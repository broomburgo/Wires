import Dispatch

extension Producer {
	@discardableResult
	public func onNext(_ callback: @escaping (ProducedType) -> ()) -> Self {
		return upon { signal in
			guard case .next(let value) = signal else { return }
			callback(value)
		}
	}

	@discardableResult
	public func onStop(_ callback: @escaping () -> ()) -> Self {
		return upon { signal in
			guard case .stop = signal else { return }
			callback()
		}
	}
}

public final class Speaker<T>: Producer {
	public typealias ProducedType = T

	private var callbacks: [(Signal<T>) -> ()] = []

    public let productionQueue: DispatchQueue
    
    public init(productionQueue: DispatchQueue = .main) {
        self.productionQueue = productionQueue
		Log.with(context: self, text: "init")
    }
    
	public func say(_ value: T) {
		Log.with(context: self, text: "saying \(value)")
        callbacks.forEach { callback in
            self.productionQueue.async { callback(.next(value)) }
        }
	}

	@discardableResult
	public func mute() -> Speaker<T> {
		Log.with(context: self, text: "muting")
        callbacks.forEach { callback in
            self.productionQueue.async { callback(.stop) }
        }
		callbacks.removeAll()
		return self
	}

	@discardableResult
	public func upon(_ callback: @escaping (Signal<T>) -> ()) -> Speaker<T> {
		Log.with(context: self, text: "appending callback")
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
		Log.with(context: self, text: "init with \(value)")
    }
    
    @discardableResult
    public func upon(_ callback: @escaping (Signal<T>) -> ()) -> Self {
		Log.with(context: self, text: "yielding \(value)")
        productionQueue.async { callback(.next(self.value)) }
        return self
    }
}

extension Fixed where T: Sequence {
	@discardableResult
	public func uponEach(stopAtEnd: Bool, _ callback: @escaping (Signal<T.Iterator.Element>) -> ()) -> Self {
		Log.with(context: self, text: "yielding \(value) one by one")
		for element in value {
			productionQueue.async { callback(.next(element)) }
		}
		if stopAtEnd {
			productionQueue.async { callback(.stop) }
		}
		return self
	}
}

public final class Future<T>: Producer {
	public typealias ProducedType = T

	private let execute: (@escaping (T) -> ()) -> ()
	private let speaker: Speaker<T>
	private var fixed: Fixed<T>? = nil

	private var currentState: FutureState<T> = .idle {
		didSet {
			Log.with(context: self, text: "updating state to \(currentState)")
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

	public init(on productionQueue: DispatchQueue = .main, execute: @escaping (@escaping (T) -> ()) -> ()) {
		self.execute = execute
		self.speaker = Speaker.init(productionQueue: productionQueue)
		Log.with(context: self, text: "init")
	}

	public var value: T? {
		guard case .complete(let value) = currentState else { return nil }
		return value
	}

	@discardableResult
	public func start() -> Self {
		guard case .idle = currentState else {
			Log.with(context: self, text: "cannot start because already started and in state \(currentState)")
			return self
		}
		Log.with(context: self, text: "starting")
		currentState = .processing
		execute { [weak self] value in
			guard let this = self else { return }
			Log.with(context: this, text: "completing with \(value)")
			this.currentState = .complete(value)
		}
		return self
	}

	public func upon(_ callback: @escaping (Signal<T>) -> ()) -> Self {
		if let fixed = fixed {
			Log.with(context: self, text: "handling callback with FIXED")
			fixed.upon(callback)
		} else {
			Log.with(context: self, text: "handling callback with SPEAKER")
			speaker.upon(callback)
		}
		return self
	}
}

fileprivate enum FutureState<A> {
	case idle
	case processing
	case complete(A)
}
