import Foundation
import PlistParser

public struct GoogleComponent: IPAComponent {
    let appKey: String?
    
    public init(appKey: String?) {
        self.appKey = appKey
    }
    
    public func apply(to context: IPAContext) throws {
        let plistParser = context.plistParser
        
        guard let appKey = appKey else {
            debugPrint("⚠️ Google App Key 為 nil，跳過替換操作。")
            return
        }
        
        // 1. 驗證 Google App Key 格式
        guard appKey.isValidGoogleAppKey() else {
            debugPrint("⚠️ \(IPAParserError.invalidGoogleAppKey.description): \(appKey)")
            return 
        }

        // 2. 替換 GIDClientID (頂層鍵)
        plistParser.replace(keyPath: "GIDClientID", with: appKey)
        debugPrint("✅ GIDClientID 已設定/更新為: \(appKey)")

        // 3. 替換 CFBundleURLTypes 中的 URL Scheme
        var urlTypes = plistParser.get(keyPath: "CFBundleURLTypes") as? [[String: Any]] ?? []
        let reversedGoogleAppKey = appKey.reversed(separator: ".")
        let googleSchemePrefix = "com.googleusercontent.apps"
        var entryFoundAndReplaced = false
        
        for (index, var urlType) in urlTypes.enumerated() {
            if let urlSchemes = urlType["CFBundleURLSchemes"] as? [String],
               urlSchemes.contains(where: { $0.hasPrefix(googleSchemePrefix) }) {
                
                // 找到舊的 entry。從現有 schemes 中移除所有舊的 Google Schemes，然後加入新的。
                var updatedSchemes = urlSchemes.filter { !$0.hasPrefix(googleSchemePrefix) }
                updatedSchemes.append(reversedGoogleAppKey)
                urlType["CFBundleURLSchemes"] = updatedSchemes
                urlTypes[index] = urlType // 更新陣列中的字典
                entryFoundAndReplaced = true
                debugPrint("✅ CFBundleURLTypes 中現有 Google URL Scheme 已更新為: \(reversedGoogleAppKey) (並保留其他 Schemes)")
                break // 找到並替換後即可退出迴圈
            }
        }
        
        if !entryFoundAndReplaced {
            // 如果沒有找到符合條件的 entry，則新增一個
            let newURLTypeEntry: [String: Any] = [
                "CFBundleTypeRole": "Editor", // 常見的角色設定，根據需要可調整
                "CFBundleURLSchemes": [reversedGoogleAppKey]
            ]
            urlTypes.append(newURLTypeEntry)
            debugPrint("ℹ️ 未找到以 '\(googleSchemePrefix)' 開頭的 URL Scheme，已新增一個 CFBundleURLTypes 條目: \(reversedGoogleAppKey)")
        }
        
        // 將修改後的 CFBundleURLTypes 寫回 PlistParser
        plistParser.replace(keyPath: "CFBundleURLTypes", with: urlTypes)
    }
}