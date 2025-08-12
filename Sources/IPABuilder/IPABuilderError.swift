import Foundation

public enum IPABuilderError: Error, CustomStringConvertible, LocalizedError {
    case templateIPANotFound(String)
    case ipaInvalid
    case zipFailed
    
    public var description: String {
        switch self {
        case .templateIPANotFound(let path):
            return NSLocalizedString("IPABuilder can't find template IPA at path => \(path)", comment: "")
        case .ipaInvalid:
            return NSLocalizedString("IPABuilder can't find any *.app in template IPA !!", comment: "")
        case .zipFailed:
            return NSLocalizedString("IPABuilder zip IPA failed !!", comment: "")
        }
    }
    
    public var errorDescription: String? {
        description
    }
}
