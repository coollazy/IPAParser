import XCTest
@testable import IPAParser
import PlistParser

final class IPAParseriPadIconTests: XCTestCase {
    var ipaURL: URL!
    var iconURL: URL!
    
    override func setUpWithError() throws {
        // Locate the resource
        guard let url = Bundle.module.url(forResource: "Example", withExtension: "ipa") else {
            XCTFail("Example.ipa not found in bundle")
            return
        }
        ipaURL = url
        
        guard let icon = Bundle.module.url(forResource: "test_icon", withExtension: "png") else {
            XCTFail("test_icon.png not found")
            return
        }
        iconURL = icon
    }
    
    func testReplaceIconWithiPadSupport() throws {
        let parser = try IPAParser(ipaURL: ipaURL)
        let appDir = try parser.appDirectory()
        let infoPlistURL = appDir.appendingPathComponent("Info.plist")
        
        // 1. Manually inject iPad Icon Configuration into Info.plist
        // Before replacing, we simulate an existing iPad configuration
        let plistParser = try PlistParser(url: infoPlistURL)
        
        let ipadIconsDict: [String: Any] = [
            "CFBundlePrimaryIcon": [
                "CFBundleIconFiles": [
                    "AppIcon60x60",
                    "AppIcon76x76"
                ],
                "CFBundleIconName": "AppIcon" // Simulate Assets.car usage
            ]
        ]
        
        plistParser.replace(keyPath: "CFBundleIcons~ipad", with: ipadIconsDict)
        try plistParser.build()
        
        // 2. Perform Icon Replacement
        try parser.replace(icon: iconURL)
        
        // 3. Verify Changes
        
        // Reload Plist
        let updatedPlist = try PlistParser(url: infoPlistURL)
        
        // A. Verify Name is removed (to detach Assets.car)
        XCTAssertNil(updatedPlist.get(keyPath: "CFBundleIcons~ipad.CFBundlePrimaryIcon.CFBundleIconName"), "CFBundleIconName for iPad should be removed")
        
        // B. Verify Files are preserved/updated
        guard let ipadFiles = updatedPlist.get(keyPath: "CFBundleIcons~ipad.CFBundlePrimaryIcon.CFBundleIconFiles") as? [String] else {
            XCTFail("CFBundleIconFiles for iPad missing")
            return
        }
        
        XCTAssertTrue(ipadFiles.contains("AppIcon60x60"))
        XCTAssertTrue(ipadFiles.contains("AppIcon76x76"))
        
        // C. Verify Physical Files Generated with ~ipad suffix
        // Code logic: for iPad, scales are [1, 2]
        // Suffix is ~ipad
        // Filename: {prefix}{scale}{suffix}.png
        
        let expectedFiles = [
            "AppIcon60x60~ipad.png",       // Scale 1
            "AppIcon60x60@2x~ipad.png",    // Scale 2
            "AppIcon76x76~ipad.png",
            "AppIcon76x76@2x~ipad.png"
        ]
        
        for fileName in expectedFiles {
            let fileURL = appDir.appendingPathComponent(fileName)
            XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path), "Expected iPad icon file not found: \(fileName)")
            
            // Optional: Verify size (if we trust Image library)
            // But existence is primary check here
        }
    }
    
    func testReplaceIconGeneratesiPadStandardSizesWhenMissing() throws {
        let parser = try IPAParser(ipaURL: ipaURL)
        let appDir = try parser.appDirectory()
        let infoPlistURL = appDir.appendingPathComponent("Info.plist")
        
        // 1. Inject Empty/Partial iPad Configuration
        // Providing the Root Key "CFBundleIcons~ipad" is enough to trigger the processor,
        // but let's leave files empty to trigger "auto-generation"
        let plistParser = try PlistParser(url: infoPlistURL)
        let ipadIconsDict: [String: Any] = [
            "CFBundlePrimaryIcon": [
                "CFBundleIconFiles": [] as [String]
            ]
        ]
        plistParser.replace(keyPath: "CFBundleIcons~ipad", with: ipadIconsDict)
        try plistParser.build()
        
        // 2. Perform Replacement
        try parser.replace(icon: iconURL)
        
        // 3. Verify
        let updatedPlist = try PlistParser(url: infoPlistURL)
        guard let ipadFiles = updatedPlist.get(keyPath: "CFBundleIcons~ipad.CFBundlePrimaryIcon.CFBundleIconFiles") as? [String] else {
            XCTFail("CFBundleIconFiles for iPad missing")
            return
        }
        
        // Standard iPad sizes defined in code: 20, 29, 40, 76, 83.5
        // Code generates names like "AppIcon20x20", "AppIcon83.5x83.5"
        
        XCTAssertTrue(ipadFiles.contains("AppIcon20x20"))
        XCTAssertTrue(ipadFiles.contains("AppIcon76x76"))
        XCTAssertTrue(ipadFiles.contains("AppIcon83.5x83.5"))
        
        // Verify files exist
        let expectedFile = appDir.appendingPathComponent("AppIcon76x76~ipad.png")
        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedFile.path))
    }
    
    func testReplaceIconCompletesMissingiPadSizes() throws {
        let parser = try IPAParser(ipaURL: ipaURL)
        let appDir = try parser.appDirectory()
        let infoPlistURL = appDir.appendingPathComponent("Info.plist")
        
        // 1. Inject Partial iPad Configuration (Simulate User Scenario)
        // Only 60x60 and 76x76 are defined
        let plistParser = try PlistParser(url: infoPlistURL)
        let ipadIconsDict: [String: Any] = [
            "CFBundlePrimaryIcon": [
                "CFBundleIconFiles": [
                    "AppIcon60x60",
                    "AppIcon76x76"
                ]
            ]
        ]
        plistParser.replace(keyPath: "CFBundleIcons~ipad", with: ipadIconsDict)
        try plistParser.build()
        
        // 2. Perform Replacement
        try parser.replace(icon: iconURL)
        
        // 3. Verify
        let updatedPlist = try PlistParser(url: infoPlistURL)
        guard let ipadFiles = updatedPlist.get(keyPath: "CFBundleIcons~ipad.CFBundlePrimaryIcon.CFBundleIconFiles") as? [String] else {
            XCTFail("CFBundleIconFiles for iPad missing")
            return
        }
        
        // Should preserve existing
        XCTAssertTrue(ipadFiles.contains("AppIcon60x60"))
        XCTAssertTrue(ipadFiles.contains("AppIcon76x76"))
        
        // Should ADD missing standard sizes: 20, 29, 40, 83.5
        XCTAssertTrue(ipadFiles.contains("AppIcon20x20"), "Should add missing 20x20")
        XCTAssertTrue(ipadFiles.contains("AppIcon29x29"), "Should add missing 29x29")
        XCTAssertTrue(ipadFiles.contains("AppIcon40x40"), "Should add missing 40x40")
        
        // Check 83.5 (The implementation usually formats it as 83.5x83.5)
        XCTAssertTrue(ipadFiles.contains("AppIcon83.5x83.5"), "Should add missing 83.5x83.5")
        
        // Verify file existence for a newly added size
        let newFile = appDir.appendingPathComponent("AppIcon83.5x83.5@2x~ipad.png")
        XCTAssertTrue(FileManager.default.fileExists(atPath: newFile.path), "Should generate physical file for new size")
    }
}
