import XCTest
@testable import Wires

class ListenerTests: XCTestCase {
    
    func testListenerReceive() {
        let expectedValue = 23
        
        let listener = Listener<Int>(listen: { signal in
            switch signal {
            case .next(let value):
                XCTAssertEqual(value, expectedValue)
            case .stop:
                fatalError()
            }
        })
        
        listener.receive(.next(expectedValue))
    }
    
}
