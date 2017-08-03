// Generated using Sourcery 0.7.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT





import Abstract
import Monads


extension Producer where ProducedType: EffectType {
	public func mapT <A> (_ transform: @escaping (ProducedType.ElementType) -> A) ->  {
		return map { $0.map(transform) }.any
	}

	public func flatMapT <A> (_ transform: @escaping (ProducedType.ElementType) -> ) ->  {
		return flatMap {
			transform($0.run())
		}
		.any
	}
}

public func |>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType) -> ) ->  where T: Producer, T.ProducedType:  {
	return object.flatMapT(transform)
}


extension Producer where ProducedType: OptionalType {
	public func mapT <A> (_ transform: @escaping (ProducedType.ElementType) -> A) ->  {
		return map { $0.map(transform) }.any
	}

	public func flatMapT <A> (_ transform: @escaping (ProducedType.ElementType) -> ) ->  {
		return flatMap {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Optional.none)) })
		}
		.any
	}
}

public func |>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType) -> ) ->  where T: Producer, T.ProducedType:  {
	return object.flatMapT(transform)
}


extension Producer where ProducedType: ResultType {
	public func mapT <A> (_ transform: @escaping (ProducedType.ElementType) -> A) ->  {
		return map { $0.map(transform) }.any
	}

	public func flatMapT <A> (_ transform: @escaping (ProducedType.ElementType) -> ) ->  {
		return flatMap {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Result.failure($0))) },
				ifCancel: { AnyProducer.init(Fixed.init(Result.cancel)) })
		}
		.any
	}
}

public func |>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType) -> ) ->  where T: Producer, T.ProducedType:  {
	return object.flatMapT(transform)
}


extension Producer where ProducedType: WriterType {
	public func mapT <A> (_ transform: @escaping (ProducedType.ElementType) -> A) ->  {
		return map { $0.map(transform) }.any
	}

	public func flatMapT <A> (_ transform: @escaping (ProducedType.ElementType) -> ) ->  {
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

public func |>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType) -> ) ->  where T: Producer, T.ProducedType:  {
	return object.flatMapT(transform)
}



extension Producer where ProducedType: EffectType, ProducedType.ElementType: EffectType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapT {
			transform($0.run())
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: EffectType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: OptionalType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Effect.init(Optional.none))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: OptionalType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: ResultType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Effect.init(Result.failure($0)))) },
				ifCancel: { AnyProducer.init(Fixed.init(Effect.init(Result.cancel))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: ResultType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: WriterType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: WriterType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: EffectType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapT {
			transform($0.run())
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: EffectType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: OptionalType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Optional.init(Optional.none))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: OptionalType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: ResultType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Optional.init(Result.failure($0)))) },
				ifCancel: { AnyProducer.init(Fixed.init(Optional.init(Result.cancel))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: ResultType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: WriterType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: WriterType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: EffectType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapT {
			transform($0.run())
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: EffectType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: OptionalType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Result.init(Optional.none))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: OptionalType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: ResultType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Result.init(Result.failure($0)))) },
				ifCancel: { AnyProducer.init(Fixed.init(Result.init(Result.cancel))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: ResultType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: WriterType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: WriterType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: EffectType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapT {
			transform($0.run())
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: EffectType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: OptionalType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Writer.init(Optional.none))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: OptionalType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: ResultType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Writer.init(Result.failure($0)))) },
				ifCancel: { AnyProducer.init(Fixed.init(Writer.init(Result.cancel))) })
		}
		.any
	}
}

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: ResultType {
	return object.flatMapTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: WriterType {
	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) ->  {
		return mapT { $0.map(transform) }.any
	}

	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: WriterType {
	return object.flatMapTT(transform)
}



extension Producer where ProducedType: EffectType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Effect.init(Effect.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Effect.init(Effect.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Effect.init(Effect.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Effect.init(Optional.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Effect.init(Optional.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Effect.init(Optional.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Effect.init(Result.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Effect.init(Result.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Effect.init(Result.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Effect.init(Writer.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Effect.init(Writer.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Effect.init(Writer.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: EffectType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: EffectType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Optional.init(Effect.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Optional.init(Effect.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Optional.init(Effect.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Optional.init(Optional.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Optional.init(Optional.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Optional.init(Optional.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Optional.init(Result.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Optional.init(Result.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Optional.init(Result.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Optional.init(Writer.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Optional.init(Writer.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Optional.init(Writer.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: OptionalType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: OptionalType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Result.init(Effect.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Result.init(Effect.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Result.init(Effect.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Result.init(Optional.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Result.init(Optional.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Result.init(Optional.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Result.init(Result.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Result.init(Result.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Result.init(Result.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Result.init(Writer.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Result.init(Writer.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Result.init(Writer.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: ResultType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Writer.init(Effect.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Writer.init(Effect.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Writer.init(Effect.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: EffectType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: EffectType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Writer.init(Optional.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Writer.init(Optional.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Writer.init(Optional.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: OptionalType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: OptionalType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Writer.init(Result.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Writer.init(Result.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Writer.init(Result.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: ResultType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: ResultType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: EffectType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			transform($0.run())
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: EffectType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: OptionalType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSome: { transform($0) },
				ifNone: { AnyProducer.init(Fixed.init(Writer.init(Writer.init(Optional.none)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: OptionalType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: ResultType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
		return flatMapTT {
			$0.run(
				ifSuccess: { transform($0) },
				ifFailure: { AnyProducer.init(Fixed.init(Writer.init(Writer.init(Result.failure($0))))) },
				ifCancel: { AnyProducer.init(Fixed.init(Writer.init(Writer.init(Result.cancel)))) })
		}
		.any
	}
}

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: ResultType {
return object.flatMapTTT(transform)
}


extension Producer where ProducedType: WriterType, ProducedType.ElementType: WriterType, ProducedType.ElementType.ElementType: WriterType {
	public func mapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType.ElementType) -> A) ->  {
		return mapTT { $0.map(transform) }.any
	}

	public func flatMapTTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> ) ->  {
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

public func |||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType.ElementType) -> ) ->  where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: WriterType, T.ProducedType.ElementType.ElementType: WriterType {
return object.flatMapTTT(transform)
}

