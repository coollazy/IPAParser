import Foundation

public enum IPAParserError: Error, CustomStringConvertible, LocalizedError {
    case templateIPANotFound(String)
    case ipaInvalid
    case zipFailed
    
    public var description: String {
        switch self {
        case .templateIPANotFound(let path):
            return NSLocalizedString("IPAParser can't find template IPA at path => \(path)", comment: "")
        case .ipaInvalid:
            return NSLocalizedString("IPAParser can't find any *.app in template IPA !!", comment: "")
        case .zipFailed:
            return NSLocalizedString("IPAParser zip IPA failed !!", comment: "")
        }
    }
    
    public var errorDescription: String? {
        description
    }
}
