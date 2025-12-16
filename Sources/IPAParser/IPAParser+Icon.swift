import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Image
import PlistParser

public extension IPAParser {
    
    /// 替換 App Icon
    /// - Parameter icon: 新 Icon 的 URL (支援本地 file:// 路徑與遠端 http(s):// 路徑)
    /// - Note: 若為遠端 URL，會先下載至暫存區，處理完後自動刪除。
    ///         若過程中發生錯誤 (如下載失敗、找不到檔案)，僅會印出警告，不會拋出錯誤，以維持鏈式呼叫。
    @discardableResult
    func replace(icon: URL) -> Self {
        do {
            // 1. 判斷 URL 類型
            if icon.isFileURL {
                // 本地檔案，直接處理
                guard FileManager.default.fileExists(atPath: icon.path) else {
                    print("⚠️ IPAParser Warning: Input icon not found at path: \(icon.path)")
                    return self
                }
                try replace(localIconURL: icon)
            } else {
                // 遠端檔案，先下載
                let tempIconURL = try downloadIcon(from: icon)
                defer {
                    // 確保暫存檔案被刪除
                    try? FileManager.default.removeItem(at: tempIconURL)
                }
                try replace(localIconURL: tempIconURL)
            }
        } catch {
            print("⚠️ IPAParser Warning: Failed to replace icon. Error: \(error.localizedDescription)")
        }
        return self
    }
    
    /// 替換 App Icon (相容舊 API)
    /// - Parameter iconPath: 新 Icon 的本地檔案路徑
    @discardableResult
    func replace(icon iconPath: String) -> Self {
        let url = URL(fileURLWithPath: iconPath)
        return replace(icon: url)
    }
    
    // MARK: - Core Logic (Private)
    
    private func replace(localIconURL: URL) throws {
        let appDir = try appDirectory()
        let infoPlistURL = appDir.appendingPathComponent("Info.plist")
        let plist = try PlistParser(url: infoPlistURL)
        let sourceImage = try Image(url: localIconURL)
        
        var isPlistModified = false
        
        // 定義標準尺寸表 (Base Size)
        let iphoneStandardSizes: [Double] = [20, 29, 40, 60]
        let ipadStandardSizes: [Double] = [20, 29, 40, 76, 83.5]
        
        // 定義配置路徑結構
        struct ConfigPath {
            let rootKey: String
            let filesKeyPath: String
            let nameKeyPath: String
            let isiPad: Bool
            let standardSizes: [Double]
        }
        
        let paths = [
            ConfigPath(rootKey: "CFBundleIcons",
                       filesKeyPath: "CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles",
                       nameKeyPath: "CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconName",
                       isiPad: false,
                       standardSizes: iphoneStandardSizes),
            ConfigPath(rootKey: "CFBundleIcons~ipad",
                       filesKeyPath: "CFBundleIcons~ipad.CFBundlePrimaryIcon.CFBundleIconFiles",
                       nameKeyPath: "CFBundleIcons~ipad.CFBundlePrimaryIcon.CFBundleIconName",
                       isiPad: true,
                       standardSizes: ipadStandardSizes)
        ]
        
        // 1. 處理主要配置路徑 (iPhone / iPad)
        for path in paths {
            // 檢查該平台配置是否存在
            guard plist.get(keyPath: path.rootKey) != nil else { continue }
            
            // A. 移除 Name 斷開 Assets.car
            if plist.get(keyPath: path.nameKeyPath) != nil {
                plist.remove(keyPath: path.nameKeyPath)
                isPlistModified = true
            }
            
            // 讀取目前的 Files 列表，如果沒有則初始化為空陣列
            var currentFiles = (plist.get(keyPath: path.filesKeyPath) as? [String]) ?? []
            let originalFilesCount = currentFiles.count
            
            // 用來記錄我們這次操作中實際生成了哪些 Prefix，避免重複加入
            var generatedPrefixes: Set<String> = []
            
            // B. 嘗試基於現有列表進行替換 (如果列表是空的，這步會跳過)
            for prefix in currentFiles {
                let generated = try processIconPrefix(prefix, isiPad: path.isiPad, appDir: appDir, sourceImage: sourceImage)
                if generated {
                    generatedPrefixes.insert(prefix)
                }
            }
            
            // C. 如果列表是空的，或者無法從現有名稱解析出足夠的資訊 (例如只有 "AppIcon")
            // 我們啟動「補全計畫」：生成標準尺寸 Icon 並註冊
            let hasValidSizeDefinitions = currentFiles.contains { parseSize(from: $0) != nil }
            
            if !hasValidSizeDefinitions {
                print("ℹ️ IPAParser: No explicit size definitions found for \(path.rootKey). Generating standard icons.")
                
                // 使用一個乾淨的 Base Name，避免跟原本的 "AppIcon" 混淆
                let baseName = "AppIcon"
                
                for size in path.standardSizes {
                    // 格式化名稱，去掉小數點後的零
                    let sizeString = size.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", size) : String(size)
                    let newPrefix = "\(baseName)\(sizeString)x\(sizeString)" // e.g., AppIcon60x60
                    
                    // 生成檔案
                    _ = try processIconPrefix(newPrefix, isiPad: path.isiPad, appDir: appDir, sourceImage: sourceImage, forcedBaseSize: size)
                    
                    // 加入到 Plist 列表
                    if !currentFiles.contains(newPrefix) {
                        currentFiles.append(newPrefix)
                    }
                }
            }
            
            // D. 如果 Files 列表有變動，寫回 Plist
            if currentFiles.count != originalFilesCount {
                plist.replace(keyPath: path.filesKeyPath, with: currentFiles)
                isPlistModified = true
            }
        }
        
        // 2. 處理 Legacy Key (CFBundleIconFiles)
        if let legacyFiles = plist.get(keyPath: "CFBundleIconFiles") as? [String] {
            for prefix in legacyFiles {
                _ = try processIconPrefix(prefix, isiPad: false, appDir: appDir, sourceImage: sourceImage)
            }
        }
        
        // 3. 儲存 Plist
        if isPlistModified {
            try plist.build()
        }
    }
    
