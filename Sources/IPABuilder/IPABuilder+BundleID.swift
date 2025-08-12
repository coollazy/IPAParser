import PlistBuilder

public extension IPABuilder {
    @discardableResult
    func replace(bundleID: String?) -> Self {
        guard let bundleID = bundleID else {
            return self
        }
        guard let infoPlistURL = try? appDirectory().appendingPathComponent("Info.plist") else {
            print("[ERROR] Can't find Info.plist")
            return self
        }
        
        try? PlistBuilder(url: infoPlistURL)
            .replace(key: "CFBundleIdentifier", with: bundleID)
            .build()
        
        return self
    }
}
