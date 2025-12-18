import Foundation
import PlistParser

public struct FacebookComponent: IPAComponent {
    let appID: String?
    let clientToken: String?
    let displayName: String?
    
    public init(appID: String?, clientToken: String? = nil, displayName: String? = nil) {
        self.appID = appID
        self.clientToken = clientToken
        self.displayName = displayName
    }
    
    public func apply(to context: IPAContext) throws {
        let plistParser = context.plistParser
        
        // 1. Update FacebookAppID & URL Scheme (only if appID is provided)
        if let appID = appID {
            plistParser.replace(keyPath: "FacebookAppID", with: appID)
            debugPrint("✅ FacebookAppID 已設定/更新為: \(appID)")
            
            updateURLScheme(plistParser: plistParser, appID: appID)
        } else {
            debugPrint("ℹ️ FacebookAppID 為 nil，跳過更新 FacebookAppID 及 URL Scheme。")
        }
        
        // 2. Update FacebookClientToken (only if clientToken is provided)
        if let clientToken = clientToken {
            plistParser.replace(keyPath: "FacebookClientToken", with: clientToken)
            debugPrint("✅ FacebookClientToken 已設定/更新為: \(clientToken)")
        } else {
            debugPrint("ℹ️ FacebookClientToken 為 nil，跳過更新 FacebookClientToken。")
        }
        
        // 3. Update FacebookDisplayName (only if displayName is provided)
        if let displayName = displayName {
            plistParser.replace(keyPath: "FacebookDisplayName", with: displayName)
            debugPrint("✅ FacebookDisplayName 已設定/更新為: \(displayName)")
        } else {
            debugPrint("ℹ️ FacebookDisplayName 為 nil，跳過更新 FacebookDisplayName。")
        }
    }
    
    private func updateURLScheme(plistParser: PlistParser, appID: String) {
        var urlTypes = plistParser.get(keyPath: "CFBundleURLTypes") as? [[String: Any]] ?? []
        let fbScheme = "fb\(appID)"
        let fbSchemePrefix = "fb"
        var entryFoundAndReplaced = false
        
        for (index, var urlType) in urlTypes.enumerated() {
            if let urlSchemes = urlType["CFBundleURLSchemes"] as? [String],
               urlSchemes.contains(where: { $0.hasPrefix(fbSchemePrefix) }) {
                
                // 找到舊的 entry (包含 fb...)
                // 移除所有舊的 FB Scheme，然後加入新的
                var updatedSchemes = urlSchemes.filter { !$0.hasPrefix(fbSchemePrefix) }
                updatedSchemes.append(fbScheme)
                
                urlType["CFBundleURLSchemes"] = updatedSchemes
                urlTypes[index] = urlType
                entryFoundAndReplaced = true
                debugPrint("✅ CFBundleURLTypes 中現有 Facebook URL Scheme 已更新為: \(fbScheme)")
                break
            }
        }
        
        if !entryFoundAndReplaced {
            // 新增一個
            let newURLTypeEntry: [String: Any] = [
                "CFBundleTypeRole": "Editor",
                "CFBundleURLSchemes": [fbScheme]
            ]
            urlTypes.append(newURLTypeEntry)
            debugPrint("ℹ️ 未找到 Facebook URL Scheme，已新增: \(fbScheme)")
        }
        
        plistParser.replace(keyPath: "CFBundleURLTypes", with: urlTypes)
    }
}