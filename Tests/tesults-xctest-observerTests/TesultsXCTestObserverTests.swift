import XCTest
@testable import tesults_xctest_observer

final class TesultsXCTestObserverTests: XCTestCase {
    override class func setUp() {
        //super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        XCTestObservationCenter.shared.addTestObserver(TesultsXCTestObserver(target: "token", buildName: "1.0.0", buildDescription: "build description here", buildResult: "pass", buildReason: "Failure reason here"))
    }
    
    func testTest1() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
    
    func testTest2() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
    
    func testTest3() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
}


final class TesultsZOther: XCTestCase {
    
    func testTest4() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
    
    func testTest5() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        TesultsXCTestObserver.file(testCase: self, path: "/full-path/log1.txt")
        XCTAssertEqual("Hello, World", "Hello, World!")
    }
    
    func testTest6() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        TesultsXCTestObserver.file(testCase: self, path: "/full-path/log2.txt")
        TesultsXCTestObserver.file(testCase: self, path: "/full-path/log3.txt")
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
}
