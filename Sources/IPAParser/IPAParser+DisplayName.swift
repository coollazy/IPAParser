import PlistParser

public extension IPAParser {
    @discardableResult
    func replace(displayName: String?) -> Self {
        guard let displayName = displayName else {
            return self
        }
        guard let infoPlistURL = try? appDirectory().appendingPathComponent("Info.plist") else {
            print("[ERROR] Can't find Info.plist")
            return self
        }
        
        try? PlistParser(url: infoPlistURL)
            .replace(key: "CFBundleDisplayName", with: displayName)
            .build()
        
        return self
    }
}
