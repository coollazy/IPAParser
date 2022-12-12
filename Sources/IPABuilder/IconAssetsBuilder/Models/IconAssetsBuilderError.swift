import Foundation

enum IconAssetsBuilderError: Error, CustomStringConvertible, LocalizedError {
    case sipsFailed
    case actoolFailed
    case plutilFailed
    
    public var description: String {
        switch self {
        case .sipsFailed:
            return NSLocalizedString("IconAssetsBuilder SwiftCLI Task run sips failed !!", comment: "")
        case .actoolFailed:
            return NSLocalizedString("IconAssetsBuilder SwiftCLI Task run actool failed !!", comment: "")
        case .plutilFailed:
            return NSLocalizedString("IconAssetsBuilder SwiftCLI Task run plutil failed !!", comment: "")
        }
    }
    
    public var errorDescription: String? {
        description
    }
}
