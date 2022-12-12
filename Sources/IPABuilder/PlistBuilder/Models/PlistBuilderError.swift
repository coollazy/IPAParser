import Foundation

enum PlistBuilderError: Error, CustomStringConvertible, LocalizedError {
    case invaildPlistURL(String)
    case replaceFailed(String, String)
    case plutilFailed
    
    public var description: String {
        switch self {
        case .invaildPlistURL(let path):
            return NSLocalizedString("PlistBuilderError invaild plist url => \(path)", comment: "")
        case .replaceFailed(let key, let value):
            return NSLocalizedString("[PlistBuilderError] replace plist failed at key => \(key) with value => \(value)", comment: "")
        case .plutilFailed:
            return NSLocalizedString("PlistBuilderError SwiftCLI Task run plutil failed !!", comment: "")
        }
    }
    
    public var errorDescription: String? {
        description
    }
}
