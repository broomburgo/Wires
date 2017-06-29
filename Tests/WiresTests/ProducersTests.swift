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
        let talker = Talker<Int>()
        
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
        wire = talker.map{ "\($0)" }.connect(to: listener)
        
        talker.say(sentValue1)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testMapSingleCached() {
        let talker = Talker<Int>()
        let cached = talker.cached()
        
        let sentValue1 = 42
        let expectedValue1 = "42"
        let willObserve1 = expectation(description: "willObserve1")
        
        talker.say(sentValue1)
        
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
        let talker = Talker<Int>()
        
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
        
        wire = talker
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
        
        talker.say(sentValue1)
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: FlatMapProduce Tests
    
    func testFlatMapSingle() {
        let talker1 = Talker<Int>()
        var talker2: Talker<String>? = nil
        
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
        
        wire = talker1
            .flatMap { value -> AnyProducer<String> in
                XCTAssertEqual(expectedValue1, value)
                willObserve1.fulfill()
                let newTalker = Talker<String>()
                DispatchQueue.main.after(0.25) { [weak newTalker] in newTalker?.say(expectedValue2) }
                talker2 = newTalker
                XCTAssertNotNil(talker2)
                return AnyProducer<String>.init(newTalker)
            }
            .connect(to: listener)
        
        talker1.say(expectedValue1)
        
        waitForExpectations(timeout: 1)
    }
    
    func testFlatMapMultiple() {
        let talker1 = Talker<Int>()
        var talker2: Talker<String>? = nil
        
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
        
        wire = talker1
            .flatMap { value -> AnyProducer<String> in
                let newTalker = Talker<String>()
                DispatchQueue.main.after(0.25) { [weak newTalker] in newTalker?.say("\(value)") }
                talker2 = newTalker
                XCTAssertNotNil(talker2)
                return AnyProducer<String>.init(newTalker)
            }
            .connect(to: listener)
        
        talker1.say(expectedValue1)
        talker1.say(expectedValue2)
        
        waitForExpectations(timeout: 1)
    }
    
    func testFlatMapMultiple2() {
        let talker1 = Talker<Int>()
        
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
        
        wire = talker1
            .flatMap { value -> AnyProducer<String> in
                let newTalker = Talker<String>()
                DispatchQueue.main.after(0.25) { [weak newTalker] in newTalker?.say("\(value)") }
                return AnyProducer<String>.init(newTalker)
            }
            .connect(to: listener)
        
        talker1.say(expectedValue1)
        talker1.say(expectedValue2)
        
        waitForExpectations(timeout: 1)
    }
    
    func testFlatMapMultiple3() {
        let talker1 = Talker<Int>()
        weak var talker2: Talker<Int>? = nil
        weak var talker3: Talker<Int>? = nil
        
        var array2: [Int] = []
        var array3: [Int] = []
        
        let listener = Listener<Int>.init { signal in }
        
        var observedOnce = false
        
        wire = talker1.flatMap { _ in
            if observedOnce {
                let newTalker = Talker<Int>()
                talker3 = newTalker
                newTalker.upon { signal in
                    switch signal {
                    case .next(let value):
                        array3.append(value)
                    case .stop:
                        break
                    }
                }
                return AnyProducer.init(newTalker)
            } else {
                let newTalker = Talker<Int>()
                talker2 = newTalker
                newTalker.upon { signal in
                    switch signal {
                    case .next(let value):
                        array2.append(value)
                    case .stop:
                        break
                    }
                }
                observedOnce = true
                return AnyProducer.init(newTalker)
            } }
            .connect(to: listener)
        
        talker1.say(1)
        talker1.say(2)
        
        let willObserve = expectation(description: "willObserve")
        
        DispatchQueue.main.after(0.1) {
            talker2?.say(1)
            talker3?.say(1)
            DispatchQueue.main.after(0.1) {
                talker2?.say(2)
                talker3?.mute()
                DispatchQueue.main.after(0.1) {
                    talker2?.say(3)
                    talker3?.say(3)
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
    
//    func testFlatMapMultiple4() {
//        weak var talker1: Talker<Int>? = nil
//        weak var talker2: Talker<Int>? = nil
//        weak var talker3: Talker<Int>? = nil
//        
//        var array1: [Int] = []
//        var array2: [Int] = []
//        var array3: [Int] = []
//        
//        var observedOnce = false
//        
//        var talker: Talker<Int>? = Talker<Int>.init()
//        wire = talker!.flatMap { _ in
//            if observedOnce {
//                let newTalker = Talker<Int>()
//                talker3 = newTalker
//                newTalker.upon { signal in
//                    switch signal {
//                    case .next(let value):
//                        array3.append(value)
//                    case .stop:
//                        break
//                    }
//                }
//                return AnyProducer.init(newTalker)
//            } else {
//                let newTalker = Talker<Int>()
//                talker2 = newTalker
//                newTalker.upon { signal in
//                    switch signal {
//                    case .next(let value):
//                        array2.append(value)
//                    case .stop:
//                        break
//                    }
//                }
//                observedOnce = true
//                return AnyProducer.init(newTalker)
//            } }
//            .connect(to: Listener<Int>.init { [weak self] signal in
//                switch signal {
//                case .next(let value):
//                    array1.append(value)
//                case .stop:
//                    self?.wire?.disconnect()
//                }
//            })
//        
//        talker1 = talker
//        talker = nil
//        
//        talker1!.say(1)
//        talker1!.say(2)
//        
//        let willObserve = expectation(description: "willObserve")
//        
//        DispatchQueue.main.after(0.1) {
//            talker2?.say(1)
//            talker3?.say(1)
//            DispatchQueue.main.after(0.1) {
//                talker2?.say(2)
//                talker3?.mute()
//                DispatchQueue.main.after(0.1) {
//                    talker2?.say(3)
//                    talker3?.say(3)
//                    DispatchQueue.main.after(0.1) {
//                        XCTAssertEqual(array1, [1,1,2])
//                        XCTAssertEqual(array2, [1,2])
//                        XCTAssertEqual(array3, [1])
//                        willObserve.fulfill()
//                    }
//                }
//            }
//        }
//        
//        waitForExpectations(timeout: 1)
//    }
    
    func testFlatMapSingleCached() {
        let talker1 = Talker<Int>()
        
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
        
        wire = talker1
            .cached()
            .flatMap { value -> AnyProducer<String> in
                XCTAssertEqual(value, expectedValue1)
                willObserve1.fulfill()
                let newTalker = Talker<String>()
                DispatchQueue.main.after(0.25) { [weak newTalker] in newTalker?.say("\(value)") }
                return AnyProducer<String>.init(newTalker)
            }
            .connect(to: listener)
        
         talker1.say(expectedValue1)
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: FilterProducer Tests
    
    func testFilter() {
        // Initial settings
        let talker = Talker<Int>()
        
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
        wire = talker.filter { $0 % 2 == 0 }.connect(to: listener)
        
        // Execution
        talker.say(value1)
        talker.say(value2)
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: CachedProducer Tests
    
    func testCached() {
        // Initial settings
        let talker = Talker<Int>()
        
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
        wire = talker.cached().connect(to: listener)
        
        // Execution
        talker.say(expectedValue1)
        talker.say(expectedValue2)
        
        waitForExpectations(timeout: 1)
    }
    
    func testCachedTwice() {
        let talker = Talker<Int>()
        
        let expectedValue = 23
        
        let cached = talker.cached()
        
        talker.say(expectedValue)
        
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
        let talker = Talker<Int>()
        
        let expectedValue1 = 23
        
        let cached = AnyProducer.init(talker.cached())
        
        talker.say(expectedValue1)
        
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
        
        talker.say(expectedValue2)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: MergeProducer Tests
    
    func testMerge() {
        let talker1 = Talker<Int>()
        let talker2 = Talker<Int>()
        
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
        
        wire = talker1.merge(talker2).connect(to: listener)
        
        talker1.say(expectedValue1)
        talker2.say(expectedValue2)
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: DebounceProducer Tests
    
    func testDebounce() {
        let talker = Talker<Int>()
        
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
        
        wire = talker.debounce(0.25).connect(to: listener)
        
        talker.say(unexpectedValue1)
        DispatchQueue.main.after(0.1) {
            talker.say(unexpectedValue2)
            DispatchQueue.main.after(0.1) {
                talker.say(expectedValue1)
                DispatchQueue.main.after(0.3) {
                    talker.say(unexpectedValue3)
                    DispatchQueue.main.after(0.1) {
                        talker.say(unexpectedValue4)
                        DispatchQueue.main.after(0.1) {
                            talker.say(expectedValue2)
                            DispatchQueue.main.after(0.3) {
                                talker.say(unexpectedValue5)
                                DispatchQueue.main.after(0.1) {
                                    talker.say(unexpectedValue6)
                                    DispatchQueue.main.after(0.1) {
                                        talker.say(unexpectedValue7)
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
        let talker = Talker<Int?>()
        
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
        
        wire = talker.mapSome { $0 }.connect(to: listener)
        
        array.forEach(talker.say)
        
        waitForExpectations(timeout: 2)
    }
    
}
