import XCTest
import tesults

public class TesultsXCTestObserver : NSObject, XCTestObservation {
    private var target: String? = nil
    private var cases : [Dictionary<String, Any>] = []
    private var buildName: String? = nil
    private var buildDesc: String? = nil
    private var buildResult: String? = nil
    private var buildReason: String? = nil
    private var failures: Dictionary<Int, [XCTIssue]> = [:]
    private var expectedFailures: Dictionary<Int, [XCTExpectedFailure]> = [:]
    private var startTimes: Dictionary<Int, TimeInterval> = [:]
    private static var files: Dictionary<Int, [String]> = [:]
    
    public init(target: String?, buildName: String? = nil, buildDescription: String? = nil, buildResult: String? = nil, buildReason: String? = nil) {
        self.target = target
        self.buildName = buildName
        self.buildDesc = buildDescription
        self.buildResult = buildResult
        self.buildReason = buildReason
        super.init()
    }
    
    public static func file(testCase: XCTestCase, path: String) {
        if (files[testCase.hash] == nil) {
            files[testCase.hash] = [path]
        } else {
            files[testCase.hash]?.append(path)
        }
    }
    
    private func extractSuite (rawSuite: String) -> String {
        return rawSuite.substringAfter(".")
    }
    
    private func extractName (rawName: String) -> String {
        // get the name and remove the class name and what comes before the class name
        var ret = rawName.substringBefore("]")
        ret = ret.substringAfter("[")
        ret = ret.substringAfter(" ")
        ret = ret.substringAfter("test")
        return ret
    }
    
    public func testCaseWillStart(_ testCase: XCTestCase) {
        startTimes[testCase.hash] = Date().timeIntervalSince1970*1000
    }
    
    public func testCase(_ testCase: XCTestCase, didRecord issue: XCTIssue) {
        if failures[testCase.hash] == nil {
            failures[testCase.hash] = [issue]
        } else {
            failures[testCase.hash]?.append(issue)
        }
    }
    
    public func testCase(_ testCase: XCTestCase, didRecord expectedFailure: XCTExpectedFailure) {
        if expectedFailures[testCase.hash] == nil {
            expectedFailures[testCase.hash] = [expectedFailure]
        } else {
            expectedFailures[testCase.hash]?.append(expectedFailure)
        }
    }
    
    public func testCaseDidFinish(_ testCaseRaw: XCTestCase) {
        var testCase = Dictionary<String, Any>()
        testCase["suite"] = extractSuite(rawSuite: testCaseRaw.className)
        testCase["name"] = extractName(rawName: testCaseRaw.name)
        testCase["desc"] = testCaseRaw.description
        testCase["_Raw Suite"] = testCaseRaw.className
        testCase["result"] = "unknown"
        
        var reasons : [String] = []
        var files: [String] = []
        
        let statFiles = TesultsXCTestObserver.files
        if (statFiles[testCaseRaw.hash] != nil) {
            for file in statFiles[testCaseRaw.hash]! {
                files.append(file)
            }
        }
        
        if let run = testCaseRaw.testRun {
            testCase["result"] = run.hasSucceeded ? "pass" : "fail"
            if (run.hasBeenSkipped) {
                testCase["result"] = "unknown"
            }
            
            testCase["duration"] = run.testDuration * 1000
            
            if run.failureCount > 0 {
                if let issues = failures[testCaseRaw.hash] {
                    for issue in issues {
                        if let value = issue.detailedDescription {
                            reasons.append(value)
                        } else {
                            reasons.append(issue.description)
                        }
                    }
                }
            }
        }
        testCase["start"] = startTimes[testCaseRaw.hash]
        testCase["end"] = (Date().timeIntervalSince1970) * 1000
        
        if (reasons.count > 0) {
            testCase["reason"] = reasons
        }
        
        if (files.count > 0) {
            testCase["files"] = files
        }
        // No params property because XCTest does not support parameterized tests.
        // No steps property because XCTest does not support steps.
        cases.append(testCase)
    }
    
    public func testBundleDidFinish(_ testBundle: Bundle) {
        // Build data
        if (self.buildName != nil) {
            var buildCase = Dictionary<String, Any>()
            buildCase["suite"] = "[build]"
            buildCase["name"] = self.buildName
            if (self.buildDesc != nil) {
                buildCase["desc"] = self.buildDesc
            }
            if (self.buildReason != nil) {
                buildCase["reason"] = self.buildReason
            }
            if (self.buildResult != nil) {
                if (self.buildResult?.lowercased() != "pass" && self.buildResult?.lowercased() != "fail") {
                    buildCase["result"] = "unknown"
                } else {
                    buildCase["result"] = self.buildResult?.lowercased()
                }
            } else {
                buildCase["result"] = "unknown"
            }
            self.cases.append(buildCase)
        }
        
        var data = Dictionary<String, Any>()
        data["target"] = target
        data["results"] = ["cases" : cases]
        
        print (data)
        print("Tesults results upload...")
        
        // Temporary work around until XCTestObservation protocol is updated for async/await
        let dataCaptured = data
        let exp = XCTestCase().expectation(description: "upload")
        Task {
            let resultsResponse = await Tesults().results(data: dataCaptured)
            print("Success: \(resultsResponse.success)")
            print("Message: \(resultsResponse.message)")
            print("Warnings: \(resultsResponse.warnings.count)")
            print("Errors: \(resultsResponse.errors.count)")
            exp.fulfill()
        }
        XCTestCase().wait(for: [exp], timeout: 3600)
    }
}
