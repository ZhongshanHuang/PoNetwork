public import Foundation

public typealias DecodedDataCompletionHandler<T> = @MainActor (DecodedDataResponse<T>) -> Void

extension HTTPClient {
    
    @discardableResult
    public func send(_ requestConvertible: any NetworkRequestConvertible, decisionPiple: [any Decision]? = nil, completionHandler: @escaping DataCompletionHandler) -> DataRequest {
        let dataRequest = requestConvertible.asRequest()
        return send(dataRequest, decisionPiple: decisionPiple, completionHandler: completionHandler)
    }
    
    @discardableResult
    public func send<T: DecodableType>(_ requestConvertible: any NetworkRequestConvertible, decisionPiple: [any Decision]? = nil, decodableType: T.Type, businessCodes: [Int]? = [200], completionHandler: @escaping DecodedDataCompletionHandler<T>) -> DataRequest {
        let dataRequest = requestConvertible.asRequest()
        return send(dataRequest, decisionPiple: decisionPiple) { response in
            self.handleDecodedResponse(response, decodableType: decodableType, businessCodes: businessCodes, completionHandler: completionHandler)
        }
    }
    
    @discardableResult
    public func send<T: DecodableType>(_ request: DataRequest, decisionPiple: [any Decision]? = nil, decodableType: T.Type, businessCodes: [Int]? = [200], completionHandler: @escaping DecodedDataCompletionHandler<T>) -> DataRequest {
        send(request, decisionPiple: decisionPiple) { response in
            self.handleDecodedResponse(response, decodableType: decodableType, businessCodes: businessCodes, completionHandler: completionHandler)
        }
    }
    
    // MARK: - Upload
    @discardableResult
    public func send<T: DecodableType>(_ request: UploadRequest, decisionPiple: [any Decision]? = nil, decodableType: T.Type, businessCodes: [Int]? = [200], completionHandler: @escaping DecodedDataCompletionHandler<T>) -> UploadRequest {
        send(request, decisionPiple: decisionPiple) { response in
            self.handleDecodedResponse(response, decodableType: decodableType, businessCodes: businessCodes, completionHandler: completionHandler)
        }
    }
    
}

extension HTTPClient {
    @MainActor
    fileprivate func handleDecodedResponse<T: Decodable>(_ response: RawDataResponse, decodableType: T.Type, businessCodes: [Int]?, completionHandler: DecodedDataCompletionHandler<T>) {
        let decodedResponse = response.decode(of: decodableType)
        switch decodedResponse.result {
        case .success(let success):
            if let baseResponse = success as? BaseEmptyDataResponse {
                /// 检验状态码
                if let code = baseResponse.code, businessCodes != nil && businessCodes?.contains(where: { $0 == code }) == false {
                    let error = baseResponse.generateErrorBySelf()
                    completionHandler(decodedResponse.replaceFailure(with: error))
                    return
                }
            }
            completionHandler(decodedResponse)
        case .failure:
            completionHandler(decodedResponse)
        }
    }
}
