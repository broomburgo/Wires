import Dispatch

public enum Signal<A> {
    case next(A)
    case stop
    
    public func map<B>(_ transform: (A) throws -> B) rethrows -> Signal<B> {
        switch self {
        case .next(let value):
            return try .next(transform(value))
        case .stop:
            return .stop
        }
    }
}

public protocol Producer: class {
    associatedtype ProducedType
    
    var productionQueue: DispatchQueue { get }
    
    @discardableResult
    func upon(_ callback: @escaping (Signal<ProducedType>) -> ()) -> Self
}

public protocol Consumer: class {
    associatedtype ConsumedType
    
    @discardableResult
    func receive(_ signal: Signal<ConsumedType>) -> Self
}
