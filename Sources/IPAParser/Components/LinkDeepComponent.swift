import Foundation
import PlistParser

public struct LinkDeepComponent: IPAComponent {
    let appKey: String?
    let groupKey: String?
    
    public init(appKey: String? = nil, groupKey: String? = nil) {
        self.appKey = appKey
        self.groupKey = groupKey
    }
    
    public func apply(to context: IPAContext) throws {
        let plistParser = context.plistParser
        
        // 1. Update App Key
        if let appKey = appKey {
            updateURLScheme(plistParser: plistParser, 
                            urlName: "com.link-deep.appkey", 
                            newScheme: appKey)
        } else {
            debugPrint("ℹ️ LinkDeep App Key 為 nil，跳過更新。")
        }
        
        // 2. Update Group Key
        if let groupKey = groupKey {
            updateURLScheme(plistParser: plistParser, 
                            urlName: "com.link-deep.groupkey", 
                            newScheme: groupKey)
        } else {
            debugPrint("ℹ️ LinkDeep Group Key 為 nil，跳過更新。")
        }
    }
    
    private func updateURLScheme(plistParser: PlistParser, urlName: String, newScheme: String) {
        var urlTypes = plistParser.get(keyPath: "CFBundleURLTypes") as? [[String: Any]] ?? []
        var entryFoundAndReplaced = false
        
        for (index, var urlType) in urlTypes.enumerated() {
            if let name = urlType["CFBundleURLName"] as? String, name == urlName {
                // 找到了明確標記的 Entry
                // 直接替換 Scheme (LinkDeep 看起來是一個 Scheme 佔據一個 Entry)
                urlType["CFBundleURLSchemes"] = [newScheme]
                urlTypes[index] = urlType
                entryFoundAndReplaced = true
                debugPrint("✅ CFBundleURLTypes 中 Name 為 '\(urlName)' 的 Entry 已更新 Scheme 為: \(newScheme)")
                break
            }
        }
        
        if !entryFoundAndReplaced {
            // 沒找到，新增一個
            let newURLTypeEntry: [String: Any] = [
                "CFBundleTypeRole": "Editor",
                "CFBundleURLName": urlName,
                "CFBundleURLSchemes": [newScheme]
            ]
            urlTypes.append(newURLTypeEntry)
            debugPrint("ℹ️ 未找到 LinkDeep URL Scheme (\(urlName))，已新增: \(newScheme)")
        }
        
        plistParser.replace(keyPath: "CFBundleURLTypes", with: urlTypes)
    }
}
