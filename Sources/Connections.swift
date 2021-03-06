import Abstract

public protocol Wire {
	var connected: Bool { get }
	func disconnect()
}

public func disconnected() -> Wire {
	return WireSingle.disconnected
}

public final class WireSingle: Wire, CustomStringConvertible {

	private var producer: Any?
	private var consumer: Any?
	public let description: String

	private(set) public var connected: Bool

	private init() {
		self.producer = nil
		self.consumer = nil
		self.description = "Wire.disconnected"
		self.connected = false
	}

	public static var disconnected: Wire {
		return WireSingle.init()
	}

	public init<P,C>(customDescription: String? = nil, producer: P, consumer: C) where P: Producer, C: Consumer, P.ProducedType == C.ConsumedType {
		self.producer = producer
		self.consumer = consumer
		self.description = customDescription ?? "WireSingle(\(producer)>--<\(consumer))"
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

public final class WireTagged: Wire, CustomStringConvertible {
	private let root: Wire
	public let tag: String

	public var connected: Bool {
		return root.connected
	}

	public func disconnect() {
		root.disconnect()
	}

	public init(root: Wire, tag: String) {
		self.root = root
		self.tag = tag
	}

	public var description: String {
		return "WireTagged(\(root))"
	}

	deinit {
		disconnect()
	}
}

public final class WireBundle: Wire, CustomStringConvertible {
	private var wires: [Wire] = []
	public let description: String

	public init(customDescription: String? = nil, _ wires: [Wire]) {
		self.wires = wires
		self.description = customDescription ?? "WireBundle"
	}

	public convenience init(customDescription: String? = nil, _ wires: Wire...) {
		self.init(customDescription: customDescription, wires)
	}

	public func add(_ value: Wire) {
		Log.with(context: self, text: "adding \(value)")
		wires.append(value)
	}

	public var connected: Bool {
		return wires.map { Or.init($0.connected) }.concatenated.unwrap
	}

	public func disconnect() {
		Log.with(context: self, text: "disconnecting")
		wires.forEach { $0.disconnect() }
		wires.removeAll()
	}

	deinit {
		disconnect()
	}
}

extension Wire {
	public func add(to bundle: WireBundle) {
		bundle.add(self)
	}
}

extension Producer {
	public func connect<C>(to consumer: C) -> Wire where C: Consumer, C.ConsumedType == ProducedType {
		return WireSingle.init(producer: self, consumer: consumer)
	}

	public func consume(onStop: @escaping () -> () = {}, onNext: @escaping (ProducedType) -> ()) -> Wire {
		let bundle = WireBundle.init()
		connect(
			to: Listener.init { [weak self, weak bundle] signal in
				guard let this = self else {
					bundle?.disconnect()
					return
				}
				switch signal {
				case .next(let value):
					Log.with(context: this, text: "consuming \(value): will callback")
					onNext(value)
				case .stop:
					Log.with(context: this, text: "consuming 'stop': will disconnect")
					onStop()
					bundle?.disconnect()
				}
			})
			.add(to: bundle)
		return bundle
	}

	public func interlace(onStop: @escaping () -> () = {}, onNext: @escaping (ProducedType) -> Wire) -> Wire {
		let bundle = WireBundle.init()
		consume(
			onStop: { [weak bundle] in
				bundle?.disconnect()
				onStop()
			},
			onNext: { [weak bundle] value in
				bundle?.add(onNext(value))
			})
			.add(to: bundle)
		return bundle
	}
}
