import XCTest
@testable import RadioPlayer

final class RadioPlayerTests: XCTestCase {
    func testExample() {
        XCTAssertEqual(RadioPlayer().isPlaying, false)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
