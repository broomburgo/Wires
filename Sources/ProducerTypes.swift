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
