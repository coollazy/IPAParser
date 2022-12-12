import Foundation
import SwiftCLI
import MD5

public class IconAssetsBuilder {
    private let appIcon: AppIconModel
    
    // Should be Resources/dsg/Assets.xcassets
    public let xcAssetsURL: URL
    
    public init(xcAssetsURL: URL) throws {
        let fileData = try Data(contentsOf: xcAssetsURL.appendingPathComponent("AppIcon.appiconset/Contents.json"))
        self.appIcon = try JSONDecoder().decode(AppIconModel.self, from: fileData)
        self.xcAssetsURL = xcAssetsURL
    }
    
    // sourceURL should be a 2048*2048 icon image, toDirectory should be the xxx.app folder
    public func build(sourceURL: URL, toDirectory: URL) throws {
        // Create a temporary directory named with this instance memory address
        let workingDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("IconAssetsBuilder").appendingPathComponent(Date().MD5)
        if FileManager.default.fileExists(atPath: workingDirectory.path) == false {
            try FileManager.default.createDirectory(at: workingDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Copy the template assets to the temporary directory
        let assetsWorkingLocation = workingDirectory.appendingPathComponent(xcAssetsURL.lastPathComponent)
        try FileManager.default.copyItem(at: xcAssetsURL, to: assetsWorkingLocation)
        
        // Remove the temporary directory after this function finish
        defer {
            do {
                try FileManager.default.removeItem(at: assetsWorkingLocation)
            } catch {
                print(error)
            }
        }
        
        // Copy the icon source to each image location
        // Then resize every image to correct size
        // Compile Assets
        try appIcon.images.forEach{ (image) in
            let iconLocation = assetsWorkingLocation
                .deletingLastPathComponent()
                .appendingPathComponent(image.folder.rawValue)
                .appendingPathComponent(image.filename)

            if FileManager.default.fileExists(atPath: iconLocation.path) {
                try FileManager.default.removeItem(at: iconLocation)
            }
            
            try FileManager.default.copyItem(at: sourceURL, to: iconLocation)
            guard let expectedSize = Int(input: image.expectedSize) else { fatalError("没有读取到特定尺寸") }
            try self.resampleHeightWidthMax(expectedSize, originalImageFile: iconLocation)
        }
        
        try self.compileAssets(at: assetsWorkingLocation, to: toDirectory)
    }
    
    private func resampleHeightWidthMax(_ pixels: Int, originalImageFile: URL) throws {
        do {
            try Task.run("/usr/bin/sips", "-Z", "\(pixels)", originalImageFile.path)
        } catch {
            throw IconAssetsBuilderError.sipsFailed
        }
    }
    
    private func compileAssets(at location: URL, to appDirectory: URL) throws {
        let plistDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("IconAssetsBuilder")
        if FileManager.default.fileExists(atPath: plistDirectory.path) == false {
            try FileManager.default.createDirectory(at: plistDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        let outputPartialInfoPlistLocation = plistDirectory.appendingPathComponent(Date().MD5).appendingPathExtension("plist")
        do {
            _ = try Task.capture("/usr/bin/actool", location.path, "--compile", appDirectory.path, "--platform", "iphoneos", "--minimum-deployment-target", "9.0", "--app-icon", "AppIcon", "--output-partial-info-plist", outputPartialInfoPlistLocation.path)
        } catch {
            throw IconAssetsBuilderError.actoolFailed
        }
        let infoPlistFileLocation = appDirectory.appendingPathComponent("Info.plist")
        
        if FileManager.default.fileExists(atPath: infoPlistFileLocation.path) {
            let value = try Task.capture("/usr/bin/plutil", arguments: ["-extract", "CFBundleIcons", "xml1", "-o", "-", outputPartialInfoPlistLocation.path], directory: nil).stdout
            do {
                try Task.run("/usr/bin/plutil", "-replace", "CFBundleIcons", "-xml", value, infoPlistFileLocation.path)
            } catch {
                throw IconAssetsBuilderError.plutilFailed
            }
        }
    }
}
