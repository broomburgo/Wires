import Dispatch

public final class Listener<T>: Consumer {
	public typealias ConsumedType = T

	private let listen: (Signal<T>) -> ()

	public init(listen: @escaping (Signal<T>) -> ()) {
		self.listen = listen
	}

	@discardableResult
	public func receive(_ value: Signal<T>) -> Listener<T> {
		listen(value)
		return self
	}
}

public final class Accumulator<T>: Consumer {
	public typealias ConsumedType = T

	public private(set) var values: [T] = []

	public init() {}

	@discardableResult
	public func receive(_ signal: Signal<T>) -> Accumulator<T> {
		switch signal {
		case .next(let value):
			values.append(value)
		case .stop:
			values.removeAll()
		}
		return self
	}
}

extension Speaker: Consumer {
	public typealias ConsumedType = T

	@discardableResult
	public func receive(_ signal: Signal<T>) -> Self {
		switch signal {
		case .next(let value):
			say(value)
		case .stop:
			mute()
		}
		return self
	}
}
