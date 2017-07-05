import XCTest
@testable import Wires

class ConnectionsTests: XCTestCase {
	static var allTests = [
		("testWiresConnect", testWiresConnect),
		("testWiresDisconnect", testWiresDisconnect),
		("testConsume", testConsume)
	]

	var currentWire: Wire? = nil

	override func tearDown() {
		super.tearDown()
		currentWire?.disconnect()
        currentWire = nil
	}

	func testWiresConnect() {
		let p = Speaker<Int>.init()

		let sentValue = 42
		let expectedValue = "\(sentValue)"

		let willListenProperly = expectation(description: "willListenProperly")

		let c = Listener<String>.init { (signal) in
			switch signal {
			case .next(let value):
				XCTAssertEqual(value, expectedValue)
				willListenProperly.fulfill()
			case .stop:
				break
			}
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
        let speaker = Speaker<Int>()
        let listener = Listener<Int>(listen : { signal in
            switch signal {
            case .next(let value):
                XCTAssertEqual(value, expectedValue)
				willDisconnectProperly.fulfill()
            case .stop:
                break
            }
        })
        
        currentWire = speaker.connect(to: listener)
        speaker.say(expectedValue)
        after(0.25) {
            self.currentWire?.disconnect()
            speaker.say(42)
        }
        
        waitForExpectations(timeout: 1)
    }

	func testConsume() {
		var values: [Int] = []

		let speaker = Speaker<Int>.init()
		currentWire = speaker.consume { value in
			values.append(value)
		}

		speaker.say(1)
		speaker.say(2)
		speaker.say(3)
		speaker.mute()
		speaker.say(4)
		speaker.say(5)
		speaker.say(6)

		let willListen = expectation(description: "willListen")
		after(0.3) { 
			XCTAssertEqual(values, [1,2,3])
			willListen.fulfill()
		}
		waitForExpectations(timeout: 1)
	}
}
