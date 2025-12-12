import XCTest
@testable import PlistParser

final class PlistParserTests: XCTestCase {
    var tempPlistURL: URL!

    override func setUpWithError() throws {
        // Create a temp file
        let tempDir = FileManager.default.temporaryDirectory
        tempPlistURL = tempDir.appendingPathComponent(UUID().uuidString + ".plist")
        
        let initialData: [String: Any] = [
            "SimpleKey": "SimpleValue",
            "Nested": [
                "Key1": "Value1",
                "Deep": [
                    "Key2": "Value2"
                ]
            ],
            "Array": ["A", "B"]
        ]
        
        let data = try PropertyListSerialization.data(fromPropertyList: initialData, format: .xml, options: 0)
        try data.write(to: tempPlistURL)
    }

    override func tearDownWithError() throws {
        if let url = tempPlistURL {
            try? FileManager.default.removeItem(at: url)
        }
    }

    func testRead() throws {
        let parser = try PlistParser(url: tempPlistURL)
        
        XCTAssertEqual(parser.get(keyPath: "SimpleKey") as? String, "SimpleValue")
        XCTAssertEqual(parser.get(keyPath: "Nested.Key1") as? String, "Value1")
        XCTAssertEqual(parser.get(keyPath: "Nested.Deep.Key2") as? String, "Value2")
        XCTAssertNil(parser.get(keyPath: "NonExistent"))
    }

    func testReplace() throws {
        let parser = try PlistParser(url: tempPlistURL)
        
        parser.replace(keyPath: "SimpleKey", with: "NewValue")
        parser.replace(keyPath: "Nested.Key1", with: "NewValue1")
        parser.replace(keyPath: "New.Key", with: "CreatedValue")
        
        XCTAssertEqual(parser.get(keyPath: "SimpleKey") as? String, "NewValue")
        XCTAssertEqual(parser.get(keyPath: "Nested.Key1") as? String, "NewValue1")
        XCTAssertEqual(parser.get(keyPath: "New.Key") as? String, "CreatedValue")
        
        // Verify persistency
        try parser.build()
        
        let newParser = try PlistParser(url: tempPlistURL)
        XCTAssertEqual(newParser.get(keyPath: "SimpleKey") as? String, "NewValue")
        XCTAssertEqual(newParser.get(keyPath: "Nested.Key1") as? String, "NewValue1")
    }
    
    func testRemove() throws {
         let parser = try PlistParser(url: tempPlistURL)
         
         parser.remove(keyPath: "SimpleKey")
         parser.remove(keyPath: "Nested.Deep")
         
         XCTAssertNil(parser.get(keyPath: "SimpleKey"))
         XCTAssertNil(parser.get(keyPath: "Nested.Deep"))
         XCTAssertNotNil(parser.get(keyPath: "Nested.Key1"))
         
         try parser.build()
         let newParser = try PlistParser(url: tempPlistURL)
         XCTAssertNil(newParser.get(keyPath: "SimpleKey"))
    }
    
    // MARK: - Error & Edge Cases
    
    func testInitWithNonExistentFile() {
        let invalidURL = FileManager.default.temporaryDirectory.appendingPathComponent("NonExistent.plist")
        
        XCTAssertThrowsError(try PlistParser(url: invalidURL)) { error in
            guard let plistError = error as? PlistParserError,
                  case .readFailed = plistError else {
                XCTFail("Expected PlistParserError.readFailed, got \(error)")
                return
            }
        }
    }
    
    func testInitWithInvalidFileContent() throws {
        // Create a file that is not a plist
        let invalidURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".txt")
        try "Not a plist".write(to: invalidURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: invalidURL) }
        
        XCTAssertThrowsError(try PlistParser(url: invalidURL)) { error in
            guard let plistError = error as? PlistParserError,
                  case .decodeContentFailed = plistError else {
                XCTFail("Expected PlistParserError.decodeContentFailed, got \(error)")
                return
            }
        }
    }
    
    func testTraverseNonDictionary() throws {
        let parser = try PlistParser(url: tempPlistURL)
        // "SimpleKey" is a String ("SimpleValue"), not a Dict. Trying to go deeper should fail gracefully.
        XCTAssertNil(parser.get(keyPath: "SimpleKey.SubKey"))
    }
}
