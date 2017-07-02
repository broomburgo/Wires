import Dispatch

public protocol Transformer: Producer {
    associatedtype TransformedType
    func transform(_ value: Signal<TransformedType>) -> (@escaping (Signal<ProducedType>) -> ()) -> ()
}

open class AbstractTransformer<Source,Target>: Transformer {
    public typealias TransformedType = Source
    public typealias ProducedType = Target
    
    private let roots: [AnyProducer<Source>]
    let transformationQueue: DispatchQueue
    public let productionQueue: DispatchQueue
    private let speaker: Speaker<Target>
    private lazy var listener: Listener<Source> = Listener<Source>.init(listen: { [weak self] signal in
        guard let this = self else { return }
        this.transformationQueue.async {
            let call = this.transform(signal)
            call { newSignal in
                switch newSignal {
                case .next(let value):
                    this.speaker.say(value)
                case .stop:
                    this.speaker.mute()
                }
            }
        }
    })
    
    public init<P>(_ roots: [P], transformationQueue: DispatchQueue, productionQueue: DispatchQueue) where P: Producer, P.ProducedType == Source {
        self.roots = roots.map(AnyProducer.init)
        self.transformationQueue = transformationQueue
        self.productionQueue = productionQueue
        self.speaker = Speaker<Target>.init(productionQueue: productionQueue)
        for root in roots {
            root.upon { [weak self] signal in self?.listener.receive(signal) }
        }
    }
    
    @discardableResult
    public func upon(_ callback: @escaping (Signal<Target>) -> ()) -> Self {
        self.speaker.upon(callback)
        return self
    }
    
    public func transform(_ value: Signal<Source>) -> (@escaping (Signal<Target>) -> ()) -> () {
        fatalError("\(self): transform(_:) not implemented")
    }
}

public final class MapProducer<Source,Target>: AbstractTransformer<Source,Target> {
    private let mappingFunction: (Source) -> Target
    
    public init<P>(_ root: P, queue: DispatchQueue, mappingFunction: @escaping (Source) -> Target) where P: Producer, P.ProducedType == Source {
        self.mappingFunction = mappingFunction
        super.init([root], transformationQueue: queue, productionQueue: root.productionQueue)
    }
    
    public override func transform(_ signal: Signal<Source>) -> (@escaping (Signal<Target>) -> ()) -> () {
        return { [weak self] done in
            guard let this = self else { return }
            done(signal.map(this.mappingFunction))
        }
    }
}

public final class FlatMapProducer<Source,Target>: AbstractTransformer<Source,Target> {
    private let flatMappingFunction: (Source) -> AnyProducer<Target>
    private var newProducers: [Int : AnyProducer<Target>] = [:]
    private var currentIndex = 0
    
    public init<P>(_ root: P, queue: DispatchQueue, flatMappingFunction: @escaping (Source) -> AnyProducer<Target>) where P: Producer, P.ProducedType == Source {
        self.flatMappingFunction = flatMappingFunction
        super.init([root], transformationQueue: queue, productionQueue: root.productionQueue)
    }
    
    public override func transform(_ signal: Signal<Source>) -> (@escaping (Signal<Target>) -> ()) -> () {
        return { [weak self] done in
            guard let this = self else { return }
            switch signal {
            case .next(let value):
                let newProducer = this.flatMappingFunction(value)
                this.currentIndex += 1
                let newIndex = this.currentIndex
                this.newProducers[newIndex] = newProducer
                newProducer.upon(done)
                newProducer.upon { [weak this] newSignal in
                    switch newSignal {
                    case .stop:
                        this?.newProducers[newIndex] = nil
                    case .next:
                        break
                    }
                }
            case .stop:
                this.newProducers.removeAll()
                done(.stop)
            }
        }
    }
}

public final class FilterProducer<Wrapped>: AbstractTransformer<Wrapped,Wrapped> {
    private let conditionFunction: (Wrapped) -> Bool
    
    public init<P>(_ root: P, queue: DispatchQueue, conditionFunction: @escaping (Wrapped) -> Bool) where P: Producer, P.ProducedType == Wrapped {
        self.conditionFunction = conditionFunction
        super.init([root], transformationQueue: queue, productionQueue: root.productionQueue)
    }
    
    public override func transform(_ signal: Signal<Wrapped>) -> (@escaping (Signal<Wrapped>) -> ()) -> () {
        return { [weak self] done in
            guard let this = self else { return }
            switch signal {
            case .next(let value):
                if this.conditionFunction(value) { done(.next(value)) }
            case .stop:
                done(.stop)
            }
        }
    }
}

