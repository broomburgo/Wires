import Dispatch

class BoxProducerBase<Wrapped>: Producer {
    typealias ProducedType = Wrapped
    
    var productionQueue: DispatchQueue {
        fatalError()
    }
    
    @discardableResult
    func upon(_ callback: @escaping (Signal<Wrapped>) -> ()) -> Self {
        fatalError()
    }
}

class BoxProducer<ProducerBase: Producer>: BoxProducerBase<ProducerBase.ProducedType> {
    let base: ProducerBase
    init(base: ProducerBase) {
        self.base = base
    }
    
    override var productionQueue: DispatchQueue {
        return base.productionQueue
    }
    
    @discardableResult
    override func upon(_ callback: @escaping (Signal<ProducerBase.ProducedType>) -> ()) -> Self {
        base.upon(callback)
        return self
    }
}

public class AnyProducer<A>: Producer {
    public typealias ProducedType = A
    
    private let box: BoxProducerBase<A>
    
    public var productionQueue: DispatchQueue {
        return self.box.productionQueue
    }
    
    public init<P: Producer>(_ base: P) where P.ProducedType == ProducedType {
        self.box = BoxProducer(base: base)
    }
    
    @discardableResult
    public func upon(_ callback: @escaping (Signal<A>) -> ()) -> Self {
        box.upon(callback)
        return self
    }
}

class BoxConsumerBase<Wrapped>: Consumer {
    typealias ConsumedType = Wrapped
    
    @discardableResult
    func receive(_ value: Signal<Wrapped>) -> Self {
        fatalError()
    }
}

class BoxConsumer<ConsumerBase: Consumer>: BoxConsumerBase<ConsumerBase.ConsumedType> {
    let base: ConsumerBase
    init(base: ConsumerBase) {
        self.base = base
    }
    
    @discardableResult
    override func receive(_ value: Signal<ConsumerBase.ConsumedType>) -> Self {
        base.receive(value)
        return self
    }
}

public class AnyConsumer<A>: Consumer {
    public typealias ConsumedType = A
    
    private let box: BoxConsumerBase<A>
    
    public init<C: Consumer>(_ base: C) where C.ConsumedType == ConsumedType {
        self.box = BoxConsumer(base: base)
    }
    
    @discardableResult
    public func receive(_ value: Signal<A>) -> Self {
        box.receive(value)
        return self
    }
}

extension Producer {
	public var any: AnyProducer<ProducedType> {
		return AnyProducer(self)
	}
}

extension Consumer {
	public var any: AnyConsumer<ConsumedType> {
		return AnyConsumer(self)
	}
}
