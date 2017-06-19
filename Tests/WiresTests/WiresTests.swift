import XCTest
@testable import Wires

class WiresTests: XCTestCase {
	var currentWire: Wire? = nil

	override func tearDown() {
		super.tearDown()
		currentWire?.disconnect()
	}

	func testExample() {
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
}
