import Foundation
import ZIPFoundation
import PlistParser

/// 將 IPA 解壓縮，並提供 AppDirectory
/// 呼叫 build 重新壓縮成 IPA 到指令路徑
public class IPAParser {
    let ipaURL: URL
    
    private var _plistParser: PlistParser?
    
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
        do {
            try FileManager.default.removeItem(atPath: workingDirectory.path)
        }
        catch {
            print("⚠️⚠️ IPAParser remove workingDirectory error: \(error)")
        }
    }
    
    public init(ipaURL: URL) throws {
        self.ipaURL = ipaURL
        guard FileManager.default.fileExists(atPath: ipaURL.path) else {
            throw IPAParserError.templateIPANotFound(ipaURL.path)
        }
        
        if FileManager.default.fileExists(atPath: unzipDirectoryURL.path) == false {
            try FileManager.default.createDirectory(at: unzipDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        try FileManager.default.unzipItem(at: ipaURL, to: unzipDirectoryURL)
    }
    
    /// 取得 PlistParser 實例 (Lazy Load)
    public func getPlistParser() throws -> PlistParser? {
        if let parser = _plistParser {
            return parser
        }
        
        let appDir = try appDirectory()
        let infoPlistURL = appDir.appendingPathComponent("Info.plist")
        
        guard FileManager.default.fileExists(atPath: infoPlistURL.path) else {
            return nil
        }
        
        let parser = try PlistParser(url: infoPlistURL)
        _plistParser = parser
        return parser
    }
    
    /// App資料夾目錄
    public func appDirectory() throws -> URL {
        let fileManager = FileManager.default
        
        // 1. 優先策略：檢查 Payload 資料夾 (標準結構)
        let payloadURL = unzipDirectoryURL.appendingPathComponent("Payload")
        var isPayloadDir: ObjCBool = false
        
        // 如果 Payload 存在且是資料夾，就進去找
        if fileManager.fileExists(atPath: payloadURL.path, isDirectory: &isPayloadDir), isPayloadDir.boolValue {
            let contents = try fileManager.contentsOfDirectory(at: payloadURL, includingPropertiesForKeys: nil)
            if let appURL = contents.first(where: { $0.pathExtension == "app" }) {
                return appURL
            }
        }
        
        // 2. 備用策略：檢查根目錄 (非標準結構)
        let rootContents = try fileManager.contentsOfDirectory(at: unzipDirectoryURL, includingPropertiesForKeys: nil)
        if let appURL = rootContents.first(where: { $0.pathExtension == "app" }) {
            return appURL
        }
        
        throw IPAParserError.ipaInvalid
    }
    
    /// 壓縮成 IPA 到指令路徑
    public func build(toPath: URL) throws {
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
        let destinationDir = toPath.deletingLastPathComponent()
        if FileManager.default.fileExists(atPath: destinationDir.path) == false {
            try FileManager.default.createDirectory(at: destinationDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        // 如果目標檔案已存在，先刪除
        if FileManager.default.fileExists(atPath: toPath.path) {
            try FileManager.default.removeItem(at: toPath)
        }
        
        try FileManager.default.copyItem(at: modifiedArchiveFileLocation, to: toPath)
    }
}
