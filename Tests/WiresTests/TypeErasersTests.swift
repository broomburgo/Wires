import XCTest
@testable import Wires

class TypeErasersTests: XCTestCase {
	static var allTests = [
		("testAnyProducer", testAnyProducer),
		("testAnyConsumer", testAnyConsumer)
	]

	var currentWire: Wire? = nil

	override func tearDown() {
		super.tearDown()
		currentWire?.disconnect()
		currentWire = nil
	}

	func testAnyProducer() {
		let speaker = Speaker<Int>.init()
		let expectedValue = 42

		var value: Int? = nil
		currentWire = speaker.any.consume {
			value = $0
		}
		speaker.say(expectedValue)

		let willConsume = expectation(description: "willConsume")
		after(0.1) { 
			XCTAssertEqual(value, expectedValue)
			willConsume.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

	func testAnyConsumer() {
		let speaker = Speaker<Int>.init()
		let expectedValue = 42

		var value: Int? = nil
		let listener = Listener<Int>.init { (signal) in
			guard case .next(let newValue) = signal else { return }
			value = newValue
		}

		currentWire = speaker.connect(to: listener.any)

		speaker.say(expectedValue)

		let willConsume = expectation(description: "willConsume")
		after(0.1) {
			XCTAssertEqual(value, expectedValue)
			willConsume.fulfill()
		}

		waitForExpectations(timeout: 1)
	}
}
