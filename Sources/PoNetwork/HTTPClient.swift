public import Foundation
@preconcurrency public import Alamofire

public typealias DataCompletionHandler = @MainActor @Sendable (RawDataResponse) -> Void
public typealias DownloadCompletionHandler = @MainActor @Sendable (DownloadResponse) -> Void

nonisolated
public final class HTTPClient: @unchecked Sendable {
    public static let `default`: HTTPClient = HTTPClient()
    
    private let session: Session
    /// 只应用于data和upload request
    private let decisionPiple: [any Decision]
    
    public init(sessionConfig: URLSessionConfiguration = URLSessionConfiguration.af.default,
                requestAdapter: any RequestAdapter = PassthroughRequestAdapter(),
                decisionPiple: [any Decision] = [],
                serverTrustManager: ServerTrustManager? = nil) {
        let interceptor = Adapter({ request, _, completion in
            do {
                let newRequest = try requestAdapter.adapte(request)
                completion(.success(newRequest))
            } catch {
                completion(.failure(error))
            }
        })
        self.decisionPiple = decisionPiple
        self.session = Session(configuration: sessionConfig, interceptor: interceptor, serverTrustManager: serverTrustManager)
    }
    
    // MARK: - Data
    @discardableResult
    public func send(_ request: DataRequest, decisionPiple: [any Decision]? = nil, completionHandler: @escaping DataCompletionHandler) -> DataRequest {
        let afRequest = session.request(request)
        if let (handler, queue) = request.uploadProgressHandler {
            afRequest.uploadProgress(queue: queue, closure: handler)
        }
        if let (handler, queue) = request.downloadProgressHandler {
            afRequest.downloadProgress(queue: queue, closure: handler)
        }
        afRequest.response(queue: .main) { response in
            MainActor.assumeIsolated {
                let dataResponse = DataResponse(request: response.request, response: response.response, data: response.data, metrics: response.metrics, result: response.result)
                self.handleDecision(request: request, response: dataResponse, decisionPiple: decisionPiple ?? self.decisionPiple, completionHandler: completionHandler)
            }
        }
        request.innerRequest = afRequest
        return request
    }
    
    // MARK: - Upload
    @discardableResult
    public func send(_ request: UploadRequest, decisionPiple: [any Decision]? = nil, completionHandler: @escaping DataCompletionHandler) -> UploadRequest {
        let afRequest: Alamofire.UploadRequest
        switch request.uploadable {
        case .data(let data):
            afRequest = session.upload(data, with: request)
        case .file(let fileURL):
            afRequest = session.upload(fileURL, with: request)
        case .stream(let inputStream):
            afRequest = session.upload(inputStream, with: request)
        case .multipartFormData(let multipartFormData):
            afRequest = session.upload(multipartFormData: multipartFormData, with: request)
        }
        if let (handler, queue) = request.uploadProgressHandler {
            afRequest.uploadProgress(queue: queue, closure: handler)
        }
        if let (handler, queue) = request.downloadProgressHandler {
            afRequest.downloadProgress(queue: queue, closure: handler)
        }
        afRequest.response(queue: .main) { response in
            MainActor.assumeIsolated {
                let dataResponse = DataResponse(request: response.request, response: response.response, data: response.data, metrics: response.metrics, result: response.result)
                self.handleDecision(request: request, response: dataResponse, decisionPiple: decisionPiple ?? self.decisionPiple, completionHandler: completionHandler)
            }
        }
        request.innerRequest = afRequest
        return request
    }
    
    // MARK: - Download
    @discardableResult
    public func send(_ request: DownloadRequest, completionHandler: @escaping DownloadCompletionHandler) -> DownloadRequest {
        let afRequest = session.download(request, to: request.destination)
        if let (handler, queue) = request.uploadProgressHandler {
            afRequest.uploadProgress(queue: queue, closure: handler)
        }
        if let (handler, queue) = request.downloadProgressHandler {
            afRequest.downloadProgress(queue: queue, closure: handler)
        }
        afRequest.response(queue: .main) { response in
            MainActor.assumeIsolated {
                let downloadResponse = DownloadResponse(request: response.request, response: response.response, fileURL: response.fileURL, metrics: response.metrics, result: response.result)
                completionHandler(downloadResponse)
            }
        }
        request.innerRequest = afRequest
        return request
    }
    
}

// MARK: - Handle Decision
extension HTTPClient {
    
    @MainActor
    private func handleDecision(request: Request, response: RawDataResponse, decisionPiple: [any Decision], completionHandler: @escaping DataCompletionHandler) {
        guard !decisionPiple.isEmpty else { completionHandler(response); return }
        
        var decisionPiple = decisionPiple
        let first = decisionPiple.removeFirst()
        
        guard first.shouldApply(request: request, response: response) else {
            handleDecision(request: request, response: response, decisionPiple: decisionPiple, completionHandler: completionHandler)
            return
        }
        first.apply(request: request, response: response) { (action) in
            switch action {
            case .continueNext:
                self.handleDecision(request: request, response: response, decisionPiple: decisionPiple, completionHandler: completionHandler)
            case .complete:
                completionHandler(response)
            case .error(let error):
                completionHandler(response.replaceFailure(with: error))
            case .restart:
                if let dataRequest = request as? DataRequest {
                    self.send(dataRequest, completionHandler: completionHandler)
                } else if let uploadRequest = request as? UploadRequest {
                    self.send(uploadRequest, completionHandler: completionHandler)
                } else {
                    fatalError("Not support request type: \(request)")
                }
            case .restartWithHost(let newHost):
                if let dataRequest = request as? DataRequest {
                    do {
                        let newRequest = try dataRequest.newRequest(with: newHost)
                        self.send(newRequest, completionHandler: completionHandler)
                    } catch let error as AFError {
                        completionHandler(response.replaceFailure(with: error))
                    } catch {
                        completionHandler(response)
                    }
                } else if let uploadRequest = request as? UploadRequest {
                    do {
                        let newRequest = try uploadRequest.newRequest(with: newHost)
                        self.send(newRequest, completionHandler: completionHandler)
                    } catch let error as AFError {
                        completionHandler(response.replaceFailure(with: error))
                    } catch {
                        completionHandler(response)
                    }
                } else {
                    fatalError("Not support request type: \(request)")
                }
            }
        }
    }
    
}