public final class MergeProducer<Wrapped>: AbstractTransformer<Wrapped,Wrapped> {
    public init<P>(_ root: P, queue: DispatchQueue, other: P) where P:Producer, P.ProducedType == Wrapped {
        super.init([root, other], transformationQueue: queue, productionQueue: DispatchQueue.main)
    }
    
    public override func transform(_ signal: Signal<Wrapped>) -> (@escaping (Signal<Wrapped>) -> ()) -> () {
        return { [weak self] done in
            guard self != nil else { return }
            done(signal)
        }
    }
}

public final class DebounceProducer<Wrapped>: AbstractTransformer<Wrapped,Wrapped> {
    private let delay: Double
    private var currentSignalId: Int = 0
    
    public init<P>(_ root: P, queue: DispatchQueue, delay: Double) where P: Producer, P.ProducedType == Wrapped {
        self.delay = delay
        super.init([root], transformationQueue: queue, productionQueue: root.productionQueue)
    }
    
    public override func transform(_ signal: Signal<Wrapped>) -> (@escaping (Signal<Wrapped>) -> ()) -> () {
        currentSignalId += 1
        let expectedSignalId = currentSignalId
        return { [weak self] done in
            guard let this = self else { return }
            switch signal {
            case .next(let value):
                this.transformationQueue.asyncAfter(deadline: .now() + this.delay, execute: {
                    guard this.currentSignalId == expectedSignalId else { return }
                    done(.next(value))
                })
            case .stop:
                done(.stop)
            }
        }
    }
}

public final class CachedProducer<Wrapped>: AbstractTransformer<Wrapped,Wrapped> {
    private var constant: Fixed<Wrapped>? = nil
    
    public init<P>(_ root: P, queue: DispatchQueue) where P:Producer, P.ProducedType == Wrapped {
        super.init([root], transformationQueue: queue, productionQueue: root.productionQueue)
        root.upon { [weak self] signal in
            guard let this = self else { return }
            this.receiveConstant(with: signal)
        }
    }
    
    public override func transform(_ signal: Signal<Wrapped>) -> (@escaping (Signal<Wrapped>) -> ()) -> () {
        return { [weak self] done in
            guard let this = self else { return }
            this.receiveConstant(with: signal)
            done(signal)
        }
    }
    
    @discardableResult
    public override func upon(_ callback: @escaping (Signal<Wrapped>) -> ()) -> Self {
        constant?.upon(callback)
        super.upon(callback)
        return self
    }
    
    private func receiveConstant(with signal: Signal<Wrapped>) {
        switch signal {
        case .next(let value):
            constant = Fixed.init(value, productionQueue: productionQueue)
        case .stop:
            constant = nil
        }
    }
}

extension Producer {
	public func map<A>(on queue: DispatchQueue = .main, _ transform: @escaping (ProducedType) -> A) -> MapProducer<ProducedType,A> {
		return MapProducer<ProducedType,A>.init(self, queue: queue, mappingFunction: transform)
	}

	public func flatMap<A>(on queue: DispatchQueue = .main, _ transform: @escaping (ProducedType) -> AnyProducer<A>) -> FlatMapProducer<ProducedType,A> {
		return FlatMapProducer<ProducedType,A>.init(self, queue: queue, flatMappingFunction: transform)
	}

	public func debounce(on queue: DispatchQueue = .main, _ delay: Double) -> DebounceProducer<ProducedType> {
		return DebounceProducer<ProducedType>.init(self, queue: queue, delay: delay)
	}

	public func filter(on queue: DispatchQueue = .main, _ predicate: @escaping (ProducedType) -> Bool) -> FilterProducer<ProducedType> {
		return FilterProducer<ProducedType>.init(self, queue: queue, conditionFunction: predicate)
	}

	public func cached(on queue: DispatchQueue = .main) -> CachedProducer<ProducedType> {
		return CachedProducer<ProducedType>.init(self, queue: queue)
	}

	public func merge<P>(on queue: DispatchQueue = .main, _ other: P) -> MergeProducer<ProducedType> where P:Producer, P.ProducedType == ProducedType {
		return MergeProducer<ProducedType>.init(AnyProducer(self), queue: queue, other: AnyProducer(other))
	}

	public func mapSome<A>(on queue: DispatchQueue = .main, _ transform: @escaping (ProducedType) -> A?) -> MapProducer<A?,A> {
		return map(transform)
			.filter { $0 != nil }
			.map { $0! }
	}
}
