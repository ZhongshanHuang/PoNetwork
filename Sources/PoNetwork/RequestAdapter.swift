public import Foundation

public protocol RequestAdapter: Sendable {
    func adapte(_ request: URLRequest) throws -> URLRequest
}

public struct PassthroughRequestAdapter: RequestAdapter {
    
    public init() {}
    
    public func adapte(_ request: URLRequest) throws -> URLRequest {
        request
    }
}

public struct AnyRequestAdapter: RequestAdapter {
    public let closure: @Sendable (URLRequest) throws -> URLRequest
    
    public init(closure: @escaping @Sendable (URLRequest) throws -> URLRequest) {
        self.closure = closure
    }
    
    public func adapte(_ request: URLRequest) throws -> URLRequest {
        try closure(request)
    }
}
