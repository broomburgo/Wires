//import Abstract
//import Monads
//
//// sourcery: transformer1
//// sourcery: transformer2
//// sourcery: transformer3
//// sourcery: concrete = "Optional"
//extension OptionalType {}
//
//// sourcery: transformer1
//// sourcery: transformer2
//// sourcery: transformer3
//// sourcery: concrete = "Result"
//// sourcery: context = "ErrorType"
//extension ResultType {}
//
//// sourcery: transformer1
//// sourcery: transformer2
//// sourcery: transformer3
//// sourcery: concrete = "Writer"
//// sourcery: context = "LogType"
//extension WriterType {}
//
//// sourcery: transformer1
//// sourcery: transformer2
//// sourcery: transformer3
//// sourcery: concrete = "Effect"
//extension EffectType {}
//
//extension Producer where ProducedType: ResultType, ProducedType.ElementType: WriterType {
//	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Result<Writer<A,ProducedType.ElementType.LogType>,ProducedType.ErrorType>> {
//		return mapT { $0.map(transform) }.any
//	}
//
//	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Result<Writer<A,ProducedType.ElementType.LogType>,ProducedType.ErrorType>>) -> AnyProducer<Result<Writer<A,ProducedType.ElementType.LogType>,ProducedType.ErrorType>> {
//		return flatMapT {
//			let (oldValue,oldLog) = $0.run
//			let newObject = transform(oldValue)
//			return newObject.mapT {
//				let (newValue,newLog) = $0.run
//				return Writer.init(value: newValue, log: oldLog <> newLog)
//				}
//				.any
//			}
//			.any
//	}
//}
//
//public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Result<Writer<A,T.ProducedType.ElementType.LogType>,T.ProducedType.ErrorType>>) -> AnyProducer<Result<Writer<A,T.ProducedType.ElementType.LogType>,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType, T.ProducedType.ElementType: WriterType {
//	return object.flatMapTT(transform)
//}
//
//extension Producer where ProducedType: WriterType, ProducedType.ElementType: ResultType {
//	public func mapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> A) -> AnyProducer<Writer<Result<A,ProducedType.ElementType.ErrorType>,ProducedType.LogType>> {
//		return mapT { $0.map(transform) }.any
//	}
//
//	public func flatMapTT <A> (_ transform: @escaping (ProducedType.ElementType.ElementType) -> AnyProducer<Writer<Result<A,ProducedType.ElementType.ErrorType>,ProducedType.LogType>>) -> AnyProducer<Writer<Result<A,ProducedType.ElementType.ErrorType>,ProducedType.LogType>> {
//		return flatMapT {
//			$0.run(
//				ifSuccess: { transform($0) },
//				ifFailure: { AnyProducer.init(Fixed.init(Writer.init(Result.failure($0)))) },
//				ifCancel: { AnyProducer.init(Fixed.init(Writer.init(Result.cancel))) })
//			}
//			.any
//	}
//}
//
//public func ||>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType.ElementType) -> AnyProducer<Writer<Result<A,T.ProducedType.ElementType.ErrorType>,T.ProducedType.LogType>>) -> AnyProducer<Writer<Result<A,T.ProducedType.ElementType.ErrorType>,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType, T.ProducedType.ElementType: ResultType {
//	return object.flatMapTT(transform)
//}
//
//
//extension Producer where ProducedType: ResultType {
//	public func mapT <A> (_ transform: @escaping (ProducedType.ElementType) -> A) -> AnyProducer<Result<A,ProducedType.ErrorType>> {
//		return map { $0.map(transform) }.any
//	}
//
//	public func flatMapT <A> (_ transform: @escaping (ProducedType.ElementType) -> AnyProducer<Result<A,ProducedType.ErrorType>>) -> AnyProducer<Result<A,ProducedType.ErrorType>> {
//		return flatMap {
//			$0.run(
//				ifSuccess: { transform($0) },
//				ifFailure: { AnyProducer.init(Fixed.init(Result.failure($0))) },
//				ifCancel: { AnyProducer.init(Fixed.init(Result.cancel)) })
//			}
//			.any
//	}
//}
//
//public func |>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType) -> AnyProducer<Result<A,T.ProducedType.ErrorType>>) -> AnyProducer<Result<A,T.ProducedType.ErrorType>> where T: Producer, T.ProducedType: ResultType {
//	return object.flatMapT(transform)
//}
//
//extension Producer where ProducedType: WriterType {
//	public func mapT <A> (_ transform: @escaping (ProducedType.ElementType) -> A) -> AnyProducer<Writer<A,ProducedType.LogType>> {
//		return map { $0.map(transform) }.any
//	}
//
//	public func flatMapT <A> (_ transform: @escaping (ProducedType.ElementType) -> AnyProducer<Writer<A,ProducedType.LogType>>) -> AnyProducer<Writer<A,ProducedType.LogType>> {
//		return flatMap {
//			let (oldValue,oldLog) = $0.run
//			let newObject = transform(oldValue)
//			return newObject.map {
//				let (newValue,newLog) = $0.run
//				return Writer.init(value: newValue, log: oldLog <> newLog)
//				}
//				.any
//			}
//			.any
//	}
//}
//
//public func |>>- <T,A> (_ object: T, _ transform: @escaping (T.ProducedType.ElementType) -> AnyProducer<Writer<A,T.ProducedType.LogType>>) -> AnyProducer<Writer<A,T.ProducedType.LogType>> where T: Producer, T.ProducedType: WriterType {
//	return object.flatMapT(transform)
//}
//
//
//
//
//
//
