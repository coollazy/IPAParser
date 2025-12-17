import Foundation
import PlistParser

public extension IPAParser {
    /// 取得 Executable Name (CFBundleExecutable)
    func executableName() -> String? {
        return try? getPlistParser()?.get(keyPath: "CFBundleExecutable") as? String
    }
}
