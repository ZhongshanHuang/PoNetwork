import Foundation

public typealias DecodedDataCompletionHandler<T> = @MainActor @Sendable (DecodedDataResponse<T>) -> Void

extension HTTPClient {
    
    @discardableResult
    public func send(_ requestConvertible: any NetworkRequestConvertible, decisionPiple: [any Decision]? = nil, completionHandler: @escaping DataCompletionHandler) -> DataRequest {
        let request = requestConvertible.asRequest()
        return send(request, decisionPiple: decisionPiple, completionHandler: completionHandler)
    }
    
    @discardableResult
    public func send<T: DecodableType>(_ requestConvertible: any NetworkRequestConvertible, decisionPiple: [any Decision]? = nil, decodableType: T.Type, completionHandler: @escaping DecodedDataCompletionHandler<T>) -> DataRequest {
        let request = requestConvertible.asRequest()
        return send(request, decisionPiple: decisionPiple, decodableType: decodableType, completionHandler: completionHandler)
    }
    
    @discardableResult
    public func send<T: DecodableType>(_ request: DataRequest, decisionPiple: [any Decision]? = nil, decodableType: T.Type, completionHandler: @escaping DecodedDataCompletionHandler<T>) -> DataRequest {
        send(request, decisionPiple: decisionPiple) { rawDataResponse in
            completionHandler(rawDataResponse.decode(of: decodableType))
        }
    }
    
    // MARK: - Upload
    @discardableResult
    public func send<T: DecodableType>(_ request: UploadRequest, decisionPiple: [any Decision]? = nil, decodableType: T.Type, completionHandler: @escaping DecodedDataCompletionHandler<T>) -> UploadRequest {
        send(request, decisionPiple: decisionPiple) { rawDataResponse in
            completionHandler(rawDataResponse.decode(of: decodableType))
        }
    }
    
}
