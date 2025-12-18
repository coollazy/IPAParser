# IPAParser

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SPM](https://img.shields.io/badge/SPM-Supported-green)
[![CI](https://github.com/coollazy/IPAParser/actions/workflows/ci.yml/badge.svg)](https://github.com/coollazy/IPAParser/actions/workflows/ci.yml)
## Introduction

Parse and repackage IPA files.

## Prerequisites

IPAParser relies on **ImageMagick** for image processing (icon resizing). **This is only required if you plan to use the `replace(icon:)` feature.**

- **macOS**:
  ```bash
  brew install imagemagick
  ```

- **Linux (Ubuntu/Debian)**:
  ```bash
  sudo apt-get install imagemagick
  ```

## SPM Installation

- Add to Package.swift dependencies:

```swift
.package(url: "https://github.com/coollazy/IPAParser.git", from: "1.3.0"),
```

- Add to target dependencies:

```swift
.product(name: "IPAParser", package: "IPAParser"),
```

## Usage

### IPAParser

- Initialize and Query Metadata

```swift
// Initialize IPAParser
let ipaTemplatePath = URL(string: "path_to_your_ipa")!
let parser = try IPAParser(ipaURL: ipaTemplatePath)

// Get App Directory
let appDirectory = try parser.appDirectory()

// Query Metadata
print(parser.version())       // e.g. "1.0.0"
print(parser.buildNumber())   // e.g. "1"
print(parser.bundleID())      // e.g. "com.example.app"
print(parser.displayName())   // e.g. "My App"
print(parser.executableName())// e.g. "App" or "Example"
```

- Modify and Build IPA

```swift
// Modify Bundle ID, Display Name, Version, Build Number, Icon, and Third-party Configs in a chainable way
try parser.replace(bundleID: "com.new.id")
      .replace(displayName: "New App Name")
      .replace(version: "2.0.0")
      .replace(buildNumber: "200")
      .replace(icon: URL(string: "path_to_new_icon.png")!) // Supports local path or remote URL
      .apply(GoogleComponent(appKey: "123456789-abc.apps.googleusercontent.com")) // Apply third-party config (Google Sign-In)
      .apply(FacebookComponent(appID: "987654321", clientToken: "xyz123abc", displayName: "My FB App")) // Apply third-party config (Facebook SDK)
      .apply(QQComponent(appID: "100424468")) // Apply third-party config (QQ SDK)
      .apply(WeChatComponent(appID: "wx1234567890abcdef")) // Apply third-party config (WeChat SDK)
      .apply(LinkDeepComponent(appKey: "linkdeep_app_key_abc", groupKey: "linkdeep_group_key_xyz")) // Apply third-party config (LinkDeep SDK)

// Repackage into a new IPA
let toURL = URL(string: "path_to_new_ipa_want_to_place")!
try parser.build(toPath: toURL)
```

### PlistParser

- Modify Info.plist file directly

```swift
// Path to the Info.plist file
let infoPlistURL = URL(string: "path/to/Payload/App.app/Info.plist")!

// Replace values and write back to file
try PlistParser(url: infoPlistURL)
    .replace(keyPath: "CFBundleIdentifier", with: "com.new.bundle.id")
    .replace(keyPath: "CFBundleDisplayName", with: "New App Name")
    .build(toPlistURL: infoPlistURL)
```

## Docker Support

For instructions on how to build and run the example project using Docker (which handles all dependencies automatically), please refer to [Example/README.md](Example/README.md).
