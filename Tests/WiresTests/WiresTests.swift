import XCTest
@testable import Wires
import Foundation

class WiresTests: XCTestCase {
	var currentWire: Wire? = nil

	override func tearDown() {
		super.tearDown()
		currentWire?.disconnect()
        currentWire = nil
	}

	func testWiresConnect() {
		let p = Talker<Int>.init()

		let sentValue = 42
		let expectedValue = "\(sentValue)"

		let willListenProperly = expectation(description: "willListenProperly")

		let c = Listener<String>.init { (signal) in
			switch signal {
			case .next(let value):
				XCTAssertEqual(value, expectedValue)
			case .stop:
				XCTFail()
			}
			willListenProperly.fulfill()
		}

		currentWire = p
			.map { "\($0)"}
			.connect(to: c)

		p.say(sentValue)

		waitForExpectations(timeout: 1)
	}
    
    func testWiresDisconnect() {
        let expectedValue = 23
        let willDisconnectProperly = expectation(description: "willDisconnectProperly")
        let talker = Talker<Int>()
        let listener = Listener<Int>(listen : { signal in
            switch signal {
            case .next(let value):
                XCTAssertEqual(value, expectedValue)
            case .stop:
                XCTFail()
            }
            willDisconnectProperly.fulfill()
        })
        
        currentWire = talker.connect(to: listener)
        talker.say(expectedValue)
        DispatchQueue.main.after(0.25) {
            self.currentWire?.disconnect()
            talker.say(42)
        }
        
        waitForExpectations(timeout: 1)
    }

	func testConsume() {
		var values: [Int] = []

		let talker = Talker<Int>.init()
		currentWire = talker.consume { value in
			values.append(value)
		}

		talker.say(1)
		talker.say(2)
		talker.say(3)
		talker.mute()
		talker.say(4)
		talker.say(5)
		talker.say(6)

		let willListen = expectation(description: "willListen")
		DispatchQueue.main.after(0.3) { 
			XCTAssertEqual(values, [1,2,3])
			willListen.fulfill()
		}
		waitForExpectations(timeout: 1)
	}
}
