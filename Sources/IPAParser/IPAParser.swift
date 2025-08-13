import Foundation
import ZIPFoundation

/// 將 IPA 解壓縮，並提供 AppDirectory
/// 呼叫 build 重新壓縮成 IPA 到指令路徑
public class IPAParser {
    let ipaURL: URL
    
    public let workingDirectory: URL = FileManager.default.temporaryDirectory
        .appendingPathComponent("IPAParser")
        .appendingPathComponent(UUID().uuidString)
    
    private lazy var unzipDirectoryURL: URL = {
        workingDirectory.appendingPathComponent("unzip")
    }()
    private lazy var zipDirectoryURL: URL = {
        workingDirectory.appendingPathComponent("zip")
    }()
    
    deinit {
        try? FileManager.default.removeItem(atPath: workingDirectory.path)
    }
    
    public init(_ ipaURL: URL) throws {
        self.ipaURL = ipaURL
        guard FileManager.default.fileExists(atPath: ipaURL.path) else {
            throw IPAParserError.templateIPANotFound(ipaURL.path)
        }
        
        if FileManager.default.fileExists(atPath: unzipDirectoryURL.path) == false {
            try FileManager.default.createDirectory(at: unzipDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        try FileManager.default.unzipItem(at: ipaURL, to: unzipDirectoryURL)
    }
    
    /// App資料夾目錄
    public func appDirectory() throws -> URL {
        let paths = try FileManager.default
            .subpathsOfDirectory(atPath: unzipDirectoryURL.path)
            .filter({ $0.hasSuffix(".app") })
        
        guard let appSubPath = paths.first else {
            throw IPAParserError.ipaInvalid
        }
        
        return unzipDirectoryURL.appendingPathComponent(appSubPath)
    }
    
    /// 壓縮成 IPA 到指令路徑
    public func build(toDirectory: URL) throws {
        // 建立暫存檔案路徑及名稱
        let modifiedArchiveFileLocation = zipDirectoryURL
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("ipa")
        
        // 在工作目錄下面，建立 zip 資料夾
        if FileManager.default.fileExists(atPath: zipDirectoryURL.path) == false {
            try FileManager.default.createDirectory(at: zipDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        do {
            let paths = try FileManager.default.contentsOfDirectory(atPath: unzipDirectoryURL.path)
                .map { unzipDirectoryURL.appendingPathComponent($0) }
            try FileManager.default.zipItems(at: paths, to: modifiedArchiveFileLocation)
        } catch {
            throw IPAParserError.zipFailed
        }
        
        // 將暫存檔案複製到指定的位置
        if FileManager.default.fileExists(atPath: toDirectory.deletingLastPathComponent().path) == false {
            try FileManager.default.createDirectory(at: toDirectory.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        }
        try FileManager.default.copyItem(at: modifiedArchiveFileLocation, to: toDirectory)
    }
}
