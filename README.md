# IPAParser

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SPM](https://img.shields.io/badge/SPM-Supported-green)
[![CI](https://github.com/coollazy/IPAParser/actions/workflows/ci.yml/badge.svg)](https://github.com/coollazy/IPAParser/actions/workflows/ci.yml)
## Introduction

Parse and repackage IPA files.

## SPM Installation

- Add to Package.swift dependencies:

```swift
.package(name: "IPAParser", url: "https://github.com/coollazy/IPAParser.git", from: "1.1.1"),
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
print(parser.bundleID())      // e.g. "com.example.app"
print(parser.displayName())   // e.g. "My App"
```

- Modify and Build IPA

```swift
// Modify Bundle ID and Display Name in a chainable way
parser.replace(bundleID: "com.new.id")
      .replace(displayName: "New App Name")

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
