import Foundation

public extension IPABuilder {
    func version() -> String? {
        guard let infoPlistURL = try? appDirectory().appendingPathComponent("Info.plist") else {
            return nil
        }
        guard let plistData = try? Data(contentsOf: infoPlistURL) else {
            return nil
        }
        guard let plistInfos = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            return nil
        }
        return plistInfos["CFBundleShortVersionString"] as? String
    }
}
