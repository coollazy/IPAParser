import PlistParser

public extension IPAParser {
    /// 取得 Display Name
    func displayName() -> String? {
        return try? getPlistParser()?.get(keyPath: "CFBundleDisplayName") as? String
    }
    
    @discardableResult
    func replace(displayName: String?) -> Self {
        guard let displayName = displayName else {
            return self
        }
        
        // Check if update is needed
        if let currentDisplayName = self.displayName(), currentDisplayName == displayName {
            debugPrint("⚠️⚠️ IPAParser replace displayName skipped: value is already \(displayName)")
            return self
        }
        
        do {
            if let plist = try getPlistParser() {
                try plist.replace(keyPath: "CFBundleDisplayName", with: displayName).build()
            }
            return self
        }
        catch {
            debugPrint("⚠️⚠️ IPAParser replace displayName failed: \(error.localizedDescription)")
            return self
        }
    }
}
