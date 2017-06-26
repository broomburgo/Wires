import XCTest
@testable import Wires

class TalkerTests: XCTestCase {
    
    func testTalkerSendSingle(){
        let talker = Talker<Int>()
        
        let expectedValue = 23
        
        talker.upon { signal in
            if case .next(let value) = signal {
                XCTAssertEqual(value, expectedValue)
            }
        }
        
        talker.say(expectedValue)
}
    
    func testTalkerSendMultiple(){
        let talker = Talker<Int>()
        
        let expectedValue1 = 23
        let expectedValue2 = 24
        
        var observeOnce = false
        
        talker.upon { signal in
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
        
        talker.say(expectedValue1)
        talker.say(expectedValue2)
    }
    
    func testTalkerStop() {
        let talker = Talker<Int>()
        
        let expetectedValue1 = 23
        let expetectedValue2 = 24
        let expetectedValue3 = 25
        
        var observeOnce = false
        
        talker.upon { signal in
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
        
        talker.say(expetectedValue1)
        talker.mute()
        talker.say(expetectedValue2)
        talker.say(expetectedValue3)
}
    
}
