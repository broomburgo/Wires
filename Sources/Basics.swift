import Dispatch

public enum Signal<A>: CustomStringConvertible {
    case next(A)
    case stop
    
    public func map<B>(_ transform: (A) throws -> B) rethrows -> Signal<B> {
		let newSignal: Signal<B>
		switch self {
        case .next(let value):
            newSignal = try .next(transform(value))
        case .stop:
            newSignal = .stop
        }
		Log.with(context: "Wires.Signal", text: "mapping \(self) into \(newSignal)")
		return newSignal
	}

	public var description: String {
		switch self {
		case .next(let value):
			return ".next(\(value))"
		default:
			return ".stop"
		}
	}
}

extension Signal where A: Equatable {
	public static func == (left: Signal, right: Signal) -> Bool {
		switch (left,right) {
		case (.next(let leftValue),.next(let rightValue)) where leftValue == rightValue:
			return true
		case (.stop,.stop):
			return true
		default:
			return false
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
