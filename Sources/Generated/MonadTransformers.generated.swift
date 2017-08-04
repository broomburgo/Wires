// Generated using Sourcery 0.7.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT





import Abstract
import Monads


extension Producer where ProducedType: EffectType {
	public func mapT <A> (_ transform: @escaping (ProducedType.ElementType) -> A) -> AnyProducer<Effect<A>> {
		return map { $0.map(transform) }.any
	}

	public func flatMapT <A> (_ transform: @escaping (ProducedType.ElementType) -> AnyProducer<Effect<A>>) -> AnyProducer<Effect<A>> {
		return flatMap {
			transform($0.run())
		}
		.any
	}
}

public func |>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType) -> AnyProducer<Effect<A>>) -> AnyProducer<Effect<A>> where T: Producer, T.ProducedType: EffectType {
	return object.flatMapT(transform)
}


extension Producer where ProducedType: OptionalType {
	public func mapT <A> (_ transform: @escaping (ProducedType.ElementType) -> A) -> AnyProducer<Optional<A>> {
		return map { $0.map(transform) }.any
	}

	public func flatMapT <A> (_ transform: @escaping (ProducedType.ElementType) -> AnyProducer<Optional<A>>) -> AnyProducer<Optional<A>> {
		return flatMap {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Optional.none)) })
		}
		.any
	}
}

public func |>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType) -> AnyProducer<Optional<A>>) -> AnyProducer<Optional<A>> where T: Producer, T.ProducedType: OptionalType {
	return object.flatMapT(transform)
}


extension Producer where ProducedType: ResultType {
	public func mapT <A> (_ transform: @escaping (ProducedType.ElementType) -> A) -> AnyProducer<Result<A,ProducedType.ErrorType>> {
		return map { $0.map(transform) }.any
	}

	public func flatMapT <A> (_ transform: @escaping (ProducedType.ElementType) -> AnyProducer<Result<A,ProducedType.ErrorType>>) -> AnyProducer<Result<A,ProducedType.ErrorType>> {
		return flatMap {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Result.failure($0))) },
				ifCancel: { AnyProducer.init(Fixed.init(Result.cancel)) })
		}
		.any
	}
}

public func |>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType) -> AnyProducer<Result<A,T.ProducedType.ErrorType>>) -> AnyProducer<Result<A,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType {
	return object.flatMapT(transform)
}


extension Producer where ProducedType: WriterType {
	public func mapT <A> (_ transform: @escaping (ProducedType.ElementType) -> A) -> AnyProducer<Writer<A,ProducedType.LogType>> {
		return map { $0.map(transform) }.any
	}

