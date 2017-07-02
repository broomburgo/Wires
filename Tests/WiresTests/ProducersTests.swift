@testable import Wires
import XCTest

class ProducersTests: XCTestCase {
    
    var wire: Wire? = nil
    
    override func tearDown() {
        super.tearDown()
        wire?.disconnect()
        wire = nil
    }
    
    // MARK: MapProducer Tests
    
    func testMapSingle() {
        let speaker = Speaker<Int>()
        
        let sentValue1 = 42
        let expectedValue1 = "42"
        let willObserve1 = expectation(description: "willObserve1")
        
        let listener = Listener<String>.init { signal in
            switch signal {
            case .next(let value):
                XCTAssertEqual(value, expectedValue1)
                willObserve1.fulfill()
            case .stop:
                XCTFail()
            }
        }
        wire = speaker.map{ "\($0)" }.connect(to: listener)
        
        speaker.say(sentValue1)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testMapSingleCached() {
        let speaker = Speaker<Int>()
        let cached = speaker.cached()
        
        let sentValue1 = 42
        let expectedValue1 = "42"
        let willObserve1 = expectation(description: "willObserve1")
        
        speaker.say(sentValue1)
        
        let listener = Listener<String>.init { signal in
            switch signal {
            case .next(let value):
                XCTAssertEqual(value, expectedValue1)
                willObserve1.fulfill()
            case .stop:
                XCTFail()
            }
        }
        
        wire = cached.map { "\($0)" }.connect(to: listener)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testMapChained() {
        let speaker = Speaker<Int>()
        
        let sentValue1 = 23
        let expectedValue1 = 46
        let expectedValue2 = "46"
        let willObserve1 = expectation(description: "willObserve1")
        let willObserve2 = expectation(description: "willObserve2")
        
        let listener = Listener<String>.init { signal in
            switch signal {
            case .next(let value):
                XCTAssertEqual(expectedValue2, value)
                willObserve2.fulfill()
            case .stop:
                XCTFail()
            }
        }
        
        wire = speaker
            .map { $0 * 2 }
            .upon { signal in
                switch signal {
                case .next(let value):
                    XCTAssertEqual(expectedValue1, value)
                    willObserve1.fulfill()
                case .stop:
                    XCTFail()
                }
            }
            .map { "\($0)" }
            .connect(to: listener)
        
        speaker.say(sentValue1)
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: FlatMapProduce Tests
    
    func testFlatMapSingle() {
        let speaker1 = Speaker<Int>()
        var speaker2: Speaker<String>? = nil
        
        let expectedValue1 = 42
        let expectedValue2 = "42"
        
        let willObserve1 = expectation(description: "willObserve1")
        let willObserve2 = expectation(description: "willObserve2")
        
        let listener = Listener<String>.init { signal in
            switch signal {
            case .next(let value):
                XCTAssertEqual(expectedValue2, value)
                willObserve2.fulfill()
            case .stop:
                XCTFail()
            }
        }
        
        wire = speaker1
            .flatMap { value -> AnyProducer<String> in
                XCTAssertEqual(expectedValue1, value)
                willObserve1.fulfill()
                let newSpeaker = Speaker<String>()
                DispatchQueue.main.after(0.25) { [weak newSpeaker] in newSpeaker?.say(expectedValue2) }
                speaker2 = newSpeaker
                XCTAssertNotNil(speaker2)
                return AnyProducer<String>.init(newSpeaker)
            }
            .connect(to: listener)
        
        speaker1.say(expectedValue1)
        
        waitForExpectations(timeout: 1)
    }
    
    func testFlatMapMultiple() {
        let speaker1 = Speaker<Int>()
        var speaker2: Speaker<String>? = nil
        
        let expectedValue1 = 42
        let expectedValue2 = 23
        let expectedValue3 = "42"
        let expectedValue4 = "23"
        
        let willObserve1 = expectation(description: "willObserve1")
        let willObserve2 = expectation(description: "willObserve2")
        
        var observedOnce = false
        
        let listener = Listener<String>.init { signal in
            switch signal {
            case .next(let value):
                if observedOnce {
                    XCTAssertEqual(expectedValue4, value)
                    willObserve2.fulfill()
                } else {
                    XCTAssertEqual(expectedValue3, value)
                    willObserve1.fulfill()
                    observedOnce = true
                }
            case .stop:
                XCTFail()
            }
        }
        
        wire = speaker1
            .flatMap { value -> AnyProducer<String> in
                let newSpeaker = Speaker<String>()
                DispatchQueue.main.after(0.25) { [weak newSpeaker] in newSpeaker?.say("\(value)") }
                speaker2 = newSpeaker
                XCTAssertNotNil(speaker2)
                return AnyProducer<String>.init(newSpeaker)
            }
            .connect(to: listener)
        
        speaker1.say(expectedValue1)
        speaker1.say(expectedValue2)
        
        waitForExpectations(timeout: 1)
    }
    
    func testFlatMapMultiple2() {
        let speaker1 = Speaker<Int>()
        
        let expectedValue1 = 42
        let expectedValue2 = 23
        let expectedValue3 = "42"
        let expectedValue4 = "23"
        
        let willObserve1 = expectation(description: "willObserve1")
        let willObserve2 = expectation(description: "willObserve2")
        
        var observedOnce = false
        
        let listener = Listener<String>.init { signal in
            switch signal {
            case .next(let value):
                if observedOnce {
                    XCTAssertEqual(expectedValue4, value)
                    willObserve2.fulfill()
                } else {
                    XCTAssertEqual(expectedValue3, value)
                    willObserve1.fulfill()
                    observedOnce = true
                }
            case .stop:
                XCTFail()
            }
        }
        
        wire = speaker1
            .flatMap { value -> AnyProducer<String> in
                let newSpeaker = Speaker<String>()
                DispatchQueue.main.after(0.25) { [weak newSpeaker] in newSpeaker?.say("\(value)") }
                return AnyProducer<String>.init(newSpeaker)
            }
            .connect(to: listener)
        
        speaker1.say(expectedValue1)
        speaker1.say(expectedValue2)
        
        waitForExpectations(timeout: 1)
    }
    
    func testFlatMapMultiple3() {
        let speaker1 = Speaker<Int>()
        weak var speaker2: Speaker<Int>? = nil
        weak var speaker3: Speaker<Int>? = nil
        
        var array2: [Int] = []
        var array3: [Int] = []
        
        let listener = Listener<Int>.init { signal in }
        
        var observedOnce = false
        
        wire = speaker1.flatMap { _ in
            if observedOnce {
                let newSpeaker = Speaker<Int>()
                speaker3 = newSpeaker
                newSpeaker.upon { signal in
                    switch signal {
                    case .next(let value):
                        array3.append(value)
                    case .stop:
                        break
                    }
                }
                return AnyProducer.init(newSpeaker)
            } else {
                let newSpeaker = Speaker<Int>()
                speaker2 = newSpeaker
                newSpeaker.upon { signal in
                    switch signal {
                    case .next(let value):
                        array2.append(value)
                    case .stop:
                        break
                    }
                }
                observedOnce = true
                return AnyProducer.init(newSpeaker)
            } }
            .connect(to: listener)
        
        speaker1.say(1)
        speaker1.say(2)
        
        let willObserve = expectation(description: "willObserve")
        
        DispatchQueue.main.after(0.1) {
            speaker2?.say(1)
            speaker3?.say(1)
            DispatchQueue.main.after(0.1) {
                speaker2?.say(2)
                speaker3?.mute()
                DispatchQueue.main.after(0.1) {
                    speaker2?.say(3)
                    speaker3?.say(3)
                    DispatchQueue.main.after(0.1) {
                        XCTAssertEqual(array2, [1,2,3])
                        XCTAssertEqual(array3, [1])
                        willObserve.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFlatMapSingleCached() {
        let speaker1 = Speaker<Int>()
        
        let expectedValue1 = 23
        let expectedValue2 = "23"
        
        let willObserve1 = expectation(description: "willObserve1")
        let willObserve2 = expectation(description: "willObserve2")
        
        let listener = Listener<String>.init { signal in
            switch signal {
            case .next(let value):
                XCTAssertEqual(value, expectedValue2)
                willObserve2.fulfill()
            case .stop:
                XCTFail()
            }
        }
        
        wire = speaker1
            .cached()
            .flatMap { value -> AnyProducer<String> in
                XCTAssertEqual(value, expectedValue1)
                willObserve1.fulfill()
                let newSpeaker = Speaker<String>()
                DispatchQueue.main.after(0.25) { [weak newSpeaker] in newSpeaker?.say("\(value)") }
                return AnyProducer<String>.init(newSpeaker)
            }
            .connect(to: listener)
        
         speaker1.say(expectedValue1)
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: FilterProducer Tests
    
    func testFilter() {
        // Initial settings
        let speaker = Speaker<Int>()
        
        let value1 = 23
        let value2 = 42
        
        // Expectation
        let expectedValue = value2
        let willObserve = expectation(description: "willObserve")
        
        let listener = Listener<Int>.init { signal in
            switch signal {
            case .next(let value):
                XCTAssert(value == expectedValue)
                willObserve.fulfill()
            case .stop:
                XCTFail("Something wrong")
            }
        }
        
        // Core functionality
        wire = speaker.filter { $0 % 2 == 0 }.connect(to: listener)
        
        // Execution
        speaker.say(value1)
        speaker.say(value2)
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: CachedProducer Tests
    
    func testCached() {
        // Initial settings
        let speaker = Speaker<Int>()
        
        let expectedValue1 = 23
        let expectedValue2 = 42
        
        var observedOnce = false
        
        // Expectation
        let willObserve1 = expectation(description: "willObserve1")
        let willObserve2 = expectation(description: "willObserve2")
        
        let listener = Listener<Int>.init { signal in
            switch signal {
            case .next(let value):
                if observedOnce {
                    XCTAssert(expectedValue2 == value)
                    willObserve2.fulfill()
                } else {
                    observedOnce = true
                    XCTAssert(expectedValue1 == value)
                    willObserve1.fulfill()
                }
            case .stop:
                XCTFail()
            }
        }
        
        // Core functionality
        wire = speaker.cached().connect(to: listener)
        
        // Execution
        speaker.say(expectedValue1)
        speaker.say(expectedValue2)
        
        waitForExpectations(timeout: 1)
    }
    
    func testCachedTwice() {
        let speaker = Speaker<Int>()
        
        let expectedValue = 23
        
        let cached = speaker.cached()
        
        speaker.say(expectedValue)
        
        let willObserve1 = expectation(description: "willObserve1")
        let willObserve2 = expectation(description: "willObserve2")
        
        cached.upon { signal in
            switch signal {
            case .next(let value):
                XCTAssertEqual(value, expectedValue)
                willObserve1.fulfill()
            case .stop:
                XCTFail()
            }
        }
        
        cached.upon { signal in
            switch signal {
            case .next(let value):
                XCTAssertEqual(value, expectedValue)
                willObserve2.fulfill()
            case .stop:
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCachedAny() {
        let speaker = Speaker<Int>()
        
        let expectedValue1 = 23
        
        let cached = AnyProducer.init(speaker.cached())
        
        speaker.say(expectedValue1)
        
        let willObserve1 = expectation(description: "willObserve1")
        let willObserve2 = expectation(description: "willObserve2")
        
        let expectedValue2 = 42
        
        var observedOnce = false
        
        cached.upon { signal in
            switch signal {
            case .next(let value):
                if observedOnce {
                    XCTAssertEqual(value, expectedValue2)
                    willObserve2.fulfill()
                } else {
                    observedOnce = true
                    XCTAssertEqual(value, expectedValue1)
                    willObserve1.fulfill()
                }
            case .stop:
                XCTFail()
            }
        }
        
        speaker.say(expectedValue2)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: MergeProducer Tests
    
    func testMerge() {
        let speaker1 = Speaker<Int>()
        let speaker2 = Speaker<Int>()
        
        let expectedValue1 = 23
        let expectedValue2 = 42
        
        let willObserve1 = expectation(description: "willObserve1")
        let willObserve2 = expectation(description: "willObserve2")
        
        let listener = Listener<Int>.init{ signal in
            switch signal {
            case .next(let value):
                if value == expectedValue1 {
                    XCTAssertEqual(value, expectedValue1)
                    willObserve1.fulfill()
                } else {
                    XCTAssertEqual(value, expectedValue2)
                    willObserve2.fulfill()
                }
            case .stop:
                XCTFail()
            }
        }
        
        wire = speaker1.merge(speaker2).connect(to: listener)
        
        speaker1.say(expectedValue1)
        speaker2.say(expectedValue2)
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: DebounceProducer Tests
    
    func testDebounce() {
        let speaker = Speaker<Int>()
        
        let unexpectedValue1 = 1
        let unexpectedValue2 = 2
        let expectedValue1 = 3
        let unexpectedValue3 = 4
        let unexpectedValue4 = 5
        let expectedValue2 = 6
        let unexpectedValue5 = 7
        let unexpectedValue6 = 8
        let unexpectedValue7 = 9
        
        let willObserve1 = expectation(description: "willObserve1")
        let willFinish = expectation(description: "willFinish")
        let willObserve2 = expectation(description: "willObserve2")
        var hasObservedOnce = false
        
        let listener = Listener<Int>.init { signal in
            switch signal {
            case .next(let value):
                if hasObservedOnce == false {
                    willObserve1.fulfill()
                    hasObservedOnce = true
                    XCTAssertEqual(value, expectedValue1)
                } else {
                    print("\(value)")
                    willObserve2.fulfill()
                    XCTAssertEqual(value, expectedValue2)
                }
            case .stop:
                XCTFail()
            }
        }
        
        wire = speaker.debounce(0.25).connect(to: listener)
        
        speaker.say(unexpectedValue1)
        DispatchQueue.main.after(0.1) {
            speaker.say(unexpectedValue2)
            DispatchQueue.main.after(0.1) {
                speaker.say(expectedValue1)
                DispatchQueue.main.after(0.3) {
                    speaker.say(unexpectedValue3)
                    DispatchQueue.main.after(0.1) {
                        speaker.say(unexpectedValue4)
                        DispatchQueue.main.after(0.1) {
                            speaker.say(expectedValue2)
                            DispatchQueue.main.after(0.3) {
                                speaker.say(unexpectedValue5)
                                DispatchQueue.main.after(0.1) {
                                    speaker.say(unexpectedValue6)
                                    DispatchQueue.main.after(0.1) {
                                        speaker.say(unexpectedValue7)
                                        DispatchQueue.main.after(0.1) {
                                            willFinish.fulfill()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    // MARK: mapSome Tests
    
    func testMapSome() {
        let speaker = Speaker<Int?>()
        
        let expectedValue1: Int? = 23
        let unexpectedValue: Int? = nil
        
        let willObserve = expectation(description: "willObserve")
        
        let array = [expectedValue1, unexpectedValue]
        
        let listener = Listener<Int>.init { signal in
            switch signal {
            case .next(let value):
                XCTAssert(value == expectedValue1)
                willObserve.fulfill()
            case .stop:
                XCTFail()
            }
        }
        
        wire = speaker.mapSome { $0 }.connect(to: listener)
        
        array.forEach(speaker.say)
        
        waitForExpectations(timeout: 2)
    }


	//MARK: - more stuff

	func testCrash() {
		let speaker = Speaker<Int>()

		let rx_string = speaker.any.map { "\($0)" }

		let willConsume = expectation(description: "willConsume")
		wire = rx_string.consume {
			XCTAssertEqual($0, "42")
			willConsume.fulfill()
		}

		speaker.say(42)

		waitForExpectations(timeout: 1)
	}
}
