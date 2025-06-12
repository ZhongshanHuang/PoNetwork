import Foundation

final class TaskCancellable : Hashable, @unchecked Sendable {

    var cancelClosure: (@Sendable () -> Void)?
    
    init(_ cancel: @Sendable @escaping () -> Void) {
        self.cancelClosure = cancel
    }

    init() {}
    
    func cancel() {
        cancelClosure?()
    }

    func hash(into hasher: inout Hasher) {
        withUnsafeBytes(of: &cancelClosure) { pt in
            hasher.combine(bytes: pt)
        }
    }
    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(ObjectIdentifier(self))
//    }
    
    static func == (lhs: TaskCancellable, rhs: TaskCancellable) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
}
