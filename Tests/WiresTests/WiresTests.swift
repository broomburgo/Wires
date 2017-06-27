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
}
