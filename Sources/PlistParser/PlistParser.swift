import Foundation

public class PlistParser {
    private let url: URL
    public private(set) var content: [String: Any]
    
    public init(url: URL) throws {
        self.url = url
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            debugPrint("⚠️⚠️ PlistParser Data(contentsOf:) error: \(error)")
            // If data loading fails, it's a read error (e.g., file not found, permissions)
            throw PlistParserError.readFailed(url)
        }

        do {
            guard let content = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
                // If PropertyListSerialization succeeds but returns something that isn't a [String: Any]
                throw PlistParserError.decodeContentFailed
            }
            self.content = content
        } catch {
            debugPrint("⚠️⚠️ PlistParser PropertyListSerialization error: \(error)")
            // If PropertyListSerialization itself throws an error (e.g., malformed plist)
            throw PlistParserError.decodeContentFailed
        }
    }
    
    // MARK: - Read
    /// 讀取巢狀 key，例如 "CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"
    public func get(keyPath: String) -> Any? {
        let keys = keyPath.components(separatedBy: ".")
        var current: Any? = content
        
        for key in keys {
            if let dict = current as? [String: Any] {
                current = dict[key]
            } else {
                return nil
            }
        }
        return current
    }
    
    // MARK: - Create / Update
    /// 設定巢狀 key，不存在的中間層會自動建立
    @discardableResult
    public func replace(keyPath: String, with value: Any?) -> Self {
        let keys = keyPath.components(separatedBy: ".")
        guard let firstKey = keys.first else { return self }
        
        if keys.count == 1 {
            content[firstKey] = value
            return self
        }
        
        var dict = content
        setValue(&dict, keys: keys, value: value)
        content = dict
        return self
    }
    
    private func setValue(_ dict: inout [String: Any], keys: [String], value: Any?) {
        var keys = keys
        let currentKey = keys.removeFirst()
        
        if keys.isEmpty {
            dict[currentKey] = value
        } else {
            var nestedDict = dict[currentKey] as? [String: Any] ?? [:]
            setValue(&nestedDict, keys: keys, value: value)
            dict[currentKey] = nestedDict
        }
    }
    
    // MARK: - Delete
    /// 移除巢狀 key，如果不存在則不做任何事
    @discardableResult
    public func remove(keyPath: String) -> Self {
        let keys = keyPath.components(separatedBy: ".")
        guard let firstKey = keys.first else { return self }
        
        if keys.count == 1 {
            content.removeValue(forKey: firstKey)
            return self
        }
        
        var dict = content
        removeValue(&dict, keys: keys)
        content = dict
        return self
    }
    
    private func removeValue(_ dict: inout [String: Any], keys: [String]) {
        var keys = keys
        let currentKey = keys.removeFirst()
        
        if keys.isEmpty {
            dict.removeValue(forKey: currentKey)
        } else {
            guard var nestedDict = dict[currentKey] as? [String: Any] else { return }
            removeValue(&nestedDict, keys: keys)
            dict[currentKey] = nestedDict
        }
    }
    
    // MARK: - Write
    public func build(toPlistURL: URL? = nil) throws {
        let toPlistURL = toPlistURL ?? url
        let content = content
        
        guard let data = try? PropertyListSerialization.data(fromPropertyList: content, format: .xml, options: 0) else {
            throw PlistParserError.encodeContentFailed
        }
        try data.write(to: toPlistURL)
    }
}
