import XCTest
@testable import IPAParser
import PlistParser

final class IPAParserIconStrictnessTests: XCTestCase {
    var ipaURL: URL!
    var iconURL: URL!
    
    override func setUpWithError() throws {
        guard let url = Bundle.module.url(forResource: "Example", withExtension: "ipa") else {
            XCTFail("Example.ipa not found")
            return
        }
        ipaURL = url
        
        guard let icon = Bundle.module.url(forResource: "test_icon", withExtension: "png") else {
            XCTFail("test_icon.png not found")
            return
        }
        iconURL = icon
    }
    
    func testiPhoneOnlyIPADoesNotGetiPadIcons() throws {
        let parser = try IPAParser(ipaURL: ipaURL)
        let appDir = try parser.appDirectory()
        let infoPlistURL = appDir.appendingPathComponent("Info.plist")
        
        // 1. Setup Info.plist to be iPhone-only (Remove iPad keys if any)
        let plistParser = try PlistParser(url: infoPlistURL)
        plistParser.remove(keyPath: "CFBundleIcons~ipad")
        
        // Ensure CFBundleIcons exists for iPhone
        let iphoneIcons: [String: Any] = [
            "CFBundlePrimaryIcon": [
                "CFBundleIconFiles": ["AppIcon60x60"]
            ]
        ]
        plistParser.replace(keyPath: "CFBundleIcons", with: iphoneIcons)
        try plistParser.build()
        
        // 2. Perform Replacement
        try parser.replace(icon: iconURL)
        
        // 3. Verify
        let updatedPlist = try PlistParser(url: infoPlistURL)
        XCTAssertNotNil(updatedPlist.get(keyPath: "CFBundleIcons"), "iPhone icons should exist")
        XCTAssertNil(updatedPlist.get(keyPath: "CFBundleIcons~ipad"), "iPad icons should NOT be created if they didn't exist")
    }
    
    func testLegacyiPhoneIconsAreReplaced() throws {
        let parser = try IPAParser(ipaURL: ipaURL)
        let appDir = try parser.appDirectory()
        let infoPlistURL = appDir.appendingPathComponent("Info.plist")
        
        // 1. Manually create legacy 1x icon files in the app directory using REAL image data
        // We copy the 1024x1024 test icon to these paths. 
        // The parser logic checks if file exists and is a valid image. 
        // Then it will overwrite it with the NEW icon resized to the target size (e.g. 57x57).
        let fileManager = FileManager.default
        let legacyFiles = ["Icon-57.png", "Icon-29.png"]
        
        // Read the real test icon data
        let testIconData = try Data(contentsOf: iconURL)
        
        for file in legacyFiles {
            let path = appDir.appendingPathComponent(file).path
            fileManager.createFile(atPath: path, contents: testIconData, attributes: nil)
        }
        
        // 2. Setup Info.plist to reference these legacy files
        let plistParser = try PlistParser(url: infoPlistURL)
        let iphoneIcons: [String: Any] = [
            "CFBundlePrimaryIcon": [
                "CFBundleIconFiles": ["Icon-57", "Icon-29", "AppIcon60x60"]
            ]
        ]
        plistParser.replace(keyPath: "CFBundleIcons", with: iphoneIcons)
        try plistParser.build()
        
        // 3. Perform Replacement
        // This should take the input icon (iconURL), resize it to 57x57 and 29x29, 
        // and OVERWRITE the files we just created.
        try parser.replace(icon: iconURL)
        
        // 4. Verify
        for file in legacyFiles {
            let fileURL = appDir.appendingPathComponent(file)
            
            // A. File must exist
            XCTAssertTrue(fileManager.fileExists(atPath: fileURL.path))
            
            // B. Check if it was resized
            // The original file (testIconData) is large (1024x1024). 
            // The replaced file should be small (57x57 or 29x29).
            // We can check file size in bytes as a proxy, or use Image parser if available.
            // A 57x57 PNG is definitely smaller than a 1024x1024 PNG.
            let newData = try Data(contentsOf: fileURL)
            XCTAssertLessThan(newData.count, testIconData.count, "File \(file) should have been resized (replaced)")
        }
        
        // Also verify that Plist entries are preserved
        let updatedPlist = try PlistParser(url: infoPlistURL)
        let files = updatedPlist.get(keyPath: "CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles") as? [String] ?? []
        XCTAssertTrue(files.contains("Icon-57"))
        XCTAssertTrue(files.contains("Icon-29"))
    }
}
