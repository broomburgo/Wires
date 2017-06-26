@testable import Wires
import XCTest

class ProducersTests: XCTestCase {
    
    var wire: Wire? = nil
    
    override func tearDown() {
        super.tearDown()
        wire?.disconnect()
        wire = nil
    }
    
    func testFilterProducer() {
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
    
}
