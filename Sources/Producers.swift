import Dispatch
import Monads

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

// MARK: -

public final class Speaker<T>: Producer, CustomStringConvertible {
	public typealias ProducedType = T

	private var callbacks: [(Signal<T>) -> ()] = []

    public let productionQueue: DispatchQueue
	public let description: String

	public init(productionQueue: DispatchQueue = .main, customDescription: String? = nil) {
        self.productionQueue = productionQueue
		self.description = customDescription ?? "Speaker<\(T.self)>"
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

	deinit {
		mute()
	}
}

// MARK: -

public final class Fixed<T>: Producer, PureConstructible {
    public typealias ProducedType = T
	public typealias ElementType = ProducedType

    public var productionQueue: DispatchQueue
    public let value: T
    
    public init(_ value: T, productionQueue: DispatchQueue) {
        self.value = value
        self.productionQueue = productionQueue
		Log.with(context: self, text: "init with \(value)")
    }

	public convenience init(_ value: T) {
		self.init(value, productionQueue: .main)
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

// MARK: -

public final class Future<T>: Producer, PureConstructible {
	public typealias ProducedType = T
	public typealias ElementType = ProducedType

	private let execute: (@escaping (T) -> ()) -> ()
	private let speaker: Speaker<T>
	private var fixed: Fixed<T>? = nil

	private var currentState: FutureState<T> = .idle {
		didSet {
			Log.with(context: self, text: "updating state to \(currentState)")
			guard case .complete(let value) = currentState else { return }
			speaker.say(value)
			speaker.mute()
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

	public convenience init(_ value: T) {
		self.init(execute: { $0(value) })
	}

	public var value: T? {
		guard case .complete(let value) = currentState else { return nil }
		return value
	}

	@discardableResult
	public func start() -> Self {
		guard case .idle = currentState else {
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
		return start()
	}

	deinit {
		speaker.mute()
	}
}

fileprivate enum FutureState<A> {
	case idle
	case processing
	case complete(A)
}

extension Deferred {
	public var toFuture: Future<ElementType> {
		return Future<ElementType>.init(execute: self.run)
	}
}

// MARK: -

public final class CombineLatest<Source1,Source2>: Producer {
    public typealias ProducedType = (Source1,Source2)
    public let productionQueue: DispatchQueue
    private let root1: AnyProducer<Source1>
    private let root2: AnyProducer<Source2>
    private var value1: Source1? = nil
    private var value2: Source2? = nil
    private let speaker: Speaker<(Source1,Source2)>
    private let wireBundle = WireBundle.init()
    
    public init<P1,P2>(_ root1: P1, _ root2: P2) where P1: Producer, P1.ProducedType == Source1, P2: Producer, P2.ProducedType == Source2 {
        self.productionQueue = root1.productionQueue
        self.root1 = root1.any
        self.root2 = root2.any
        self.speaker = Speaker<(Source1,Source2)>.init(productionQueue: self.productionQueue)
        
        self.root1
			.consume(onStop: { [weak self] in
				guard let this = self else { return }
				this.speaker.mute()
			}) { [weak self] value1 in
                guard let this = self else { return }
                this.value1 = value1
                guard let value1 = this.value1, let value2 = this.value2 else { return }
                this.speaker.say((value1,value2))
            }
            .add(to: self.wireBundle)
        
        self.root2
			.consume(onStop: { [weak self] in
				guard let this = self else { return }
				this.speaker.mute()
			}) { [weak self] value2 in
                guard let this = self else { return }
                this.value2 = value2
                guard let value1 = this.value1, let value2 = this.value2 else { return }
                this.speaker.say((value1,value2))
            }
            .add(to: self.wireBundle)
    }
    
    public func upon(_ callback: @escaping (Signal<(Source1, Source2)>) -> ()) -> Self {
        self.speaker.upon(callback)
        return self
    }
    
    deinit {
		speaker.mute()
        wireBundle.disconnect()
    }
}

public func combineLatest<P1,P2>(_ producer1: P1, _ producer2: P2) -> CombineLatest<P1.ProducedType,P2.ProducedType> where P1: Producer, P2: Producer {
    return CombineLatest.init(producer1, producer2)
}

// MARK: -

public final class CombineLatest3<Source1,Source2,Source3>: Producer {
    public typealias ProducedType = (Source1,Source2,Source3)
    public let productionQueue: DispatchQueue
    private let root1: AnyProducer<Source1>
    private let root2: AnyProducer<Source2>
    private let root3: AnyProducer<Source3>
    private var value1: Source1? = nil
    private var value2: Source2? = nil
    private var value3: Source3? = nil
    private let speaker: Speaker<(Source1,Source2,Source3)>
    private let wireBundle = WireBundle.init()
    
    public init<P1,P2,P3>(_ root1: P1, _ root2: P2, _ root3: P3) where P1: Producer, P1.ProducedType == Source1, P2: Producer, P2.ProducedType == Source2, P3: Producer, P3.ProducedType == Source3 {
        self.productionQueue = root1.productionQueue
        self.root1 = root1.any
        self.root2 = root2.any
        self.root3 = root3.any
        self.speaker = Speaker<(Source1,Source2,Source3)>.init(productionQueue: self.productionQueue)
        
        self.root1
            .consume(onStop: { [weak self] in
                guard let this = self else { return }
                this.speaker.mute()
            }) { [weak self] value1 in
                guard let this = self else { return }
                this.value1 = value1
                guard let value1 = this.value1, let value2 = this.value2, let value3 = this.value3 else { return }
                this.speaker.say(value1,value2,value3)
            }
            .add(to: self.wireBundle)
        
        self.root2
            .consume(onStop: { [weak self] in
                guard let this = self else { return }
                this.speaker.mute()
            }) { [weak self] value2 in
                guard let this = self else { return }
                this.value2 = value2
                guard let value1 = this.value1, let value2 = this.value2, let value3 = this.value3 else { return }
                this.speaker.say(value1,value2, value3)
            }
            .add(to: self.wireBundle)
        
        self.root3
            .consume(onStop: { [weak self] in
                guard let this = self else { return }
                this.speaker.mute()
            }) { [weak self] value3 in
                guard let this = self else { return }
                this.value3 = value3
                guard let value1 = this.value1, let value2 = this.value2, let value3 = this.value3 else { return }
                this.speaker.say(value1,value2, value3)
            }
            .add(to: self.wireBundle)
    }
    
    public func upon(_ callback: @escaping (Signal<(Source1, Source2, Source3)>) -> ()) -> Self {
        self.speaker.upon(callback)
        return self
    }
    
    deinit {
        speaker.mute()
        wireBundle.disconnect()
    }
}

public func combineLatest<P1,P2,P3>(_ producer1: P1, _ producer2: P2, _ producer3: P3) -> CombineLatest3<P1.ProducedType,P2.ProducedType,P3.ProducedType> where P1: Producer, P2: Producer, P3: Producer {
    return CombineLatest3.init(producer1, producer2, producer3)
}

// MARK: -

public final class Zip2Producer<Source1,Source2>: Producer {
	public typealias ProducedType = (Source1,Source2)
	public let productionQueue: DispatchQueue
	private let root1: AnyProducer<Source1>
	private let root2: AnyProducer<Source2>
	private var value1Queue: [Source1] = []
	private var value2Queue: [Source2] = []
	private let speaker: Speaker<(Source1,Source2)>
	private let wireBundle = WireBundle.init()

	public init<P1,P2>(_ root1: P1, _ root2: P2) where P1: Producer, P2: Producer, P1.ProducedType == Source1, P2.ProducedType == Source2 {
		self.productionQueue = root1.productionQueue
		self.root1 = root1.any
		self.root2 = root2.any
		self.speaker = Speaker<(Source1,Source2)>.init(productionQueue: self.productionQueue)
		
		self.root1
			.consume(onStop: { [weak self] in
				guard let this = self else { return }
				this.speaker.mute()
			}) { [weak self] value1 in
				guard let this = self else { return }
				this.value1Queue.append(value1)
				guard let enqueuedValue1 = this.value1Queue.first, let enqueuedValue2 = this.value2Queue.first else { return }
				this.value1Queue.removeFirst(1)
				this.value2Queue.removeFirst(1)
				this.speaker.say((enqueuedValue1,enqueuedValue2))
			}
			.add(to: self.wireBundle)

		self.root2
			.consume(onStop: { [weak self] in
				guard let this = self else { return }
				this.speaker.mute()
			}) { [weak self] value2 in
				guard let this = self else { return }
				this.value2Queue.append(value2)
				guard let enqueuedValue1 = this.value1Queue.first, let enqueuedValue2 = this.value2Queue.first else { return }
				this.value1Queue.removeFirst(1)
				this.value2Queue.removeFirst(1)
				this.speaker.say((enqueuedValue1,enqueuedValue2))
			}
			.add(to: self.wireBundle)
	}

	public func upon(_ callback: @escaping (Signal<(Source1, Source2)>) -> ()) -> Self {
		self.speaker.upon(callback)
		return self
	}

	deinit {
		speaker.mute()
		wireBundle.disconnect()
	}
}

public func zip<P1,P2>(_ producer1: P1, _ producer2: P2) -> Zip2Producer<P1.ProducedType,P2.ProducedType> where P1: Producer, P2: Producer {
	return Zip2Producer.init(producer1, producer2)
}

// MARK: -

public final class Zip3Producer<Source1,Source2,Source3>: Producer {
	public typealias ProducedType = (Source1,Source2,Source3)
	public let productionQueue: DispatchQueue
	private let root1: AnyProducer<Source1>
	private let root2: AnyProducer<Source2>
	private let root3: AnyProducer<Source3>
	private var value1Queue: [Source1] = []
	private var value2Queue: [Source2] = []
	private var value3Queue: [Source3] = []
	private let speaker: Speaker<(Source1,Source2,Source3)>
	private let wireBundle = WireBundle.init()

	public init<P1,P2,P3>(_ root1: P1, _ root2: P2, _ root3: P3) where P1: Producer, P2: Producer, P3: Producer, P1.ProducedType == Source1, P2.ProducedType == Source2, P3.ProducedType == Source3 {
		self.productionQueue = root1.productionQueue
		self.root1 = root1.any
		self.root2 = root2.any
		self.root3 = root3.any
		self.speaker = Speaker<(Source1,Source2,Source3)>.init(productionQueue: self.productionQueue)

		self.root1
			.consume(onStop: { [weak self] in
				guard let this = self else { return }
				this.speaker.mute()
			}) { [weak self] value1 in
				guard let this = self else { return }
				this.value1Queue.append(value1)
				guard
					let enqueuedValue1 = this.value1Queue.first,
					let enqueuedValue2 = this.value2Queue.first,
					let enqueuedValue3 = this.value3Queue.first
					else { return }
				this.value1Queue.removeFirst(1)
				this.value2Queue.removeFirst(1)
				this.value3Queue.removeFirst(1)
				this.speaker.say((enqueuedValue1,enqueuedValue2,enqueuedValue3))
			}
			.add(to: self.wireBundle)

		self.root2
			.consume(onStop: { [weak self] in
				guard let this = self else { return }
				this.speaker.mute()
			}) { [weak self] value2 in
				guard let this = self else { return }
				this.value2Queue.append(value2)
				guard
					let enqueuedValue1 = this.value1Queue.first,
					let enqueuedValue2 = this.value2Queue.first,
					let enqueuedValue3 = this.value3Queue.first
					else { return }
				this.value1Queue.removeFirst(1)
				this.value2Queue.removeFirst(1)
				this.value3Queue.removeFirst(1)
				this.speaker.say((enqueuedValue1,enqueuedValue2,enqueuedValue3))
			}
			.add(to: self.wireBundle)

		self.root3
			.consume(onStop: { [weak self] in
				guard let this = self else { return }
				this.speaker.mute()
			}) { [weak self] value3 in
				guard let this = self else { return }
				this.value3Queue.append(value3)
				guard
					let enqueuedValue1 = this.value1Queue.first,
					let enqueuedValue2 = this.value2Queue.first,
					let enqueuedValue3 = this.value3Queue.first
					else { return }
				this.value1Queue.removeFirst(1)
				this.value2Queue.removeFirst(1)
				this.value3Queue.removeFirst(1)
				this.speaker.say((enqueuedValue1,enqueuedValue2,enqueuedValue3))
			}
			.add(to: self.wireBundle)
	}

	public func upon(_ callback: @escaping (Signal<(Source1, Source2, Source3)>) -> ()) -> Self {
		self.speaker.upon(callback)
		return self
	}

	deinit {
		speaker.mute()
		wireBundle.disconnect()
	}
}

public func zip<P1,P2,P3>(_ producer1: P1, _ producer2: P2, _ producer3: P3) -> Zip3Producer<P1.ProducedType,P2.ProducedType,P3.ProducedType> where P1: Producer, P2: Producer, P3: Producer {
	return Zip3Producer.init(producer1, producer2, producer3)
}
