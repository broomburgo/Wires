import XCTest
@testable import Wires

class ProducersTests: XCTestCase {
	static var allTests = [
		("testSpeakerSendSingle", testSpeakerSendSingle),
		("testSpeakerSendMultiple", testSpeakerSendMultiple),
		("testSpeakerStop", testSpeakerStop),
		("testFixed", testFixed),
		("testFixedSequence", testFixedSequence),
		("testFutureAlreadyDone1",testFutureAlreadyDone1),
		("testFutureAlreadyDone2",testFutureAlreadyDone2),
		("testFutureWillDo1",testFutureWillDo1),
		("testFutureWillDo2",testFutureWillDo2),
		("testFutureStartIdempotent",testFutureStartIdempotent)
	]

	func testSpeakerSendSingle(){
		let speaker = Speaker<Int>()

		let expectedValue = 23

		speaker.upon { signal in
			if case .next(let value) = signal {
				XCTAssertEqual(value, expectedValue)
			}
		}

		speaker.say(expectedValue)
	}

	func testSpeakerSendMultiple(){
		let speaker = Speaker<Int>()

		let expectedValue1 = 23
		let expectedValue2 = 24

		var observeOnce = false

		speaker.upon { signal in
			switch (signal, observeOnce) {
			case (.next(let value), false):
				XCTAssertEqual(value, expectedValue1)
				observeOnce = true
			case (.next(let value), true):
				XCTAssertEqual(value, expectedValue2)
			default:
				fatalError()
			}
		}

		speaker.say(expectedValue1)
		speaker.say(expectedValue2)
	}

	func testSpeakerStop() {
		let speaker = Speaker<Int>()

		let expetectedValue1 = 23
		let expetectedValue2 = 24
		let expetectedValue3 = 25

		var observeOnce = false

		speaker.upon { signal in
			switch (signal, observeOnce) {
			case (.next(let value), false):
				XCTAssertEqual(value, expetectedValue1)
				observeOnce = true
			case(.stop, true):
				XCTAssert(true)
			default:
				fatalError()
			}
		}

		speaker.say(expetectedValue1)
		speaker.mute()
		speaker.say(expetectedValue2)
		speaker.say(expetectedValue3)
	}

	func testFixed() {
		let fixed = Fixed.init(42)

		var values: [Int] = []
		fixed.onNext { values.append($0) }
		fixed.onNext { values.append($0) }
		fixed.onNext { values.append($0) }

		let willListen = expectation(description: "willListen")
		after(0.1) { 
			XCTAssertEqual(values, [42,42,42])
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func testFixedSequence() {
		let fixed = Fixed.init([1,2,3])

		var values: [Int] = []
		fixed.uponEach(stopAtEnd: true) { (signal) in
			guard case .next(let value) = signal else { return }
			values.append(value)
		}

		let willListen = expectation(description: "willListen")
		after(0.1) {
			XCTAssertEqual(values, [1,2,3])
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func testFutureAlreadyDone1() {
		let expectedValue = 42

		let future = Future<Int>.init { (done) in
			done(expectedValue)
		}

		XCTAssertNil(future.value)
		var value: Int? = nil
		future.onNext { value = $0 }
		XCTAssertNil(future.value)
		XCTAssertNil(value)
		future.start()
		XCTAssertEqual(future.value, 42)
		XCTAssertNil(value)

		let willListen = expectation(description: "willListen")
		after(0.1) {
			XCTAssertEqual(value, 42)
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func testFutureAlreadyDone2() {
		let expectedValue = 42

		let future = Future<Int>.init { (done) in
			done(expectedValue)
		}

		XCTAssertNil(future.value)
		var value: Int? = nil
		future.start()
		XCTAssertEqual(future.value, 42)
		XCTAssertNil(value)
		future.onNext { value = $0 }
		XCTAssertEqual(future.value, 42)
		XCTAssertNil(value)

		let willListen = expectation(description: "willListen")
		after(0.1) {
			XCTAssertEqual(value, 42)
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func testFutureWillDo1() {
		let expectedValue = 42

		let future = Future<Int>.init { (done) in
			after(0.1) {
				done(expectedValue)
			}
		}

		XCTAssertNil(future.value)
		var value: Int? = nil
		future.onNext { value = $0 }
		XCTAssertNil(future.value)
		future.start()

		let willListen = expectation(description: "willListen")
		after(0.2) {
			XCTAssertEqual(value, 42)
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func testFutureWillDo2() {
		let expectedValue = 42

		let future = Future<Int>.init { (done) in
			after(0.1) {
				done(expectedValue)
			}
		}

		XCTAssertNil(future.value)
		var value: Int? = nil
		future.start()
		XCTAssertNil(future.value)
		future.onNext { value = $0 }

		let willListen = expectation(description: "willListen")
		after(0.2) {
			XCTAssertEqual(value, 42)
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func testFutureStartIdempotent() {
		let expectedValue = 42

		let future = Future<Int>.init { (done) in
			after(0.1) {
				done(expectedValue)
			}
		}

		XCTAssertNil(future.value)

		var value: Int? = nil
		future
			.start()
			.start()
			.start()
			.onNext { value = $0 }

		let willListen = expectation(description: "willListen")
		after(0.2) {
			XCTAssertEqual(value, 42)
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}
}
