import Foundation
import PlistParser

public extension IPAParser {
    func version() -> String? {
        guard let infoPlistURL = try? appDirectory().appendingPathComponent("Info.plist") else {
            return nil
        }
        return try? PlistParser(url: infoPlistURL).get(keyPath: "CFBundleShortVersionString") as? String
    }
}
