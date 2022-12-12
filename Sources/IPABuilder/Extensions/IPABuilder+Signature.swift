import Foundation
import SwiftCLI

extension IPABuilder {
    // 用 新的憑證 跟 profile 重新簽名 IPA
    public func signature(certificationName: String, provisionURL: URL, toDirectory: URL) throws {
        let appDirectory = try self.appDirectory()
        
        // Generate entitllements.plist
        let provision = try Task.capture("/usr/bin/security", arguments: ["cms", "-D", "-i", provisionURL.path], directory: workingDirectory.path)
        guard FileManager.default.createFile(atPath: workingDirectory.appendingPathComponent("provision.plist").path, contents: provision.stdoutData, attributes: nil) else {
            throw IPABuilderError.provisionFailed
        }
        let entitlements = try Task.capture("/usr/libexec/PlistBuddy", arguments: ["-x", "-c", "Print :Entitlements", "provision.plist"], directory: workingDirectory.path)
        guard FileManager.default.createFile(atPath: workingDirectory.appendingPathComponent("entitlements.plist").path, contents: entitlements.stdoutData, attributes: nil) else {
            throw IPABuilderError.entitlementsFailed
        }

        // Remove old code signature
        let codeSignatureDirectory = appDirectory.appendingPathComponent("_CodeSignature")
        try FileManager.default.removeItem(at: codeSignatureDirectory)

        // Replace embedded mobile provisioning profile
        let embeddedProvisionURL = appDirectory.appendingPathComponent("embedded.mobileprovision")
        try FileManager.default.removeItem(at: embeddedProvisionURL)
        try FileManager.default.copyItem(at: provisionURL, to: embeddedProvisionURL)

        // Re-sign Framework/*
        if let frameworks = try? FileManager.default.subpathsOfDirectory(atPath: appDirectory.appendingPathComponent("Frameworks").path).filter({ $0.hasSuffix(".framework") }) {
            try frameworks.forEach({ framework in
                let frameworkPath = appDirectory.appendingPathComponent("Frameworks").appendingPathComponent(framework).path
                try Task.run("/usr/bin/codesign", arguments: ["-f", "-s", certificationName, "--entitlements", "entitlements.plist", frameworkPath], directory: workingDirectory.path)
            })
        }

        // Re-sign app
        try Task.run("/usr/bin/codesign", arguments: ["-f", "-s", certificationName, "--entitlements", "entitlements.plist", appDirectory.path], directory: workingDirectory.path)
        
        // Re-sign for ios 15
        try Task.run("/usr/bin/codesign", arguments: ["-s", certificationName, "-f", "--preserve-metadata", "--generate-entitlement-der", appDirectory.path], directory: workingDirectory.path)
        
        // Re-package
        try build(toDirectory: toDirectory)
    }
}
