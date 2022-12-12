import Foundation

enum IPABuilderError: Error, CustomStringConvertible, LocalizedError {
    case templateIPANotFound(String)
    case ipaInvalid
    case provisionFailed
    case entitlementsFailed
    case zipFailed
    
    public var description: String {
        switch self {
        case .templateIPANotFound(let path):
            return NSLocalizedString("IPABuilder can't find template IPA at path => \(path)", comment: "")
        case .ipaInvalid:
            return NSLocalizedString("IPABuilder can't find any *.app in template IPA !!", comment: "")
        case .provisionFailed:
            return NSLocalizedString("IPABuilder can't create provision.plist !!", comment: "")
        case .entitlementsFailed:
            return NSLocalizedString("IPABuilder can't create entitlements.plist !!", comment: "")
        case .zipFailed:
            return NSLocalizedString("IPABuilder zip IPA failed !!", comment: "")
        }
    }
    
    public var errorDescription: String? {
        description
    }
}
