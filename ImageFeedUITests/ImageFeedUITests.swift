import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Войти"].tap()
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("<login>")
        app.typeText("\t")
        webView.swipeUp()
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("<password>")
        app.typeText("\t")
        webView.swipeUp()
        webView.buttons["Login"].tap()
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        
        let likeButton = tablesQuery.children(matching: .cell).element(boundBy: 1)
        likeButton.buttons["Like"].tap()
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        
        likeButton.buttons["Like"].tap()
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        let backButton = app.buttons["BackButton"]
        backButton.tap()
    }
    
    func testProfile() throws {
        sleep(2)
        app.tabBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["nameLabel"].exists)
        XCTAssertTrue(app.staticTexts["nicknameLabel"].exists)
        
        app.buttons["logoutButton"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
