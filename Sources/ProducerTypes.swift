import Dispatch

public final class Speaker<T>: Producer {
	public typealias ProducedType = T

	private var callbacks: [(Signal<T>) -> ()] = []

    public let productionQueue: DispatchQueue
    
    public init(productionQueue: DispatchQueue = .main) {
        self.productionQueue = productionQueue
    }
    
	public func say(_ value: T) {
        callbacks.forEach { callback in
            self.productionQueue.async { callback(.next(value)) }
        }
	}

	@discardableResult
	public func mute() -> Speaker<T> {
        callbacks.forEach { callback in
            self.productionQueue.async { callback(.stop) }
        }
		callbacks.removeAll()
		return self
	}

	@discardableResult
	public func upon(_ callback: @escaping (Signal<T>) -> ()) -> Speaker<T> {
		callbacks.append(callback)
		return self
	}
}

public final class Fixed<T>: Producer {
    public typealias ProducedType = T
    
    public var productionQueue: DispatchQueue
    fileprivate let value: T
    
    public init(_ value: T, productionQueue: DispatchQueue = .main) {
        self.value = value
        self.productionQueue = productionQueue
    }
    
    @discardableResult
    public func upon(_ callback: @escaping (Signal<T>) -> ()) -> Self {
        productionQueue.async { callback(.next(self.value)) }
        return self
    }
}

extension Fixed where T: Sequence {
	@discardableResult
	public func upon(_ callback: @escaping (Signal<T.Iterator.Element>) -> ()) -> Self {
		for element in value {
			productionQueue.async { callback(.next(element)) }
		}
		return self
	}
}

public final class Future<T>: Producer {
	public typealias ProducedType = T

	private let execute: ((T) -> ()) -> ()
	private let speaker: Speaker<T>
	private var fixed: Fixed<T>? = nil

	private var currentState: State = .idle {
		didSet {
			guard case .complete(let value) = currentState else { return }
			speaker.say(value)
			fixed = Fixed.init(value, productionQueue: speaker.productionQueue)
		}
	}

	public var productionQueue: DispatchQueue {
		if let fixed = fixed {
			return fixed.productionQueue
		} else {
			return speaker.productionQueue
		}
	}

	public init(execute: @escaping ((T) -> ()) -> (), on productionQueue: DispatchQueue = .main) {
		self.execute = execute
		self.speaker = Speaker.init(productionQueue: productionQueue)
	}

	public var value: T? {
		guard case .complete(let value) = currentState else { return nil }
		return value
	}

	public func start() -> Self {
		guard case .idle = currentState else { return self }
		currentState = .processing
		execute { [weak self] value in
			guard let this = self else { return }
			this.currentState = .complete(value)
		}
		return self
	}

	public func upon(_ callback: @escaping (Signal<T>) -> ()) -> Self {
		if let fixed = fixed {
			fixed.upon(callback)
		} else {
			speaker.upon(callback)
		}
		return self
	}

	private enum State {
		case idle
		case processing
		case complete(T)
	}
}
