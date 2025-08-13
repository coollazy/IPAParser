import Foundation

public enum PlistParserError: Error, CustomStringConvertible, LocalizedError {
    case readFailed(URL)
    case decodeContentFailed
    case encodeContentFailed
    case replaceFailed(String, String)
    
    public var description: String {
        switch self {
        case .readFailed(let url):
            return NSLocalizedString("[Error] PlistParser read plist url failed => \(url.absoluteString)", comment: "")
        case .decodeContentFailed:
            return NSLocalizedString("[Error] PlistParser decode plist failed", comment: "")
        case .encodeContentFailed:
            return NSLocalizedString("[Error] PlistParser encode plist failed", comment: "")
        case .replaceFailed(let key, let value):
            return NSLocalizedString("[Error] PlistParser replace plist failed at key => \(key) with value => \(value)", comment: "")
        }
    }
    
    public var errorDescription: String? {
        description
    }
}
