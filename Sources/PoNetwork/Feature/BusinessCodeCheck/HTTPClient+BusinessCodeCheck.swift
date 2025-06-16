import Foundation

extension HTTPClient {
    
    // MARK: - Data
    @discardableResult
    public func send<T: DecodableType & BaseResponseProtocol>(_ requestConvertible: any NetworkRequestConvertible, decisionPiple: [any Decision]? = nil, baseDecodableType: T.Type, businessCodes: [Int]? = [200], completionHandler: @escaping DecodedDataCompletionHandler<T>) -> DataRequest {
        let dataRequest = requestConvertible.asRequest()
        return send(dataRequest, decisionPiple: decisionPiple, baseDecodableType: baseDecodableType, businessCodes: businessCodes, completionHandler: completionHandler)
    }
    
    @discardableResult
    public func send<T: DecodableType & BaseResponseProtocol>(_ request: DataRequest, decisionPiple: [any Decision]? = nil, baseDecodableType: T.Type, businessCodes: [Int]? = [200], completionHandler: @escaping DecodedDataCompletionHandler<T>) -> DataRequest {
        send(request, decisionPiple: decisionPiple) { [completionHandler] response in
            self.handleDecodedResponse(response, baseDecodableType: baseDecodableType, businessCodes: businessCodes, completionHandler: completionHandler)
        }
    }
    
    public func send<T: DecodableType & BaseResponseProtocol>(_ request: DataRequest, decisionPiple: [any Decision]? = nil, baseDecodableType: T.Type, businessCodes: [Int]? = [200]) -> sending DataTask<T> {
        let task = Task {
            await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    send(request, decisionPiple: decisionPiple, baseDecodableType: baseDecodableType, businessCodes: businessCodes) { response in
                        continuation.resume(returning: response)
                    }
                }
            } onCancel: {
                request.cancel()
            }
        }
        return DataTask(request: request, task: task, shouldAutomaticallyCancel: true)
    }
    
    public func send<T: DecodableType & BaseResponseProtocol>(_ requestConvertible: any NetworkRequestConvertible, decisionPiple: [any Decision]? = nil, baseDecodableType: T.Type) -> sending DataTask<T> {
        let request = requestConvertible.asRequest()
        return send(request, decisionPiple: decisionPiple, baseDecodableType: baseDecodableType)
    }
    
    public func send<T: DecodableType & BaseResponseProtocol>(_ request: DataRequest, decisionPiple: [any Decision]? = nil, baseDecodableType: T.Type) -> sending DataTask<T> {
        let task = Task {
            await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    send(request, decisionPiple: decisionPiple, baseDecodableType: baseDecodableType) { response in
                        continuation.resume(returning: response)
                    }
                }
            } onCancel: {
                request.cancel()
            }
        }
        return DataTask(request: request, task: task, shouldAutomaticallyCancel: true)
    }
    
    // MARK: - Upload
    @discardableResult
    public func send<T: DecodableType & BaseResponseProtocol>(_ request: UploadRequest, decisionPiple: [any Decision]? = nil, baseDecodableType: T.Type, businessCodes: [Int]? = [200], completionHandler: @escaping DecodedDataCompletionHandler<T>) -> UploadRequest {
        send(request, decisionPiple: decisionPiple) { response in
            self.handleDecodedResponse(response, baseDecodableType: baseDecodableType, businessCodes: businessCodes, completionHandler: completionHandler)
        }
    }
    
    public func send<T: DecodableType & BaseResponseProtocol>(_ request: UploadRequest, decisionPiple: [any Decision]? = nil, baseDecodableType: T.Type, businessCodes: [Int]? = [200]) -> sending UploadTask<T> {
        let task = Task {
            await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    send(request, decisionPiple: decisionPiple, baseDecodableType: baseDecodableType, businessCodes: businessCodes) { response in
                        continuation.resume(returning: response)
                    }
                }
            } onCancel: {
                request.cancel()
            }
        }
        return UploadTask(request: request, task: task, shouldAutomaticallyCancel: true)
    }
    
    public func send<T: DecodableType & BaseResponseProtocol>(_ request: UploadRequest, decisionPiple: [any Decision]? = nil, baseDecodableType: T.Type) -> sending UploadTask<T> {
        let task = Task {
            await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    send(request, decisionPiple: decisionPiple, baseDecodableType: baseDecodableType) { response in
                        continuation.resume(returning: response)
                    }
                }
            } onCancel: {
                request.cancel()
            }
        }
        return UploadTask(request: request, task: task, shouldAutomaticallyCancel: true)
    }
    
}

extension HTTPClient {
    @MainActor
    fileprivate func handleDecodedResponse<T: Decodable & BaseResponseProtocol>(_ response: RawDataResponse, baseDecodableType: T.Type, businessCodes: [Int]?, completionHandler: DecodedDataCompletionHandler<T>) {
        let decodedResponse = response.decode(of: baseDecodableType)
        switch decodedResponse.result {
        case .success(let baseResponse):
            /// 检验状态码
            if let code = baseResponse.code, businessCodes != nil && businessCodes?.contains(where: { $0 == code }) == false {
                let error = baseResponse.generateErrorBySelf()
                completionHandler(decodedResponse.replaceFailure(with: error))
                return
            }
            completionHandler(decodedResponse)
        case .failure:
            completionHandler(decodedResponse)
        }
    }
}
