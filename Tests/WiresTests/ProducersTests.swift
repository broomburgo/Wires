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
		("testFutureStartIdempotent",testFutureStartIdempotent),
		("testCombineLatest1",testCombineLatest1),
		("testCombineLatest2",testCombineLatest2),
		("testZip2Producer1",testZip2Producer1),
		("testZip2Producer2",testZip2Producer2),
		("testZip2Producer3",testZip2Producer3),
		("testZip3Producer1",testZip3Producer1),
		("testZip3Producer2",testZip3Producer2)
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
			case (.stop,true):
				break
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
    
    func testCombineLatest1() {
        let speaker1 = Speaker<Int>.init()
        let speaker2 = Speaker<String>.init()
        
        let combined = combineLatest(speaker1, speaker2)
        
        var values = [(Int,String)].init()
        let expectedValues: [(Int,String)] = [
            (0,"0"),
            (1,"0"),
            (1,"1"),
            (1,"2"),
            (1,"3"),
            (2,"3"),
            (3,"3")
        ]
        
        combined.onNext { values.append(($0,$1)) }
        
        speaker1.say(0)
        speaker2.say("0")
        speaker1.say(1)
        speaker2.say("1")
        speaker2.say("2")
        speaker2.say("3")
        speaker1.say(2)
        speaker1.say(3)
        
        let willListen = expectation(description: "willListen")
        after(0.1) {
            XCTAssertEqual(values.count, expectedValues.count)
            for (value1,value2) in zip(values, expectedValues) {
                XCTAssert(value1 == value2)
            }
            willListen.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }

	func testCombineLatest2() {
		let speaker1 = Speaker<Int>.init()
		let speaker2 = Speaker<String>.init()

		let combined = combineLatest(speaker1, speaker2)

		var values = [(Int,String)].init()
		let expectedValues: [(Int,String)] = [
			(0,"0"),
			(1,"0"),
			(1,"1"),
			(1,"2")
		]

		combined.onNext { values.append(($0,$1)) }

		speaker1.say(0)
		speaker2.say("0")
		speaker1.say(1)
		speaker2.say("1")
		speaker2.say("2")
		speaker2.mute()
		speaker2.say("3")
		speaker1.say(2)
		speaker1.say(3)

		let willListen = expectation(description: "willListen")
		after(0.1) {
			XCTAssertEqual(values.count, expectedValues.count)
			for (value1,value2) in zip(values, expectedValues) {
				XCTAssert(value1 == value2)
			}
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func testZip2Producer1() {
		let speaker1 = Speaker<Int>.init()
		let speaker2 = Speaker<String>.init()

		let zipped = zip(speaker1, speaker2)

		var values = [(Int,String)].init()
		let expectedValues: [(Int,String)] = [
			(0,"0"),
			(1,"1"),
			(2,"2"),
			(3,"3")
		]

		zipped.onNext { values.append(($0,$1)) }

		speaker1.say(0)
		speaker1.say(1)
		speaker2.say("0")
		speaker1.say(2)
		speaker2.say("1")
		speaker2.say("2")
		speaker1.say(3)
		speaker2.say("3")
		speaker1.say(3)
		speaker1.say(3)

		let willListen = expectation(description: "willListen")
		after(0.1) {
			XCTAssertEqual(values.count, expectedValues.count)
			for (value1,value2) in zip(values, expectedValues) {
				XCTAssert(value1 == value2)
			}
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func testZip2Producer2() {
		let speaker1 = Speaker<Int>.init()
		let speaker2 = Speaker<String>.init()

		let zipped = zip(speaker1, speaker2)

		var values = [(Int,String)].init()
		let expectedValues: [(Int,String)] = [
			(0,"0"),
			(1,"1"),
			(2,"2"),
			(3,"3"),
			(4,"4"),
			(5,"5"),
			(6,"6"),
			(7,"7")
		]

		zipped.onNext { values.append(($0,$1)) }

		speaker1.say(0)
		speaker1.say(1)
		speaker1.say(2)
		speaker1.say(3)
		speaker2.say("0")
		speaker2.say("1")
		speaker2.say("2")
		speaker1.say(4)
		speaker1.say(5)
		speaker2.say("3")
		speaker2.say("4")
		speaker2.say("5")
		speaker2.say("6")
		speaker1.say(6)
		speaker2.say("7")
		speaker2.say("8")
		speaker2.say("9")
		speaker1.say(7)

		let willListen = expectation(description: "willListen")
		after(0.1) {
			XCTAssertEqual(values.count, expectedValues.count)
			for (value1,value2) in zip(values, expectedValues) {
				XCTAssert(value1 == value2)
			}
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func testZip2Producer3() {
		let speaker1 = Speaker<Int>.init()
		let speaker2 = Speaker<String>.init()

		let zipped = zip(speaker1, speaker2)

		var values = [(Int,String)].init()
		let expectedValues: [(Int,String)] = [
			(0,"0"),
			(1,"1"),
			(2,"2")
		]

		zipped.onNext { values.append(($0,$1)) }

		speaker1.say(0)
		speaker1.say(1)
		speaker2.say("0")
		speaker1.say(2)
		speaker2.say("1")
		speaker2.say("2")
		speaker1.mute()
		speaker1.say(3)
		speaker2.say("3")
		speaker1.say(3)
		speaker1.say(3)

		let willListen = expectation(description: "willListen")
		after(0.1) {
			XCTAssertEqual(values.count, expectedValues.count)
			for (value1,value2) in zip(values, expectedValues) {
				XCTAssert(value1 == value2)
			}
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func testZip3Producer1() {
		let speaker1 = Speaker<Int>.init()
		let speaker2 = Speaker<String>.init()
		let speaker3 = Speaker<Bool>.init()

		let zipped = zip(speaker1, speaker2, speaker3)

		var values = [(Int,String,Bool)].init()
		let expectedValues: [(Int,String,Bool)] = [
			(0,"0",true),
			(1,"1",false),
			(2,"2",false),
			(3,"3",true),
			(4,"4",false),
			(5,"5",true),
			(6,"6",true),
			(7,"7",true)
		]

		zipped.onNext { values.append(($0,$1,$2)) }

		speaker1.say(0)
		speaker1.say(1)
		speaker3.say(true)
		speaker1.say(2)
		speaker1.say(3)
		speaker2.say("0")
		speaker3.say(false)
		speaker2.say("1")
		speaker2.say("2")
		speaker3.say(false)
		speaker1.say(4)
		speaker1.say(5)
		speaker2.say("3")
		speaker2.say("4")
		speaker3.say(true)
		speaker3.say(false)
		speaker2.say("5")
		speaker2.say("6")
		speaker3.say(true)
		speaker1.say(6)
		speaker2.say("7")
		speaker2.say("8")
		speaker3.say(true)
		speaker3.say(true)
		speaker3.say(false)
		speaker2.say("9")
		speaker1.say(7)
		speaker3.say(true)
		speaker3.say(false)

		let willListen = expectation(description: "willListen")
		after(0.1) {
			XCTAssertEqual(values.count, expectedValues.count)
			for (value1,value2) in zip(values, expectedValues) {
				XCTAssert(value1 == value2)
			}
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func testZip3Producer2() {
		let speaker1 = Speaker<Int>.init()
		let speaker2 = Speaker<String>.init()
		let speaker3 = Speaker<Bool>.init()

		let zipped = zip(speaker1, speaker2, speaker3)

		var values = [(Int,String,Bool)].init()
		let expectedValues: [(Int,String,Bool)] = [
			(0,"0",true),
			(1,"1",false),
			(2,"2",false),
			(3,"3",true)
		]

		zipped.onNext { values.append(($0,$1,$2)) }

		speaker1.say(0)
		speaker1.say(1)
		speaker3.say(true)
		speaker1.say(2)
		speaker1.say(3)
		speaker2.say("0")
		speaker3.say(false)
		speaker2.say("1")
		speaker2.say("2")
		speaker3.say(false)
		speaker1.say(4)
		speaker1.say(5)
		speaker2.say("3")
		speaker2.say("4")
		speaker3.say(true)
		speaker3.mute()
		speaker3.say(false)
		speaker2.say("5")
		speaker2.say("6")
		speaker3.say(true)
		speaker1.say(6)
		speaker2.say("7")
		speaker2.say("8")
		speaker3.say(true)
		speaker3.say(true)
		speaker3.say(false)
		speaker2.say("9")
		speaker1.say(7)
		speaker3.say(true)
		speaker3.say(false)

		let willListen = expectation(description: "willListen")
		after(0.1) {
			XCTAssertEqual(values.count, expectedValues.count)
			for (value1,value2) in zip(values, expectedValues) {
				XCTAssert(value1 == value2)
			}
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}
}
