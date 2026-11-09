import XCTest

final class BillSplitUITests: XCTestCase {
    @MainActor
    func testCloseBillStartsDisabled() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertFalse(app.buttons["closeBillButton"].isEnabled)
    }

    /// Demo for the workshop: watch the simulator register a purchase and close the bill.
    @MainActor
    func testAddingPurchaseEnablesCloseBill() {
        let app = XCUIApplication()
        app.launch()

        // Go to the purchases tab and wait for the class list to load.
        app.tabBars.buttons["Compras"].tap()
        let addButton = app.buttons["addPurchaseButton"]
        XCTAssertTrue(addButton.wait(for: \.isEnabled, toEqual: true, timeout: 5))
        addButton.tap()

        // Fill in the purchase.
        app.buttons["buyerPicker"].tap()
        app.buttons["Ana"].tap()

        app.buttons["Bebida"].tap()

        let itemField = app.textFields["itemField"]
        itemField.tap()
        itemField.typeText("Refri pra galera")

        let amountField = app.textFields["amountField"]
        amountField.tap()
        amountField.typeText("90")

        app.buttons["savePurchaseButton"].tap()

        // The purchase shows up in the list.
        XCTAssertTrue(app.staticTexts["R$ 90,00"].firstMatch.waitForExistence(timeout: 2))

        // Back to the balance: the bill can be closed now.
        app.tabBars.buttons["Acerto"].tap()
        let closeBill = app.buttons["closeBillButton"]
        XCTAssertTrue(closeBill.isEnabled)
        closeBill.tap()

        // Everyone sends a Pix to Ana.
        XCTAssertTrue(app.staticTexts["Pix pra Ana"].waitForExistence(timeout: 2))
    }
}
