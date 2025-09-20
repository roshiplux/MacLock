import XCTest
@testable import AppLock

final class AppLockTests: XCTestCase {
    var appManager: AppLockManager!
    
    override func setUpWithError() throws {
        appManager = AppLockManager()
    }
    
    override func tearDownWithError() throws {
        appManager = nil
    }
    
    func testAddApp() throws {
        let testApp = "TestApp.app"
        appManager.addApp(testApp)
        
        XCTAssertTrue(appManager.lockedApps.contains(testApp))
    }
    
    func testRemoveApp() throws {
        let testApp = "TestApp.app"
        appManager.addApp(testApp)
        appManager.removeApp(testApp)
        
        XCTAssertFalse(appManager.lockedApps.contains(testApp))
    }
    
    func testNoDuplicateApps() throws {
        let testApp = "TestApp.app"
        appManager.addApp(testApp)
        appManager.addApp(testApp)
        
        let count = appManager.lockedApps.filter { $0 == testApp }.count
        XCTAssertEqual(count, 1)
    }
}
