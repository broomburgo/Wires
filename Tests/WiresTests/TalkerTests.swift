import XCTest
@testable import Wires

class SpeakerTests: XCTestCase {
    
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
    
}
