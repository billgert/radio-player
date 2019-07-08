import XCTest
@testable import RadioPlayer

@available(iOS 10.0, *)
final class RadioPlayerTests: XCTestCase {
    func testExample() {
        XCTAssertEqual(RadioPlayer().isPlaying, false)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
