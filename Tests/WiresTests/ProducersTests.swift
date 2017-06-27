@testable import Wires
import XCTest

class ProducersTests: XCTestCase {
    
    var wire: Wire? = nil
    
    override func tearDown() {
        super.tearDown()
        wire?.disconnect()
        wire = nil
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

}
