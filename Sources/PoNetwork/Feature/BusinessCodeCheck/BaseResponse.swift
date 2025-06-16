import Foundation
import Alamofire

public protocol BaseResponseProtocol: Decodable, Sendable {
    var code: Int? { get }
    var msg: String? { get }
    
    func generateErrorBySelf() -> NetworkError
}

public struct BaseDataResponse<T: Decodable>: BaseResponseProtocol, @unchecked Sendable {
    public var code: Int?
    public var msg: String?
    public var data: T?
    
    public func generateErrorBySelf() -> NetworkError {
        if data == nil {
            let innerError = NSError(domain: "poNetwork", code: self.code ?? 0, userInfo: [NSLocalizedDescriptionKey: msg ?? "base response data null"])
            return NetworkError.responseValidationFailed(reason: .customValidationFailed(error: innerError))
        }
        let innerError = NSError(domain: "poNetwork", code: self.code ?? 0, userInfo: [NSLocalizedDescriptionKey: msg ?? "base response business check error"])
        return NetworkError.responseValidationFailed(reason: .customValidationFailed(error: innerError))
    }
    
}

public struct BaseEmptyDataResponse: BaseResponseProtocol {
    public var code: Int?
    public var msg: String?
    
    public func generateErrorBySelf() -> NetworkError {
        let innerError = NSError(domain: "poNetwork", code: self.code ?? 0, userInfo: [NSLocalizedDescriptionKey: msg ?? "base response business check error"])
        return NetworkError.responseValidationFailed(reason: .customValidationFailed(error: innerError))
    }
}

