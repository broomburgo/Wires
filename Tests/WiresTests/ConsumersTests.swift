import XCTest
@testable import Wires

class ConsumersTests: XCTestCase {
	static var allTests = [
		("testListener", testListener),
		("testAccumulator", testAccumulator),
		("testSpeakerAsConsumer", testSpeakerAsConsumer)
	]

    func testListener() {
        let expectedValue = 42

		let willListen = expectation(description: "willListen")

        let listener = Listener<Int>(listen: { signal in
            switch signal {
            case .next(let value):
                XCTAssertEqual(value, expectedValue)
				willListen.fulfill()
            case .stop:
                fatalError()
            }
        })
        
        listener.receive(.next(expectedValue))

		waitForExpectations(timeout: 1)
    }

	func testAccumulator() {
		let expectedValue = 42

		let accumulator = Accumulator<Int>.init()

		accumulator.receive(.next(expectedValue))
		accumulator.receive(.next(expectedValue))
		accumulator.receive(.next(expectedValue))

		XCTAssertEqual(accumulator.values, [42,42,42])
	}

	func testSpeakerAsConsumer() {
		let expectedValue = 42
		var value: Int? = nil

		let speaker = Speaker<Int>.init()
		speaker.onNext { value = $0 }

		speaker.receive(.next(expectedValue))

		let willListen = expectation(description: "willListen")
		after(0.1) {
			XCTAssertEqual(value, expectedValue)
			willListen.fulfill()
		}

		waitForExpectations(timeout: 1)
	}
}
