import PlistParser

public extension IPAParser {
    /// 取得 Bundle ID
    func bundleID() -> String? {
        guard let infoPlistURL = try? appDirectory().appendingPathComponent("Info.plist") else {
            return nil
        }
        return try? PlistParser(url: infoPlistURL).get(keyPath: "CFBundleIdentifier") as? String
    }
    
    @discardableResult
    func replace(bundleID: String?) -> Self {
        guard let bundleID = bundleID else {
            return self
        }
        
        // Check if update is needed
        if let currentBundleID = self.bundleID(), currentBundleID == bundleID {
            debugPrint("⚠️⚠️ IPAParser replace bundleID skipped: value is already \(bundleID)")
            return self
        }
        
        do {
            let infoPlistURL = try appDirectory().appendingPathComponent("Info.plist")
            try PlistParser(url: infoPlistURL)
                .replace(keyPath: "CFBundleIdentifier", with: bundleID)
                .build()
            
            return self
        }
        catch {
            debugPrint("⚠️⚠️ IPAParser replace bundleID failed: \(error.localizedDescription)")
            return self
        }
    }
}
