import Foundation
import PlistParser

public struct WeChatComponent: IPAComponent {
    let appID: String?
    
    public init(appID: String?) {
        self.appID = appID
    }
    
    public func apply(to context: IPAContext) throws {
        let plistParser = context.plistParser
        
        guard let appID = appID else {
            debugPrint("ℹ️ WeChat App ID 為 nil，跳過更新 URL Scheme。")
            return
        }
        
        updateURLScheme(plistParser: plistParser, appID: appID)
    }
    
    private func updateURLScheme(plistParser: PlistParser, appID: String) {
        var urlTypes = plistParser.get(keyPath: "CFBundleURLTypes") as? [[String: Any]] ?? []
        let wechatScheme = appID // 微信 Scheme 直接就是 AppID (通常以 wx 開頭)
        let urlName = "com.wechat"
        var entryFoundAndReplaced = false
        
        // 策略 1: 根據 CFBundleURLName 尋找
        for (index, var urlType) in urlTypes.enumerated() {
            if let name = urlType["CFBundleURLName"] as? String, name == urlName {
                // 找到了明確標記為 com.wechat 的 Entry
                updateEntry(&urlType, newScheme: wechatScheme)
                urlTypes[index] = urlType
                entryFoundAndReplaced = true
                debugPrint("✅ CFBundleURLTypes 中 Name 為 '\(urlName)' 的 Entry 已更新 Scheme 為: \(wechatScheme)")
                break
            }
        }
        
        // 策略 2: 如果策略 1 沒找到，嘗試尋找包含 'wx' 開頭 Scheme 的 Entry (模糊匹配)
        // 注意：只有在明確沒找到 com.wechat 的情況下才這麼做，避免重複修改
        if !entryFoundAndReplaced {
            for (index, var urlType) in urlTypes.enumerated() {
                if let urlSchemes = urlType["CFBundleURLSchemes"] as? [String],
                   urlSchemes.contains(where: { $0.hasPrefix("wx") }) {
                    
                    // 假設這是舊的微信 Entry
                    updateEntry(&urlType, newScheme: wechatScheme)
                    urlTypes[index] = urlType
                    entryFoundAndReplaced = true
                    debugPrint("✅ CFBundleURLTypes 中發現疑似舊 WeChat Scheme (wx開頭)，已更新為: \(wechatScheme)")
                    break
                }
            }
        }
        
        // 策略 3: 如果都沒找到，新增一個
        if !entryFoundAndReplaced {
            let newURLTypeEntry: [String: Any] = [
                "CFBundleTypeRole": "Editor",
                "CFBundleURLName": urlName,
                "CFBundleURLSchemes": [wechatScheme]
            ]
            urlTypes.append(newURLTypeEntry)
            debugPrint("ℹ️ 未找到 WeChat URL Scheme，已新增: \(wechatScheme) (Name: \(urlName))")
        }
        
        plistParser.replace(keyPath: "CFBundleURLTypes", with: urlTypes)
    }
    
    private func updateEntry(_ urlType: inout [String: Any], newScheme: String) {
        var schemes = urlType["CFBundleURLSchemes"] as? [String] ?? []
        // 移除所有以 wx 開頭的舊 Scheme (假設它們是舊的微信 ID)
        // 這裡假設使用者不會在同一個 App 裡混用兩個不同的微信 ID
        schemes.removeAll { $0.hasPrefix("wx") }
        schemes.append(newScheme)
        urlType["CFBundleURLSchemes"] = schemes
    }
}
