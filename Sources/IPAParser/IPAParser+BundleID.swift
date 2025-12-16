import PlistParser

public extension IPAParser {
    /// 取得 Bundle ID
    func bundleID() -> String? {
        return try? getPlistParser()?.get(keyPath: "CFBundleIdentifier") as? String
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
            if let plist = try getPlistParser() {
                try plist.replace(keyPath: "CFBundleIdentifier", with: bundleID).build()
            }
            return self
        }
        catch {
            debugPrint("⚠️⚠️ IPAParser replace bundleID failed: \(error.localizedDescription)")
            return self
        }
    }
}