    /// 處理單個 Icon Prefix：尋找檔案覆蓋，或生成新檔案
    @discardableResult
    private func processIconPrefix(_ prefix: String, isiPad: Bool, appDir: URL, sourceImage: Image, forcedBaseSize: Double? = nil) throws -> Bool {
        var processed = false
        let scales = isiPad ? [1, 2] : [2, 3]
        
        for scale in scales {
            let suffix = isiPad ? "~ipad" : ""
            let scaleString = scale > 1 ? "@\(scale)x" : ""
            let fileName = "\(prefix)\(scaleString)\(suffix).png"
            let fileURL = appDir.appendingPathComponent(fileName)
            
            var targetSize: CGSize?
            
            // 1. 優先：檔案存在 -> 讀取實際尺寸
            if FileManager.default.fileExists(atPath: fileURL.path),
               let existingSize = try? Image(url: fileURL).size, existingSize.width > 0 {
                targetSize = existingSize
            }
            // 2. 次之：強制指定尺寸 (來自標準表生成)
            else if let forced = forcedBaseSize {
                let pixel = forced * Double(scale)
                targetSize = CGSize(width: pixel, height: pixel)
            }
            // 3. 最後：嘗試從名稱解析
            else if let parsed = parseSize(from: prefix) {
                let pixel = parsed * Double(scale)
                targetSize = CGSize(width: pixel, height: pixel)
            }
            
            // 執行寫入
            if let size = targetSize {
                try resizeAndWrite(source: sourceImage, to: fileURL, size: size)
                processed = true
            }
        }
        return processed
    }
    
    private func resizeAndWrite(source: Image, to url: URL, size: CGSize) throws {
        let resized = try source.resize(to: size)
        try resized.data.write(to: url)
    }
    
    private func parseSize(from name: String) -> Double? {
        let pattern = "([0-9]+(\\.[0-9]+)?)x[0-9]+"
        if let range = name.range(of: pattern, options: .regularExpression) {
             let match = String(name[range])
             let numberPart = match.split(separator: "x").first
             return Double(String(numberPart ?? ""))
        }
        
        let legacyPattern = "[-_]([0-9]+(\\.[0-9]+)?)$"
        if let range = name.range(of: legacyPattern, options: .regularExpression) {
            let match = String(name[range])
            let numberString = match.dropFirst()
            return Double(String(numberString))
        }
        return nil
    }
    
    // MARK: - Download Helper
    
    private func downloadIcon(from url: URL) throws -> URL {
        let semaphore = DispatchSemaphore(value: 0)
        var resultURL: URL?
        var resultError: Error?
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30 // 30秒超時
        config.timeoutIntervalForResource = 60
        let session = URLSession(configuration: config)
        
        let task = session.downloadTask(with: url) { location, response, error in
            defer { semaphore.signal() }
            
            if let error = error {
                resultError = error
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                resultError = IPAParserError.custom("Invalid response for icon download.")
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                resultError = IPAParserError.custom("Failed to download icon. HTTP Status: \(httpResponse.statusCode)")
                return
            }
            
            guard let location = location else {
                resultError = IPAParserError.custom("Download succeeded but file location is nil.")
                return
            }
            
            // 將暫存檔移到我們可控的位置
            let tempDir = FileManager.default.temporaryDirectory
            let targetURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
            
            do {
                try FileManager.default.moveItem(at: location, to: targetURL)
                resultURL = targetURL
            } catch {
                resultError = error
            }
        }
        
        task.resume()
        semaphore.wait()
        
        if let error = resultError {
            throw error
        }
        
        guard let url = resultURL else {
            throw IPAParserError.custom("Unknown error during icon download.")
        }
        
        return url
    }
    
    private struct IconEntry {
        let prefix: String
        let isiPad: Bool
    }
}
