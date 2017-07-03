import XCTest
@testable import WiresTests

XCTMain([
    testCase(ConnectionsTests.allTests),
    testCase(ConsumersTests.allTests),
    testCase(OperatorsTests.allTests),
    testCase(ProducersTests.allTests),
    testCase(TypeErasersTests.allTests)
])
