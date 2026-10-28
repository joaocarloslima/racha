import XCTest

final class BillSplitUITests: XCTestCase {
    @MainActor
    func testCloseBillStartsDisabled() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertFalse(app.buttons["closeBillButton"].isEnabled)
    }
}
