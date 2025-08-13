import PlistParser

public extension IPAParser {
    @discardableResult
    func replace(bundleID: String?) -> Self {
        guard let bundleID = bundleID else {
            return self
        }
        
        do {
            let infoPlistURL = try appDirectory().appendingPathComponent("Info.plist")
            try PlistParser(url: infoPlistURL)
                .replace(key: "CFBundleIdentifier", with: bundleID)
                .build()
            
            return self
        }
        catch {
            debugPrint("⚠️⚠️ IPAParser replace bundleID failed: \(error.localizedDescription)")
            return self
        }
    }
}
