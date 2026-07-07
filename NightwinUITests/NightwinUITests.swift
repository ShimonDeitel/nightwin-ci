import XCTest

final class NightwinUITests: XCTestCase {
    private var interruptionMonitorToken: NSObjectProtocol?

    override func setUpWithError() throws {
        continueAfterFailure = false
        interruptionMonitorToken = addUIInterruptionMonitor(withDescription: "System alert dismissal") { alert in
            for label in ["Allow", "OK", "Don't Allow", "Cancel"] {
                let button = alert.buttons[label]
                if button.exists {
                    button.tap()
                    return true
                }
            }
            return false
        }
    }

    override func tearDownWithError() throws {
        if let token = interruptionMonitorToken {
            removeUIInterruptionMonitor(token)
        }
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset"]
        app.launch()
        return app
    }

    func testHomeShowsConstellationOnLaunch() throws {
        let app = launchApp()
        let constellation = app.descendants(matching: .any).matching(identifier: "constellationView").firstMatch
        XCTAssertTrue(constellation.waitForExistence(timeout: 12), "Constellation did not appear on launch")
    }

    func testSeedWinsAppear() throws {
        let app = launchApp()
        XCTAssertTrue(app.staticTexts["Went for a walk before it got dark"].waitForExistence(timeout: 12), "Seed win for today did not appear")
    }

    func testLogWinFromHome() throws {
        let app = launchApp()
        let logButton = app.buttons["logWinButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 12))
        logButton.tap()

        let textField = app.textViews["winTextField"].exists ? app.textViews["winTextField"] : app.textFields["winTextField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 12))
        textField.tap()
        textField.typeText("Cooked a real dinner")

        app.buttons["saveWinButton"].tap()

        XCTAssertTrue(app.staticTexts["Cooked a real dinner"].waitForExistence(timeout: 12), "New win did not appear")
    }

    func testEditingTodaysWinUpdatesTonightCard() throws {
        let app = launchApp()
        let logButton = app.buttons["logWinButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 12))
        logButton.tap()

        let textField = app.textViews["winTextField"].exists ? app.textViews["winTextField"] : app.textFields["winTextField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 12))
        // Field is pre-filled with today's existing win; clear and retype.
        textField.tap()
        textField.typeText(" edited")

        app.buttons["saveWinButton"].tap()

        XCTAssertTrue(app.staticTexts["tonightWinText"].waitForExistence(timeout: 12))
    }

    func testDeleteWinFromHistory() throws {
        let app = launchApp()
        let entryText = app.staticTexts["Finally fixed that annoying bug"]
        XCTAssertTrue(entryText.waitForExistence(timeout: 12))

        let deleteButton = app.buttons["deleteWin_Finally fixed that annoying bug"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 12))
        deleteButton.tap()

        XCTAssertFalse(app.staticTexts["Finally fixed that annoying bug"].waitForExistence(timeout: 6), "Win was not deleted")
    }

    func testSettingsShowsStreakStats() throws {
        let app = launchApp()
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Current Streak"].waitForExistence(timeout: 12))
    }

    func testKeyboardDismissesOnTapOutside() throws {
        let app = launchApp()
        let logButton = app.buttons["logWinButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 12))
        logButton.tap()

        let textField = app.textViews["winTextField"].exists ? app.textViews["winTextField"] : app.textFields["winTextField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 12))
        textField.tap()
        textField.typeText("Test")
        XCTAssertTrue(app.keyboards.element.exists)

        app.staticTexts["Tonight's Win"].firstMatch.tap()
        XCTAssertFalse(app.keyboards.element.exists, "Keyboard did not dismiss on tap-outside")
    }
}
