import Foundation

public enum PlistBuilderError: Error, CustomStringConvertible, LocalizedError {
    case readFailed(URL)
    case decodeContentFailed
    case encodeContentFailed
    case replaceFailed(String, String)
    
    public var description: String {
        switch self {
        case .readFailed(let url):
            return NSLocalizedString("[Error] PlistBuilder read plist url failed => \(url.absoluteString)", comment: "")
        case .decodeContentFailed:
            return NSLocalizedString("[Error] PlistBuilder decode plist failed", comment: "")
        case .encodeContentFailed:
            return NSLocalizedString("[Error] PlistBuilder encode plist failed", comment: "")
        case .replaceFailed(let key, let value):
            return NSLocalizedString("[Error] PlistBuilder replace plist failed at key => \(key) with value => \(value)", comment: "")
        }
    }
    
    public var errorDescription: String? {
        description
    }
}
