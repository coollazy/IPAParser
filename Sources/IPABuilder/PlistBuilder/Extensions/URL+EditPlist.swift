import Foundation
import SwiftCLI

extension URL {
    @discardableResult
    func replace(_ keypath: String, with value: String) throws -> Self {
        guard pathExtension == "plist" else {
            throw PlistBuilderError.invaildPlistURL(self.path)
        }
        
        try remove(keypath)
        do {
            try Task.run("/usr/bin/plutil", "-replace", keypath, "-string", value, path)
        } catch {
            throw PlistBuilderError.plutilFailed
        }
        return self
    }
    
    @discardableResult
    func remove(_ keypath: String) throws -> Self {
        guard pathExtension == "plist" else {
            throw PlistBuilderError.invaildPlistURL(self.path)
        }
        
        do {
            try Task.run("/usr/bin/plutil", "-remove", keypath, path)
        } catch {
            throw PlistBuilderError.plutilFailed
        }
        return self
    }
    
    @discardableResult
    func insert(_ keypath: String, with value: String) throws -> Self {
        guard pathExtension == "plist" else {
            throw PlistBuilderError.invaildPlistURL(self.path)
        }
        
        do {
            try Task.run("/usr/bin/plutil", "-insert", keypath, "-string", value, path)
        } catch {
            throw PlistBuilderError.plutilFailed
        }
        return self
    }
}
