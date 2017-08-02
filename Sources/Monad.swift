import Abstract
import Monads

extension Producer where ProducedType: OptionalType {
	public func mapT <A> (_ transform: @escaping (ProducedType.ElementType) -> A) -> AnyProducer<Optional<A>> {
		return map { $0.map(transform) }.any
	}

	public func flatMapT <A> (_ transform: @escaping (ProducedType.ElementType) -> AnyProducer<Optional<A>>) -> AnyProducer<Optional<A>> {
		return flatMap { $0.run(
			ifSome: { transform($0) },
			ifNone: { AnyProducer.init(Fixed.init(Optional.none)) })
		}
		.any
	}
}

public func |>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType) -> AnyProducer<Optional<A>>) -> AnyProducer<Optional<A>> where T: Producer, T.ProducedType: OptionalType {
	return object.flatMapT(transform)
}

extension Producer where ProducedType: WriterType {
	public func mapT <A> (_ transform: @escaping (ProducedType.ElementType) -> A) -> AnyProducer<Writer<A,ProducedType.LogType>> {
		return map { $0.map(transform) }.any
	}

	public func flatMapT <A> (_ transform: @escaping (ProducedType.ElementType) -> AnyProducer<Writer<A,ProducedType.LogType>>) -> AnyProducer<Writer<A,ProducedType.LogType>> {
		return flatMap { (writer) -> AnyProducer<Writer<A,ProducedType.LogType>> in
			let (oldValue,oldLog) = writer.run
			let newObject = transform(oldValue)
			return newObject.map {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}.any
		}.any
	}
}

public func |>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType) -> AnyProducer<Writer<A,T.ProducedType.LogType>>) -> AnyProducer<Writer<A,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType {
	return object.flatMapT(transform)
}
