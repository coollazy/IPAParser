import Foundation
import PlistParser

public struct QQComponent: IPAComponent {
    let appID: String?
    
    public init(appID: String?) {
        self.appID = appID
    }
    
    public func apply(to context: IPAContext) throws {
        let plistParser = context.plistParser
        
        guard let appID = appID else {
            debugPrint("ℹ️ QQ App ID 為 nil，跳過更新 QQ URL Schemes。")
            return
        }
        
        // 1. 設定 QQAppID (Optional, 為了方便讀取)
        plistParser.replace(keyPath: "QQAppID", with: appID)
        debugPrint("✅ QQAppID 已設定/更新為: \(appID)")

        // 2. 準備 Schemes
        let tencentScheme = "tencent" + appID
        
        var qqScheme: String? = nil
        if let intValue = Int(appID) {
            // 轉換為 16 進位 (小寫)
            let hexValue = String(intValue, radix: 16, uppercase: false)
            // 根據常見慣例，如果是單數長度，前面補0？
            // 您的舊代碼沒有補0邏輯，直接 "qq" + hex。我們照舊。
            // 例如 100 -> 64 -> qq64
            qqScheme = "qq" + hexValue
        } else {
            debugPrint("⚠️ QQ App ID 不是純數字，無法生成 'qq' 開頭的 16 進位 Scheme。")
        }
        
        // 3. 更新 URL Schemes
        var urlTypes = plistParser.get(keyPath: "CFBundleURLTypes") as? [[String: Any]] ?? []
        
        // --- 處理 tencentScheme ---
        updateOrAddScheme(urlTypes: &urlTypes, 
                          prefix: "tencent", 
                          newScheme: tencentScheme, 
                          urlName: "tencent") // Name 僅用於新增時
        
        // --- 處理 qqScheme ---
        if let qqScheme = qqScheme {
            // 這裡比較棘手，因為 "qq" 前綴太短，可能會誤判 (例如 qqmail)。
            // 但在 URL Scheme 語境下，通常 qq[0-9a-f]+ 就是 QQ ID。
            // 我們使用 "qq" 作為前綴來搜尋。
            updateOrAddScheme(urlTypes: &urlTypes, 
                              prefix: "qq", 
                              newScheme: qqScheme, 
                              urlName: "qq") // Name 僅用於新增時
        }
        
        // 4. 寫回 Plist
        plistParser.replace(keyPath: "CFBundleURLTypes", with: urlTypes)
    }
    
    private func updateOrAddScheme(urlTypes: inout [[String: Any]], prefix: String, newScheme: String, urlName: String) {
        var entryFoundAndReplaced = false
        
        for (index, var urlType) in urlTypes.enumerated() {
            if let urlSchemes = urlType["CFBundleURLSchemes"] as? [String],
               urlSchemes.contains(where: { $0.hasPrefix(prefix) }) {
                
                // 找到包含該前綴的 Entry
                // 移除舊的 (符合 prefix 的)，加入新的
                var updatedSchemes = urlSchemes.filter { !$0.hasPrefix(prefix) }
                updatedSchemes.append(newScheme)
                
                urlType["CFBundleURLSchemes"] = updatedSchemes
                urlTypes[index] = urlType
                entryFoundAndReplaced = true
                debugPrint("✅ CFBundleURLTypes 中現有 \(prefix) URL Scheme 已更新為: \(newScheme)")
                
                // 注意：這裡假設一個 Entry 只負責一種 QQ Scheme。
                // 如果使用者的 Plist 把 tencent 和 qq 放在同一個 Entry，這個邏輯可能會把該 Entry 修改兩次（這沒問題）。
                break 
            }
        }
        
        if !entryFoundAndReplaced {
            // 沒找到，新增一個
            let newURLTypeEntry: [String: Any] = [
                "CFBundleTypeRole": "Editor",
                "CFBundleURLName": urlName, // 使用建議的 Name
                "CFBundleURLSchemes": [newScheme]
            ]
            urlTypes.append(newURLTypeEntry)
            debugPrint("ℹ️ 未找到 \(prefix) URL Scheme，已新增: \(newScheme) (Name: \(urlName))")
        }
    }
}
