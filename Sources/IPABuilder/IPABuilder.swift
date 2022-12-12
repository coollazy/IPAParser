import Foundation
import Zip
import MD5
import SwiftCLI

// 將傳入的 IPA 解壓縮到 appDirectory, 呼叫 build 重新壓縮成 IPA
public class IPABuilder {
    let ipaURL: URL
    public var workingDirectory: URL = FileManager.default.temporaryDirectory.appendingPathComponent("IPABuilder").appendingPathComponent(Date().md5)

    deinit {
        do {
            try FileManager.default.removeItem(atPath: workingDirectory.path)
        } catch let error {
            print("[ERROR] \(error.localizedDescription)")
        }
    }
    
    public init(ipaURL: URL) throws {
        self.ipaURL = ipaURL
        guard FileManager.default.fileExists(atPath: ipaURL.path) else {
            throw IPABuilderError.templateIPANotFound(ipaURL.path)
        }
        
        Zip.addCustomFileExtension("ipa")
        if FileManager.default.fileExists(atPath: workingDirectory.path) == false {
            try FileManager.default.createDirectory(at: workingDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        try Zip.unzipFile(ipaURL, destination: workingDirectory, overwrite: false, password: nil)
    }
    
    public func appDirectory() throws -> URL {
        let paths = try FileManager.default.subpathsOfDirectory(atPath: workingDirectory.path).filter({ $0.hasSuffix(".app") })
        guard let appSubPath = paths.first else {
            throw IPABuilderError.ipaInvalid
        }
        
        return workingDirectory.appendingPathComponent(appSubPath)
    }
    
    public func build(toDirectory: URL) throws {
        let modifiedArchiveFileLocation = workingDirectory.appendingPathComponent(Date().md5).appendingPathExtension("ipa")
        
        // 這裡改用 SwiftCLI 直接呼叫 zip 指令, 因為用 Zip 的壓縮方式，壓出來的檔案無法正常安裝到裝置上。
        do {
            try Task.run("/usr/bin/zip", arguments: ["-qr", modifiedArchiveFileLocation.path, "Payload"], directory: workingDirectory.path)
        } catch {
            throw IPABuilderError.zipFailed
        }
        
        if FileManager.default.fileExists(atPath: toDirectory.deletingLastPathComponent().path) == false {
            try FileManager.default.createDirectory(at: toDirectory.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        }
        try FileManager.default.copyItem(at: modifiedArchiveFileLocation, to: toDirectory)
    }
}
