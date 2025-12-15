import XCTest
@testable import IPAParser
import PlistParser

final class IPAParserTests: XCTestCase {
    var ipaURL: URL!
    
    override func setUpWithError() throws {
        // Locate the resource
        // Bundle.module is available because we added resources to the target in Package.swift
        guard let url = Bundle.module.url(forResource: "Example", withExtension: "ipa") else {
            XCTFail("Example.ipa not found in bundle")
            return
        }
        ipaURL = url
    }
    
    func testInit() throws {
        let parser = try IPAParser(ipaURL: ipaURL)
        XCTAssertNoThrow(try parser.appDirectory())
    }
    
    func testAppDirectoryContainsInfoPList() throws {
        let parser = try IPAParser(ipaURL: ipaURL)
        let appDir = try parser.appDirectory()
        let infoPlist = appDir.appendingPathComponent("Info.plist")
        XCTAssertTrue(FileManager.default.fileExists(atPath: infoPlist.path))
    }
    
    func testBuild() throws {
        let parser = try IPAParser(ipaURL: ipaURL)
        let tempDir = FileManager.default.temporaryDirectory
        let outputIPA = tempDir.appendingPathComponent(UUID().uuidString + ".ipa")
        
        try parser.build(toPath: outputIPA)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputIPA.path))
        
        // Cleanup
        try? FileManager.default.removeItem(at: outputIPA)
    }
    
    func testAppDirectoryWithFlatIPA() throws {
        // Locate the Flat.ipa resource
        guard let url = Bundle.module.url(forResource: "Flat", withExtension: "ipa") else {
            XCTFail("Flat.ipa not found in bundle")
            return
        }
        
        let parser = try IPAParser(ipaURL: url)
        let foundAppDirectory = try parser.appDirectory()
        
        XCTAssertTrue(foundAppDirectory.lastPathComponent == "FlatApp.app", "IPAParser should find 'FlatApp.app' in flat IPA")
        XCTAssertTrue(FileManager.default.fileExists(atPath: foundAppDirectory.appendingPathComponent("Info.plist").path), "Found .app in flat IPA should contain Info.plist")
        
        // Optionally, check if version parsing also works with this flat IPA
        XCTAssertEqual(parser.version(), "1.0", "Should be able to parse version from flat IPA")
    }
    
    func testModifyBundleID() throws {
        let parser = try IPAParser(ipaURL: ipaURL)
        let newBundleID = "com.test.modified"
        
        parser.replace(bundleID: newBundleID)
        
        // verify by checking the file on disk in the unzip directory
        let appDir = try parser.appDirectory()
        let infoPlist = appDir.appendingPathComponent("Info.plist")
        
        // Use PlistParser to read it back
        let plistParser = try PlistParser(url: infoPlist)
        XCTAssertEqual(plistParser.get(keyPath: "CFBundleIdentifier") as? String, newBundleID)
    }
    
    // MARK: - Error & Edge Cases
    
    func testInitWithNonExistentFile() {
        let invalidURL = FileManager.default.temporaryDirectory.appendingPathComponent("NonExistent.ipa")
        
        XCTAssertThrowsError(try IPAParser(ipaURL: invalidURL)) { error in
            guard let ipaError = error as? IPAParserError,
                  case .templateIPANotFound = ipaError else {
                XCTFail("Expected IPAParserError.templateIPANotFound, got \(error)")
                return
            }
        }
    }
    
    func testAppDirectoryNotFound() throws {
        // Use the NoApp.ipa resource
        guard let noAppIpaURL = Bundle.module.url(forResource: "NoApp", withExtension: "ipa") else {
            XCTFail("NoApp.ipa not found in bundle")
            return
        }
        
        let parser = try IPAParser(ipaURL: noAppIpaURL)
        XCTAssertThrowsError(try parser.appDirectory()) { error in
            guard let ipaError = error as? IPAParserError,
                  case .ipaInvalid = ipaError else {
                XCTFail("Expected IPAParserError.ipaInvalid, got \(error)")
                return
            }
        }
    }
    
    func testNoInfoPlistInApp() throws {
        // Locate the NoInfoPlist.ipa resource
        guard let url = Bundle.module.url(forResource: "NoInfoPlist", withExtension: "ipa") else {
            XCTFail("NoInfoPlist.ipa not found in bundle")
            return
        }
        
        // IPAParser 初始化應該成功，因為 .app 資料夾存在
        let parser = try IPAParser(ipaURL: url)
        
        // appDirectory() 應該也能找到 .app 資料夾
        XCTAssertNoThrow(try parser.appDirectory())
        
        // 嘗試獲取版本號，應該為 nil，因為沒有 Info.plist
        XCTAssertNil(parser.version(), "version() should return nil when Info.plist is missing")
    }
    
    func testReplaceBundleIDWithNil() throws {
        let parser = try IPAParser(ipaURL: ipaURL)
        
        // Get original bundle ID
        let appDir = try parser.appDirectory()
        let infoPlist = appDir.appendingPathComponent("Info.plist")
        let originalPlistParser = try PlistParser(url: infoPlist)
        let originalBundleID = originalPlistParser.get(keyPath: "CFBundleIdentifier") as? String
        
        parser.replace(bundleID: nil)
        
        // Read it back and verify it's unchanged
        let newPlistParser = try PlistParser(url: infoPlist)
        XCTAssertEqual(newPlistParser.get(keyPath: "CFBundleIdentifier") as? String, originalBundleID)
    }
}
