public import Foundation

public enum DecisionAction: Sendable {
    case continueNext
    case complete
    case error(NetworkError)
    case restart
    case restartWithHost(String)
}

public protocol Decision: Sendable {
    // 是否应该进行这个决策，判断响应数据是否符合这个决策执行的条件
    @MainActor
    func shouldApply(request: Request, response: RawDataResponse) -> Bool
    
    @MainActor
    func apply(request: Request, response: RawDataResponse, done: @MainActor @escaping (DecisionAction) -> Void)
}

//public protocol DecisionProvider: AnyObject {
//    var decisions: [any Decision] { get }
//}
//
//public extension DecisionProvider {
//    var decisions: [any Decision] {
//        []
//    }
//}
