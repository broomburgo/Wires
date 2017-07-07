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

	func testConsumeInterlacing() {
		var values: [Int] = []

		let speaker1 = Speaker<Int>.init()
		let speaker2 = Speaker<Int>.init()
		let speaker3 = Speaker<Int>.init()

		var subwireIndex = 0
		var subbundleIndex = 0

		currentWire = speaker1.consumeInterlacing { value in
			values.append(value)
			subwireIndex += 1
			subbundleIndex += 1
			return WireBundle.init(
				speaker2.consume { value in
					values.append(value)
				},
				speaker3.consume { value in
					values.append(value)
			})
		}

		speaker1.say(1)
		after(0.1) {
			speaker2.say(10)
			speaker3.say(100)
			speaker1.say(2)
			after(0.1) {
				speaker2.say(20)
				speaker3.say(200)
				speaker2.mute()
				speaker2.say(30)
				speaker3.say(300)
				speaker1.say(4)
				after(0.1) {
					speaker2.say(40)
					speaker3.say(400)
					speaker1.say(5)
					speaker1.mute()
					after(0.1) {
						speaker2.say(50)
						speaker3.say(500)
						speaker1.say(6)
					}
				}
			}
		}

		let willListen = expectation(description: "willListen")
		after(0.6) {
			XCTAssertEqual(values, [1,10,100,2,20,20,200,200,300,300,4,40,400,400,400,5])
			willListen.fulfill()
		}
		waitForExpectations(timeout: 1)
	}
}
