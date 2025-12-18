import Foundation
import PlistParser

/// 提供給組件操作 IPA 內容的上下文環境
public struct IPAContext {
    /// Info.plist 的解析器，可用於讀取或修改 Info.plist
    public let plistParser: PlistParser
    
    /// 解壓後的 .app 目錄路徑 (File URL)
    /// 組件可以使用此 URL 來存取或修改 App Bundle 內的任何檔案 (例如替換資源檔、GoogleService-Info.plist 等)
    public let appDirectory: URL
    
    public init(plistParser: PlistParser, appDirectory: URL) {
        self.plistParser = plistParser
        self.appDirectory = appDirectory
    }
}

public protocol IPAComponent {
    /// 執行該組件的配置邏輯
    /// - Parameter context: 包含 IPA 操作環境的上下文物件
    /// - Returns: 是否執行成功（或拋出錯誤）
    func apply(to context: IPAContext) throws
}