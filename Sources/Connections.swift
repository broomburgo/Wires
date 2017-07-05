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
		Log.with(context: self, text: "connecting \(producer) to \(consumer)")

        producer.upon { [weak self, weak producer, weak consumer] signal in
            guard
                let this = self,
                this.connected,
                let currentConsumer = consumer,
				let currentProducer = producer
                else { return }
			Log.with(context: this, text: "passing \(signal) from \(currentProducer) to \(currentConsumer)")
            currentConsumer.receive(signal)
        }
    }
    
    public func disconnect() {
		Log.with(context: self, text: "disconnecting")
        producer = nil
        consumer = nil
        connected = false
    }

	deinit {
		disconnect()
	}
}

public final class DisconnectableBag: Disconnectable {
    private var disconnectables: [Disconnectable] = []
    
    public init() {}
    
    public func add(_ value: Disconnectable) {
		Log.with(context: self, text: "adding \(value)")
        disconnectables.append(value)
    }
    
    public var connected: Bool {
        return disconnectables
            .reduce(false) { $0 || $1.connected }
    }
    
    public func disconnect() {
		Log.with(context: self, text: "disconnecting")
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
		let disconnectable = connect(to: Listener.init { [weak self, weak toDisconnect] signal in
			guard let this = self else {
				toDisconnect?.disconnect()
				return
			}
			switch signal {
			case .next(let value):
				Log.with(context: this, text: "consuming \(value): will callback")
				callback(value)
			case .stop:
				Log.with(context: this, text: "consuming 'stop': will disconnect")
				toDisconnect?.disconnect()
			}
		})
		toDisconnect = disconnectable
		return disconnectable
	}
}
