import Foundation
import PlistParser

public extension IPAParser {
    /// 應用一個配置組件 (Component) 來修改 IPA。
    /// 這適用於 Google, Facebook 等第三方 SDK 的配置，或資源替換操作。
    ///
    /// - Parameter component: 要應用的組件實例 (例如 `GoogleComponent`)
    /// - Returns: IPAParser 實例本身，用於鏈式呼叫。
    @discardableResult
    func apply(_ component: IPAComponent) -> Self {
        // 1. 取得 App Directory (如果失敗則無法進行任何檔案操作)
        guard let appDir = try? appDirectory() else {
            debugPrint("⚠️ \(IPAParserError.ipaInvalid.description)")
            return self
        }

        // 2. 取得 PlistParser (如果失敗則無法修改 Info.plist)
        guard let plistParser = try? getPlistParser() else {
            debugPrint("⚠️ \(IPAParserError.infoPlistNotFound.description)")
            return self
        }
        
        // 3. 建構 Context
        let context = IPAContext(plistParser: plistParser, appDirectory: appDir)
        
        do {
            // 4. 執行 Component 邏輯
            try component.apply(to: context)
            
            // 5. 將修改寫回 Info.plist 文件
            // 注意：如果 Component 修改了其他檔案，它應該自己在 apply 方法中處理 IO。
            // 這裡我們確保最常見的 Info.plist 變更被儲存。
            try plistParser.build()
            // debugPrint("✅ Component applied: \(type(of: component))")
        } catch {
            debugPrint("❌ Component \(type(of: component)) apply failed: \(error.localizedDescription)")
        }
        
        return self
    }
}