import Foundation
import IPAParser

do {
    let fromPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("Resources")
        .appendingPathComponent("Example.ipa")
    
    let toPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("output")
        .appendingPathComponent("NewExample.ipa")
    
    // Initialize IPAParser
    let ipaParser = try IPAParser(ipaURL: fromPath)
        .replace(bundleID: "com.newtest.example")
        .replace(displayName: "新IPA")
    
    print("IPA 版本號：\(ipaParser.version() ?? "無法識別版本號")")
    
    // Repackage the previously extracted folder into a new IPA
    try ipaParser.build(toPath: toPath)
    
    print("🟢 Generate new assets.car with new icon successfully!")
}
catch {
    print("error \(error)")
}

