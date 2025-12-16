import Foundation
import PlistParser

public extension IPAParser {
    func version() -> String? {
        return try? getPlistParser()?.get(keyPath: "CFBundleShortVersionString") as? String
    }

    func buildNumber() -> String? {
        return try? getPlistParser()?.get(keyPath: "CFBundleVersion") as? String
    }

    @discardableResult
    func replace(version: String?) -> Self {
        do {
            guard let plist = try getPlistParser() else { return self }

            let currentVersion = plist.get(keyPath: "CFBundleShortVersionString") as? String
            guard currentVersion != version else {
                print("⚠️ IPAParser replace version skipped: value is already \(version ?? "nil")")
                return self
            }

            if let newVersion = version {
                plist.replace(keyPath: "CFBundleShortVersionString", with: newVersion)
            } else {
                plist.remove(keyPath: "CFBundleShortVersionString")
            }
            try plist.build()
        } catch {
            print("⚠️ IPAParser Warning: Failed to replace version. Error: \(error.localizedDescription)")
        }
        return self
    }

    @discardableResult
    func replace(buildNumber: String?) -> Self {
        do {
            guard let plist = try getPlistParser() else { return self }

            let currentBuildNumber = plist.get(keyPath: "CFBundleVersion") as? String
            guard currentBuildNumber != buildNumber else {
                print("⚠️ IPAParser replace build number skipped: value is already \(buildNumber ?? "nil")")
                return self
            }

            if let newBuildNumber = buildNumber {
                plist.replace(keyPath: "CFBundleVersion", with: newBuildNumber)
            } else {
                plist.remove(keyPath: "CFBundleVersion")
            }
            try plist.build()
        } catch {
            print("⚠️ IPAParser Warning: Failed to replace build number. Error: \(error.localizedDescription)")
        }
        return self
    }
}
