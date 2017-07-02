public protocol Disconnectable {
    var connected: Bool { get }
    func disconnect()
}

public final class Wire: Disconnectable {
    
    private var producer: Any?
    private var consumer: Any?
    
    private(set) public var connected: Bool
    
    public init<P,C>(producer: P, consumer: C) where P: Producer, C: Consumer, P.ProducedType == C.ConsumedType {
        self.producer = producer
        self.consumer = consumer
        self.connected = true
        
        producer.upon { [weak self, weak consumer] signal in
            guard
                let this = self,
                this.connected,
                let current = consumer
                else { return }
            current.receive(signal)
        }
    }
    
    public func disconnect() {
        producer = nil
        consumer = nil
        connected = false
    }
}

public final class DisconnectableBag: Disconnectable {
    private var disconnectables: [Disconnectable] = []
    
    public init() {}
    
    public func add(_ value: Disconnectable) {
        disconnectables.append(value)
    }
    
    public var connected: Bool {
        return disconnectables
            .reduce(false) { $0 || $1.connected }
    }
    
    public func disconnect() {
        disconnectables.forEach { $0.disconnect() }
        disconnectables.removeAll()
    }
}

extension Disconnectable {
    public func add(to bag: DisconnectableBag) {
        bag.add(self)
    }
}

extension Producer {
    public func connect<C>(to consumer: C) -> Wire where C: Consumer, C.ConsumedType == ProducedType {
        return Wire.init(producer: self, consumer: consumer)
    }

	public func consume(_ callback: @escaping (ProducedType) -> ()) -> Wire {
		var toDisconnect: Wire? = nil
		let disconnectable = connect(to: Listener.init { signal in
			switch signal {
			case .next(let value):
				callback(value)
			case .stop:
				toDisconnect?.disconnect()
			}
		})
		toDisconnect = disconnectable
		return disconnectable
	}
}
