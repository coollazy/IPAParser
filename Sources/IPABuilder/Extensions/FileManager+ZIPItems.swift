import Foundation
import ZIPFoundation

extension FileManager {
    public func zipItems(at sources: [URL], to destinationURL: URL, shouldKeepParent: Bool = true, compressionMethod: CompressionMethod = .none) throws {
        let fileManager = FileManager()
        
        // 確認要產生壓縮檔案的位置不存在
        guard !fileManager.itemExists(at: destinationURL) else {
            throw CocoaError(.fileWriteFileExists, userInfo: [NSFilePathErrorKey: destinationURL.path])
        }
        guard !sources.isEmpty else {
            throw CocoaError(.fileReadNoSuchFile, userInfo: [NSFilePathErrorKey: "sources can't be empty"])
        }
        
        // 建立 Archive
        let archive = try Archive(url: destinationURL, accessMode: .create)
        
        for source in sources {
            // 判斷是否為資料夾
            if fileManager.directoryExists(atPath: source.path) {
                var subPaths = try self.subpathsOfDirectory(atPath: source.path)
                
                // Enforce an entry for the root directory to preserve its file attributes
                if shouldKeepParent { subPaths.append("") }

                // If the caller wants to keep the parent directory, we use the lastPathComponent of the source URL
                // as common base for all entries (similar to macOS' Archive Utility.app)
                let directoryPrefix = source.lastPathComponent
                for entryPath in subPaths {
                    let finalEntryPath = shouldKeepParent ? directoryPrefix + "/" + entryPath : entryPath
                    let finalBaseURL = shouldKeepParent ? source.deletingLastPathComponent() : source
                    
                    try archive.addEntry(with: finalEntryPath, relativeTo: finalBaseURL, compressionMethod: compressionMethod)
                }
            }
            else {
                guard itemExists(at: source) else {
                    continue
                }
                let baseURL = source.deletingLastPathComponent()
                try archive.addEntry(with: source.lastPathComponent, relativeTo: baseURL, compressionMethod: compressionMethod)
            }
        }
    }
    
    func itemExists(at url: URL) -> Bool {
        return (try? url.checkResourceIsReachable()) == true
    }
}

extension FileManager {
    func directoryExists(atPath path: String) -> Bool {
        var directoryExists = ObjCBool.init(false)
        let fileExists = fileExists(atPath: path, isDirectory: &directoryExists)
        return fileExists && directoryExists.boolValue
    }
}
