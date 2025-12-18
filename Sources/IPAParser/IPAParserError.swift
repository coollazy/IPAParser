import Foundation

public enum IPAParserError: Error, CustomStringConvertible, LocalizedError {
    case templateIPANotFound(String)
    case ipaInvalid
    case zipFailed
    case custom(String)
    case infoPlistNotFound
    case invalidGoogleAppKey
    case googleAppKeyNotFound
    case googleURLSchemeNotFound
    
    public var description: String {
        switch self {
        case .templateIPANotFound(let path):
            return NSLocalizedString("IPAParser can't find template IPA at path => \(path)", comment: "")
        case .ipaInvalid:
            return NSLocalizedString("IPAParser can't find any *.app in template IPA !!", comment: "")
        case .zipFailed:
            return NSLocalizedString("IPAParser zip IPA failed !!", comment: "")
        case .custom(let message):
            return NSLocalizedString(message, comment: "")
        case .infoPlistNotFound:
            return NSLocalizedString("IPAParser can't find Info.plist !!", comment: "")
        case .invalidGoogleAppKey:
            return NSLocalizedString("IPAParser invalid google app key format", comment: "")
        case .googleAppKeyNotFound:
            return NSLocalizedString("IPAParser google app key (GIDClientID) not found", comment: "")
        case .googleURLSchemeNotFound:
            return NSLocalizedString("IPAParser google URL Scheme not found in CFBundleURLTypes", comment: "")
        }
    }
    
    public var errorDescription: String? {
        description
    }
}
