public import Foundation
public import Alamofire

public struct RetryHostDicision: Decision {
    
    public let hostMap: [String: String]
    
    public init(hostMap: [String: String]) {
        self.hostMap = hostMap
    }
    
    public func shouldApply(request: Request, response: RawDataResponse) -> Bool {
        guard let error = response.error else { return false }
        guard let url = try? request.urlConvertible.asURL(), let host = url.host, hostMap.keys.contains(host) else { return false }
        guard Alamofire.RetryPolicy.defaultRetryableHTTPMethods.contains(request.method) else { return false }

        if let statusCode = response.statusCode, Alamofire.RetryPolicy.defaultRetryableHTTPStatusCodes.contains(statusCode) {
            return true
        } else {
            guard let code = (error.underlyingError as? URLError)?.code else { return false }

            return Alamofire.RetryPolicy.defaultRetryableURLErrorCodes.contains(code)
        }

    }
    
    public func apply(request: Request, response: RawDataResponse, done: @MainActor @escaping (DecisionAction) -> Void) {
        if let url = try? request.urlConvertible.asURL(), let host = url.host, let newHost = hostMap[host] {
            done(.restartWithHost(newHost))
        } else {
            done(.continueNext)
        }
    }
    
}
