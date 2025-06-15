public import Foundation

public struct PassthroughDecision: Decision {
    
    public func shouldApply(request: Request, response: RawDataResponse) -> Bool {
        true
    }
    
    public func apply(request: Request, response: RawDataResponse, done: @MainActor @escaping (DecisionAction) -> Void) {
        done(.complete)
    }
}
