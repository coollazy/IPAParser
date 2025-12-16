import Foundation
import IPAParser

do {
    let fromPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("Resources")
        .appendingPathComponent("Example.ipa")
    
    let toPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("output")
        .appendingPathComponent("NewExample.ipa")
    
    let iconURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("Resources")
        .appendingPathComponent("test_icon.png")
    
    // Initialize IPAParser
    let ipaParser = try IPAParser(ipaURL: fromPath)
    
    print("原始 IPA 版本號：\(ipaParser.version() ?? "N/A")")
    print("原始 IPA Build 號：\(ipaParser.buildNumber() ?? "N/A")")
    print("原始 IPA Bundle ID：\(ipaParser.bundleID() ?? "N/A")")
    print("原始 IPA Display Name：\(ipaParser.displayName() ?? "N/A")")
    print("原始 IPA Executable Name：\(ipaParser.executableName() ?? "N/A")") // 只印出原始值
    
    _ = ipaParser
        .replace(bundleID: "com.newtest.example")
        .replace(displayName: "新IPA")
        .replace(version: "2.0.0")
        .replace(buildNumber: "200")
        .replace(icon: iconURL)
    
    print("修改後 IPA 版本號：\(ipaParser.version() ?? "N/A")")
    print("修改後 IPA Build 號：\(ipaParser.buildNumber() ?? "N/A")")
    print("修改後 IPA Bundle ID：\(ipaParser.bundleID() ?? "N/A")")
    print("修改後 IPA Display Name：\(ipaParser.displayName() ?? "N/A")")
    
    // Repackage the previously extracted folder into a new IPA
    try ipaParser.build(toPath: toPath)
    
    print("Generate new ipa successfully! ✅")
}
catch {
    print("error \(error)")
}

