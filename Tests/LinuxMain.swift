import XCTest
@testable import WiresTests

XCTMain([
    testCase(ConnectionsTests.allTests),
    testCase(ConsumersTests.allTests),
    testCase(ProducersTests.allTests),
    testCase(TransformersTests.allTests),
    testCase(TypeErasersTests.allTests)
])