	public func flatMapT <A> (_ transform: @escaping (ProducedType.ElementType) -> AnyProducer<Writer<A,ProducedType.LogType>>) -> AnyProducer<Writer<A,ProducedType.LogType>> {
		return flatMap {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.map {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType) -> AnyProducer<Writer<A,T.ProducedType.LogType>>) -> AnyProducer<Writer<A,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType {
	return object.flatMapT(transform)
}



extension Producer where ProducedType: EffectType, ProducedType.ElementType: EffectType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Effect<A>>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Effect<Effect<A>>>) -> AnyProducer<Effect<Effect<A>>> {
		return flatMapT {
			transform($0.run())
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Effect<Effect<A>>>) -> AnyProducer<Effect<Effect<A>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: EffectType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: OptionalType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Optional<A>>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Effect<Optional<A>>>) -> AnyProducer<Effect<Optional<A>>> {
		return flatMapT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Effect.init(Optional.none))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Effect<Optional<A>>>) -> AnyProducer<Effect<Optional<A>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: OptionalType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: ResultType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Result<A,ProducedType.ElementType.ErrorType>>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Effect<Result<A,ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Effect<Result<A,ProducedType.ElementType.ErrorType>>> {
		return flatMapT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Effect.init(Result.failure($0)))) },
				ifCancel: { AnyProducer.init(Fixed.init(Effect.init(Result.cancel))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Effect<Result<A,T.ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Effect<Result<A,T.ProducedType.ElementType.ErrorType>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: ResultType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: WriterType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Writer<A,ProducedType.ElementType.LogType>>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Effect<Writer<A,ProducedType.ElementType.LogType>>>) -> AnyProducer<Effect<Writer<A,ProducedType.ElementType.LogType>>> {
		return flatMapT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Effect<Writer<A,T.ProducedType.ElementType.LogType>>>) -> AnyProducer<Effect<Writer<A,T.ProducedType.ElementType.LogType>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: WriterType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: EffectType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Effect<A>>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Optional<Effect<A>>>) -> AnyProducer<Optional<Effect<A>>> {
		return flatMapT {
			transform($0.run())
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Optional<Effect<A>>>) -> AnyProducer<Optional<Effect<A>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: EffectType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: OptionalType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Optional<A>>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Optional<Optional<A>>>) -> AnyProducer<Optional<Optional<A>>> {
		return flatMapT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Optional.init(Optional.none))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Optional<Optional<A>>>) -> AnyProducer<Optional<Optional<A>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: OptionalType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: ResultType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Result<A,ProducedType.ElementType.ErrorType>>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Optional<Result<A,ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Optional<Result<A,ProducedType.ElementType.ErrorType>>> {
		return flatMapT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Optional.init(Result.failure($0)))) },
				ifCancel: { AnyProducer.init(Fixed.init(Optional.init(Result.cancel))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Optional<Result<A,T.ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Optional<Result<A,T.ProducedType.ElementType.ErrorType>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: ResultType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: WriterType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Writer<A,ProducedType.ElementType.LogType>>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Optional<Writer<A,ProducedType.ElementType.LogType>>>) -> AnyProducer<Optional<Writer<A,ProducedType.ElementType.LogType>>> {
		return flatMapT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Optional<Writer<A,T.ProducedType.ElementType.LogType>>>) -> AnyProducer<Optional<Writer<A,T.ProducedType.ElementType.LogType>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: WriterType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: EffectType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Result<Effect<A>,ProducedType.ErrorType>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Result<Effect<A>,ProducedType.ErrorType>>) -> AnyProducer<Result<Effect<A>,ProducedType.ErrorType>> {
		return flatMapT {
			transform($0.run())
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Result<Effect<A>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Effect<A>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: EffectType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: OptionalType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Result<Optional<A>,ProducedType.ErrorType>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Result<Optional<A>,ProducedType.ErrorType>>) -> AnyProducer<Result<Optional<A>,ProducedType.ErrorType>> {
		return flatMapT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Result.init(Optional.none))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Result<Optional<A>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Optional<A>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: OptionalType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: ResultType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Result<Result<A,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Result<Result<A,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>>) -> AnyProducer<Result<Result<A,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>> {
		return flatMapT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Result.init(Result.failure($0)))) },
				ifCancel: { AnyProducer.init(Fixed.init(Result.init(Result.cancel))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Result<Result<A,T.ProducedType.ElementType.ErrorType>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Result<A,T.ProducedType.ElementType.ErrorType>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: ResultType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: WriterType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Result<Writer<A,ProducedType.ElementType.LogType>,ProducedType.ErrorType>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Result<Writer<A,ProducedType.ElementType.LogType>,ProducedType.ErrorType>>) -> AnyProducer<Result<Writer<A,ProducedType.ElementType.LogType>,ProducedType.ErrorType>> {
		return flatMapT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Result<Writer<A,T.ProducedType.ElementType.LogType>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Writer<A,T.ProducedType.ElementType.LogType>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: WriterType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: EffectType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Effect<A>,ProducedType.LogType>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Writer<Effect<A>,ProducedType.LogType>>) -> AnyProducer<Writer<Effect<A>,ProducedType.LogType>> {
		return flatMapT {
			transform($0.run())
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Writer<Effect<A>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Effect<A>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: EffectType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: OptionalType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Optional<A>,ProducedType.LogType>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Writer<Optional<A>,ProducedType.LogType>>) -> AnyProducer<Writer<Optional<A>,ProducedType.LogType>> {
		return flatMapT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Writer.init(Optional.none))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Writer<Optional<A>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Optional<A>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: OptionalType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: ResultType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Result<A,ProducedType.ElementType.ErrorType>,ProducedType.LogType>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Writer<Result<A,ProducedType.ElementType.ErrorType>,ProducedType.LogType>>) -> AnyProducer<Writer<Result<A,ProducedType.ElementType.ErrorType>,ProducedType.LogType>> {
		return flatMapT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Writer.init(Result.failure($0)))) },
				ifCancel: { AnyProducer.init(Fixed.init(Writer.init(Result.cancel))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Writer<Result<A,T.ProducedType.ElementType.ErrorType>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Result<A,T.ProducedType.ElementType.ErrorType>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: ResultType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: WriterType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Writer<A,ProducedType.ElementType.LogType>,ProducedType.LogType>> {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Writer<Writer<A,ProducedType.ElementType.LogType>,ProducedType.LogType>>) -> AnyProducer<Writer<Writer<A,ProducedType.ElementType.LogType>,ProducedType.LogType>> {
		return flatMapT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Writer<Writer<A,T.ProducedType.ElementType.LogType>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Writer<A,T.ProducedType.ElementType.LogType>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: WriterType {
	return object.flatMapTT(transform)
}



extension Producer where ProducedType: EffectType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Effect<Effect<A>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Effect<Effect<A>>>>) -> AnyProducer<Effect<Effect<Effect<A>>>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Effect<Effect<A>>>>) -> AnyProducer<Effect<Effect<Effect<A>>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Effect<Optional<A>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Effect<Optional<A>>>>) -> AnyProducer<Effect<Effect<Optional<A>>>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Effect.init(Effect.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Effect<Optional<A>>>>) -> AnyProducer<Effect<Effect<Optional<A>>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Effect<Result<A,ProducedType.ElementType.ElementType.ErrorType>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Effect<Result<A,ProducedType.ElementType.ElementType.ErrorType>>>>) -> AnyProducer<Effect<Effect<Result<A,ProducedType.ElementType.ElementType.ErrorType>>>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Effect.init(Effect.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Effect.init(Effect.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Effect<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>>>) -> AnyProducer<Effect<Effect<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Effect<Writer<A,ProducedType.ElementType.ElementType.LogType>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Effect<Writer<A,ProducedType.ElementType.ElementType.LogType>>>>) -> AnyProducer<Effect<Effect<Writer<A,ProducedType.ElementType.ElementType.LogType>>>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Effect<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>>>) -> AnyProducer<Effect<Effect<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Optional<Effect<A>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Optional<Effect<A>>>>) -> AnyProducer<Effect<Optional<Effect<A>>>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Optional<Effect<A>>>>) -> AnyProducer<Effect<Optional<Effect<A>>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Optional<Optional<A>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Optional<Optional<A>>>>) -> AnyProducer<Effect<Optional<Optional<A>>>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Effect.init(Optional.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Optional<Optional<A>>>>) -> AnyProducer<Effect<Optional<Optional<A>>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Optional<Result<A,ProducedType.ElementType.ElementType.ErrorType>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Optional<Result<A,ProducedType.ElementType.ElementType.ErrorType>>>>) -> AnyProducer<Effect<Optional<Result<A,ProducedType.ElementType.ElementType.ErrorType>>>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Effect.init(Optional.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Effect.init(Optional.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Optional<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>>>) -> AnyProducer<Effect<Optional<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Optional<Writer<A,ProducedType.ElementType.ElementType.LogType>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Optional<Writer<A,ProducedType.ElementType.ElementType.LogType>>>>) -> AnyProducer<Effect<Optional<Writer<A,ProducedType.ElementType.ElementType.LogType>>>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Optional<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>>>) -> AnyProducer<Effect<Optional<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Result<Effect<A>,ProducedType.ElementType.ErrorType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Result<Effect<A>,ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Effect<Result<Effect<A>,ProducedType.ElementType.ErrorType>>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Result<Effect<A>,T.ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Effect<Result<Effect<A>,T.ProducedType.ElementType.ErrorType>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Result<Optional<A>,ProducedType.ElementType.ErrorType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Result<Optional<A>,ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Effect<Result<Optional<A>,ProducedType.ElementType.ErrorType>>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Effect.init(Result.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Result<Optional<A>,T.ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Effect<Result<Optional<A>,T.ProducedType.ElementType.ErrorType>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Result<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.ErrorType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Result<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Effect<Result<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.ErrorType>>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Effect.init(Result.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Effect.init(Result.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Result<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Effect<Result<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.ErrorType>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Result<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.ErrorType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Result<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Effect<Result<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.ErrorType>>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Result<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Effect<Result<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.ErrorType>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Writer<Effect<A>,ProducedType.ElementType.LogType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Writer<Effect<A>,ProducedType.ElementType.LogType>>>) -> AnyProducer<Effect<Writer<Effect<A>,ProducedType.ElementType.LogType>>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Writer<Effect<A>,T.ProducedType.ElementType.LogType>>>) -> AnyProducer<Effect<Writer<Effect<A>,T.ProducedType.ElementType.LogType>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Writer<Optional<A>,ProducedType.ElementType.LogType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Writer<Optional<A>,ProducedType.ElementType.LogType>>>) -> AnyProducer<Effect<Writer<Optional<A>,ProducedType.ElementType.LogType>>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Effect.init(Writer.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Writer<Optional<A>,T.ProducedType.ElementType.LogType>>>) -> AnyProducer<Effect<Writer<Optional<A>,T.ProducedType.ElementType.LogType>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Writer<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.LogType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Writer<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.LogType>>>) -> AnyProducer<Effect<Writer<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.LogType>>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Effect.init(Writer.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Effect.init(Writer.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Writer<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.LogType>>>) -> AnyProducer<Effect<Writer<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.LogType>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Effect<Writer<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.LogType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Writer<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.LogType>>>) -> AnyProducer<Effect<Writer<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.LogType>>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Effect<Writer<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.LogType>>>) -> AnyProducer<Effect<Writer<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.LogType>>> where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Effect<Effect<A>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Effect<Effect<A>>>>) -> AnyProducer<Optional<Effect<Effect<A>>>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Effect<Effect<A>>>>) -> AnyProducer<Optional<Effect<Effect<A>>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Effect<Optional<A>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Effect<Optional<A>>>>) -> AnyProducer<Optional<Effect<Optional<A>>>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Optional.init(Effect.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Effect<Optional<A>>>>) -> AnyProducer<Optional<Effect<Optional<A>>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Effect<Result<A,ProducedType.ElementType.ElementType.ErrorType>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Effect<Result<A,ProducedType.ElementType.ElementType.ErrorType>>>>) -> AnyProducer<Optional<Effect<Result<A,ProducedType.ElementType.ElementType.ErrorType>>>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Optional.init(Effect.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Optional.init(Effect.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Effect<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>>>) -> AnyProducer<Optional<Effect<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Effect<Writer<A,ProducedType.ElementType.ElementType.LogType>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Effect<Writer<A,ProducedType.ElementType.ElementType.LogType>>>>) -> AnyProducer<Optional<Effect<Writer<A,ProducedType.ElementType.ElementType.LogType>>>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Effect<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>>>) -> AnyProducer<Optional<Effect<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Optional<Effect<A>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Optional<Effect<A>>>>) -> AnyProducer<Optional<Optional<Effect<A>>>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Optional<Effect<A>>>>) -> AnyProducer<Optional<Optional<Effect<A>>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Optional<Optional<A>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Optional<Optional<A>>>>) -> AnyProducer<Optional<Optional<Optional<A>>>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Optional.init(Optional.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Optional<Optional<A>>>>) -> AnyProducer<Optional<Optional<Optional<A>>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Optional<Result<A,ProducedType.ElementType.ElementType.ErrorType>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Optional<Result<A,ProducedType.ElementType.ElementType.ErrorType>>>>) -> AnyProducer<Optional<Optional<Result<A,ProducedType.ElementType.ElementType.ErrorType>>>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Optional.init(Optional.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Optional.init(Optional.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Optional<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>>>) -> AnyProducer<Optional<Optional<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Optional<Writer<A,ProducedType.ElementType.ElementType.LogType>>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Optional<Writer<A,ProducedType.ElementType.ElementType.LogType>>>>) -> AnyProducer<Optional<Optional<Writer<A,ProducedType.ElementType.ElementType.LogType>>>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Optional<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>>>) -> AnyProducer<Optional<Optional<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Result<Effect<A>,ProducedType.ElementType.ErrorType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Result<Effect<A>,ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Optional<Result<Effect<A>,ProducedType.ElementType.ErrorType>>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Result<Effect<A>,T.ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Optional<Result<Effect<A>,T.ProducedType.ElementType.ErrorType>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Result<Optional<A>,ProducedType.ElementType.ErrorType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Result<Optional<A>,ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Optional<Result<Optional<A>,ProducedType.ElementType.ErrorType>>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Optional.init(Result.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Result<Optional<A>,T.ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Optional<Result<Optional<A>,T.ProducedType.ElementType.ErrorType>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Result<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.ErrorType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Result<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Optional<Result<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.ErrorType>>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Optional.init(Result.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Optional.init(Result.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Result<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Optional<Result<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.ErrorType>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Result<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.ErrorType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Result<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Optional<Result<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.ErrorType>>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Result<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.ErrorType>>>) -> AnyProducer<Optional<Result<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.ErrorType>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Writer<Effect<A>,ProducedType.ElementType.LogType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Writer<Effect<A>,ProducedType.ElementType.LogType>>>) -> AnyProducer<Optional<Writer<Effect<A>,ProducedType.ElementType.LogType>>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Writer<Effect<A>,T.ProducedType.ElementType.LogType>>>) -> AnyProducer<Optional<Writer<Effect<A>,T.ProducedType.ElementType.LogType>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Writer<Optional<A>,ProducedType.ElementType.LogType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Writer<Optional<A>,ProducedType.ElementType.LogType>>>) -> AnyProducer<Optional<Writer<Optional<A>,ProducedType.ElementType.LogType>>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Optional.init(Writer.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Writer<Optional<A>,T.ProducedType.ElementType.LogType>>>) -> AnyProducer<Optional<Writer<Optional<A>,T.ProducedType.ElementType.LogType>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Writer<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.LogType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Writer<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.LogType>>>) -> AnyProducer<Optional<Writer<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.LogType>>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Optional.init(Writer.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Optional.init(Writer.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Writer<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.LogType>>>) -> AnyProducer<Optional<Writer<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.LogType>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Optional<Writer<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.LogType>>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Writer<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.LogType>>>) -> AnyProducer<Optional<Writer<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.LogType>>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Optional<Writer<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.LogType>>>) -> AnyProducer<Optional<Writer<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.LogType>>> where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Effect<Effect<A>>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Effect<Effect<A>>,ProducedType.ErrorType>>) -> AnyProducer<Result<Effect<Effect<A>>,ProducedType.ErrorType>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Effect<Effect<A>>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Effect<Effect<A>>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Effect<Optional<A>>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Effect<Optional<A>>,ProducedType.ErrorType>>) -> AnyProducer<Result<Effect<Optional<A>>,ProducedType.ErrorType>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Result.init(Effect.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Effect<Optional<A>>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Effect<Optional<A>>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Effect<Result<A,ProducedType.ElementType.ElementType.ErrorType>>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Effect<Result<A,ProducedType.ElementType.ElementType.ErrorType>>,ProducedType.ErrorType>>) -> AnyProducer<Result<Effect<Result<A,ProducedType.ElementType.ElementType.ErrorType>>,ProducedType.ErrorType>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Result.init(Effect.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Result.init(Effect.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Effect<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Effect<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Effect<Writer<A,ProducedType.ElementType.ElementType.LogType>>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Effect<Writer<A,ProducedType.ElementType.ElementType.LogType>>,ProducedType.ErrorType>>) -> AnyProducer<Result<Effect<Writer<A,ProducedType.ElementType.ElementType.LogType>>,ProducedType.ErrorType>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Effect<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Effect<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Optional<Effect<A>>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Optional<Effect<A>>,ProducedType.ErrorType>>) -> AnyProducer<Result<Optional<Effect<A>>,ProducedType.ErrorType>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Optional<Effect<A>>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Optional<Effect<A>>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Optional<Optional<A>>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Optional<Optional<A>>,ProducedType.ErrorType>>) -> AnyProducer<Result<Optional<Optional<A>>,ProducedType.ErrorType>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Result.init(Optional.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Optional<Optional<A>>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Optional<Optional<A>>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Optional<Result<A,ProducedType.ElementType.ElementType.ErrorType>>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Optional<Result<A,ProducedType.ElementType.ElementType.ErrorType>>,ProducedType.ErrorType>>) -> AnyProducer<Result<Optional<Result<A,ProducedType.ElementType.ElementType.ErrorType>>,ProducedType.ErrorType>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Result.init(Optional.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Result.init(Optional.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Optional<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Optional<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Optional<Writer<A,ProducedType.ElementType.ElementType.LogType>>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Optional<Writer<A,ProducedType.ElementType.ElementType.LogType>>,ProducedType.ErrorType>>) -> AnyProducer<Result<Optional<Writer<A,ProducedType.ElementType.ElementType.LogType>>,ProducedType.ErrorType>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Optional<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Optional<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Result<Effect<A>,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Result<Effect<A>,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>>) -> AnyProducer<Result<Result<Effect<A>,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Result<Effect<A>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Result<Effect<A>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Result<Optional<A>,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Result<Optional<A>,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>>) -> AnyProducer<Result<Result<Optional<A>,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Result.init(Result.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Result<Optional<A>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Result<Optional<A>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Result<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Result<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>>) -> AnyProducer<Result<Result<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Result.init(Result.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Result.init(Result.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Result<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Result<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Result<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Result<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>>) -> AnyProducer<Result<Result<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.ErrorType>,ProducedType.ErrorType>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Result<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Result<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Writer<Effect<A>,ProducedType.ElementType.LogType>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Writer<Effect<A>,ProducedType.ElementType.LogType>,ProducedType.ErrorType>>) -> AnyProducer<Result<Writer<Effect<A>,ProducedType.ElementType.LogType>,ProducedType.ErrorType>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Writer<Effect<A>,T.ProducedType.ElementType.LogType>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Writer<Effect<A>,T.ProducedType.ElementType.LogType>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Writer<Optional<A>,ProducedType.ElementType.LogType>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Writer<Optional<A>,ProducedType.ElementType.LogType>,ProducedType.ErrorType>>) -> AnyProducer<Result<Writer<Optional<A>,ProducedType.ElementType.LogType>,ProducedType.ErrorType>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Result.init(Writer.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Writer<Optional<A>,T.ProducedType.ElementType.LogType>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Writer<Optional<A>,T.ProducedType.ElementType.LogType>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Writer<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.LogType>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Writer<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.LogType>,ProducedType.ErrorType>>) -> AnyProducer<Result<Writer<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.LogType>,ProducedType.ErrorType>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Result.init(Writer.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Result.init(Writer.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Writer<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.LogType>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Writer<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.LogType>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Result<Writer<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.LogType>,ProducedType.ErrorType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Writer<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.LogType>,ProducedType.ErrorType>>) -> AnyProducer<Result<Writer<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.LogType>,ProducedType.ErrorType>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Result<Writer<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.LogType>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Writer<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.LogType>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Effect<Effect<A>>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Effect<Effect<A>>,ProducedType.LogType>>) -> AnyProducer<Writer<Effect<Effect<A>>,ProducedType.LogType>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Effect<Effect<A>>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Effect<Effect<A>>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Effect<Optional<A>>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Effect<Optional<A>>,ProducedType.LogType>>) -> AnyProducer<Writer<Effect<Optional<A>>,ProducedType.LogType>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Writer.init(Effect.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Effect<Optional<A>>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Effect<Optional<A>>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Effect<Result<A,ProducedType.ElementType.ElementType.ErrorType>>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Effect<Result<A,ProducedType.ElementType.ElementType.ErrorType>>,ProducedType.LogType>>) -> AnyProducer<Writer<Effect<Result<A,ProducedType.ElementType.ElementType.ErrorType>>,ProducedType.LogType>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Writer.init(Effect.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Writer.init(Effect.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Effect<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Effect<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Effect<Writer<A,ProducedType.ElementType.ElementType.LogType>>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Effect<Writer<A,ProducedType.ElementType.ElementType.LogType>>,ProducedType.LogType>>) -> AnyProducer<Writer<Effect<Writer<A,ProducedType.ElementType.ElementType.LogType>>,ProducedType.LogType>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Effect<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Effect<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Optional<Effect<A>>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Optional<Effect<A>>,ProducedType.LogType>>) -> AnyProducer<Writer<Optional<Effect<A>>,ProducedType.LogType>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Optional<Effect<A>>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Optional<Effect<A>>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Optional<Optional<A>>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Optional<Optional<A>>,ProducedType.LogType>>) -> AnyProducer<Writer<Optional<Optional<A>>,ProducedType.LogType>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Writer.init(Optional.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Optional<Optional<A>>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Optional<Optional<A>>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Optional<Result<A,ProducedType.ElementType.ElementType.ErrorType>>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Optional<Result<A,ProducedType.ElementType.ElementType.ErrorType>>,ProducedType.LogType>>) -> AnyProducer<Writer<Optional<Result<A,ProducedType.ElementType.ElementType.ErrorType>>,ProducedType.LogType>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Writer.init(Optional.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Writer.init(Optional.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Optional<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Optional<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Optional<Writer<A,ProducedType.ElementType.ElementType.LogType>>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Optional<Writer<A,ProducedType.ElementType.ElementType.LogType>>,ProducedType.LogType>>) -> AnyProducer<Writer<Optional<Writer<A,ProducedType.ElementType.ElementType.LogType>>,ProducedType.LogType>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Optional<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Optional<Writer<A,T.ProducedType.ElementType.ElementType.LogType>>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Result<Effect<A>,ProducedType.ElementType.ErrorType>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Result<Effect<A>,ProducedType.ElementType.ErrorType>,ProducedType.LogType>>) -> AnyProducer<Writer<Result<Effect<A>,ProducedType.ElementType.ErrorType>,ProducedType.LogType>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Result<Effect<A>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Result<Effect<A>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Result<Optional<A>,ProducedType.ElementType.ErrorType>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Result<Optional<A>,ProducedType.ElementType.ErrorType>,ProducedType.LogType>>) -> AnyProducer<Writer<Result<Optional<A>,ProducedType.ElementType.ErrorType>,ProducedType.LogType>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Writer.init(Result.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Result<Optional<A>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Result<Optional<A>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Result<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.ErrorType>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Result<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.ErrorType>,ProducedType.LogType>>) -> AnyProducer<Writer<Result<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.ErrorType>,ProducedType.LogType>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Writer.init(Result.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Writer.init(Result.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Result<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Result<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Result<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.ErrorType>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Result<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.ErrorType>,ProducedType.LogType>>) -> AnyProducer<Writer<Result<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.ErrorType>,ProducedType.LogType>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Result<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Result<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.ErrorType>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Writer<Effect<A>,ProducedType.ElementType.LogType>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Writer<Effect<A>,ProducedType.ElementType.LogType>,ProducedType.LogType>>) -> AnyProducer<Writer<Writer<Effect<A>,ProducedType.ElementType.LogType>,ProducedType.LogType>> {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Writer<Effect<A>,T.ProducedType.ElementType.LogType>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Writer<Effect<A>,T.ProducedType.ElementType.LogType>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: EffectType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Writer<Optional<A>,ProducedType.ElementType.LogType>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Writer<Optional<A>,ProducedType.ElementType.LogType>,ProducedType.LogType>>) -> AnyProducer<Writer<Writer<Optional<A>,ProducedType.ElementType.LogType>,ProducedType.LogType>> {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Writer.init(Writer.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Writer<Optional<A>,T.ProducedType.ElementType.LogType>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Writer<Optional<A>,T.ProducedType.ElementType.LogType>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: OptionalType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Writer<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.LogType>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Writer<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.LogType>,ProducedType.LogType>>) -> AnyProducer<Writer<Writer<Result<A,ProducedType.ElementType.ElementType.ErrorType>,ProducedType.ElementType.LogType>,ProducedType.LogType>> {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Writer.init(Writer.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Writer.init(Writer.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Writer<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.LogType>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Writer<Result<A,T.ProducedType.ElementType.ElementType.ErrorType>,T.ProducedType.ElementType.LogType>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: ResultType {
	return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Writer<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.LogType>,ProducedType.LogType>> {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Writer<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.LogType>,ProducedType.LogType>>) -> AnyProducer<Writer<Writer<Writer<A,ProducedType.ElementType.ElementType.LogType>,ProducedType.ElementType.LogType>,ProducedType.LogType>> {
		return flatMapTT {
			let (oldValue,oldLog) = $0.run
			let newObject = transform(oldValue)
			return newObject.mapTT {
				let (newValue,newLog) = $0.run
				return Writer.init(value: newValue, log: oldLog <> newLog)
			}
			.any
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> AnyProducer<Writer<Writer<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.LogType>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Writer<Writer<A,T.ProducedType.ElementType.ElementType.LogType>,T.ProducedType.ElementType.LogType>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: WriterType {
	return object.flatMapTTT(transform)
}

