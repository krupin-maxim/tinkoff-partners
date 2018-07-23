import Foundation

public enum Result<T> {
    case fulfilled(T)
    case rejected(Error)
}

public extension Result {
    var isFulfilled: Bool {
        switch self {
        case .fulfilled:
            return true
        case .rejected:
            return false
        }
    }
}