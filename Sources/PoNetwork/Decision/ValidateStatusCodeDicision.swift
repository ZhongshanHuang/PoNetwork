import Foundation
import Alamofire

public struct ValidateStatusCodeDicision: Decision {
    
    public let acceptableStatusCode: Set<Int>
    
    public init<T: Sequence>(acceptableStatusCode: T = 200..<300) where T.Element == Int {
        self.acceptableStatusCode = Set(acceptableStatusCode)
    }
    
    public func shouldApply(request: Request, response: RawDataResponse) -> Bool {
        true
    }
    
    public func apply(request: Request, response: RawDataResponse, done: @MainActor @escaping (DecisionAction) -> Void) {
        guard let statusCode = response.statusCode else { done(.continueNext); return }
        if acceptableStatusCode.contains(statusCode) {
            done(.continueNext)
            return
        }
        let reason: NetworkError.ResponseValidationFailureReason = .unacceptableStatusCode(code: statusCode)
        done(.error(NetworkError.responseValidationFailed(reason: reason)))
    }
}
