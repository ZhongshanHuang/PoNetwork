public import Foundation
public import Alamofire

public struct RetryCountDicision: Decision {
    public let retryLimit: UInt
    public let timeInterval: TimeInterval
    
    public init(retryLimit: UInt = 2, timeInterval: TimeInterval = 0.5) {
        self.retryLimit = retryLimit
        self.timeInterval = timeInterval
    }
    
    public func shouldApply(request: Request, response: RawDataResponse) -> Bool {
        guard let error = response.error, request.sendCount < retryLimit + 1 else { return false }
        
        guard Alamofire.RetryPolicy.defaultRetryableHTTPMethods.contains(request.method) else { return false }

        if let statusCode = response.statusCode, Alamofire.RetryPolicy.defaultRetryableHTTPStatusCodes.contains(statusCode) {
            return true
        } else {
            guard let code = (error.underlyingError as? URLError)?.code else { return false }

            return Alamofire.RetryPolicy.defaultRetryableURLErrorCodes.contains(code)
        }

    }
    
    public func apply(request: Request, response: RawDataResponse, done: @MainActor @escaping (DecisionAction) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
            done(.restart)
        }
    }
    
}
