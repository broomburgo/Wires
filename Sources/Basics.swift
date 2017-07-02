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

public protocol ProductionQueueOwner {
	var productionQueue: DispatchQueue { get }
}

public protocol Producer: class, ProductionQueueOwner {
    associatedtype ProducedType
    
    @discardableResult
    func upon(_ callback: @escaping (Signal<ProducedType>) -> ()) -> Self
}

public protocol TransformationQueueOwner {
	var transformationQueue: DispatchQueue { get }
}

public protocol Transformer: Producer, TransformationQueueOwner {
	associatedtype TransformedType
	func transform(_ value: Signal<TransformedType>) -> (@escaping (Signal<ProducedType>) -> ()) -> ()
}

public protocol Consumer: class {
	associatedtype ConsumedType

	@discardableResult
	func receive(_ signal: Signal<ConsumedType>) -> Self
}
