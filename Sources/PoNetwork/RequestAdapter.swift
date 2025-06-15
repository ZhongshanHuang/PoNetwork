public import Foundation

public protocol RequestAdapter {
    func adapte(_ request: URLRequest) throws -> URLRequest
}

public struct PassthroughRequestAdapter: RequestAdapter {
    
    public init() {}
    
    public func adapte(_ request: URLRequest) throws -> URLRequest {
        request
    }
}

public struct AnyRequestAdapter: RequestAdapter {
    public let closure: (URLRequest) throws -> URLRequest
    
    public init(closure: @escaping (URLRequest) throws -> URLRequest) {
        self.closure = closure
    }
    
    public func adapte(_ request: URLRequest) throws -> URLRequest {
        try closure(request)
    }
}
