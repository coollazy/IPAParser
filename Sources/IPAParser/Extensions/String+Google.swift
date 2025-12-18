import Foundation

public extension String {
    func isValidGoogleAppKey() -> Bool {
        /// 檢查 Google Client ID 格式是否符合  ex. 1234567890-abcdefg.apps.googleusercontent.com
        let suffix = ".apps.googleusercontent.com"
        guard hasSuffix(suffix) else { return false }
        
        // Ensure there is a prefix before the suffix
        return count > suffix.count
    }
    
    func reversed(separator: String) -> String {
        components(separatedBy: separator)
            .reversed()
            .joined(separator: separator)
    }
}
