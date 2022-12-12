import Foundation

public class PlistBuilder {
    private var plistInfos = [String: String]()
    
    public init() {}
    
    public func replace(key: String, with value: String?) -> Self {
        if let value = value {
            plistInfos[key] = value
        }
        return self
    }
    
    public func build(toPlistURL: URL) throws {
        try plistInfos.forEach({ (key, value) in
            try toPlistURL.replace(key, with: value)
        })
    }
}
