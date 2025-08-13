import PlistParser

public extension IPAParser {
    @discardableResult
    func replace(displayName: String?) -> Self {
        guard let displayName = displayName else {
            return self
        }
        
        do {
            let infoPlistURL = try appDirectory().appendingPathComponent("Info.plist")
            try PlistParser(url: infoPlistURL)
                .replace(keyPath: "CFBundleDisplayName", with: displayName)
                .build()
            
            return self
        }
        catch {
            debugPrint("⚠️⚠️ IPAParser replace displayName failed: \(error.localizedDescription)")
            return self
        }
    }
}
