import Foundation

public class PlistParser {
    private let url: URL
    public var content: Dictionary<String, Any>?
    
    public init(url: URL) throws {
        self.url = url
        guard let data = try? Data(contentsOf: url) else {
            throw PlistParserError.readFailed(url)
        }
        guard let content = try? PropertyListSerialization.propertyList(from: data, format: nil) as? Dictionary<String, Any> else {
            throw PlistParserError.decodeContentFailed
        }
        self.content = content
    }
    
    @discardableResult
    public func replace(key: String, with value: String?) throws -> Self {
        guard content?[key] != nil else {
            throw PlistParserError.replaceFailed(key, value ?? "nil")
        }
        
        content?[key] = value
        return self
    }
    
    public func build(toPlistURL: URL? = nil) throws {
        let toPlistURL = toPlistURL ?? url
        let content = content ?? [String: Any]()
        
        guard let data = try? PropertyListSerialization.data(fromPropertyList: content, format: .xml, options: 0) else {
            throw PlistParserError.encodeContentFailed
        }
        try data.write(to: toPlistURL)
    }
}
