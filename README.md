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
.package(name: "IPAParser", url: "https://github.com/coollazy/IPAParser.git", from: "1.1.0"),
```

- Add to target dependencies:

```swift
.product(name: "IPAParser", package: "IPAParser"),
```

## Usage

### IPAParser

- Initialize Builder with IPA

```swift
// Initialize IPAParser
let ipaTemplatePath = URL(string: "path_to_your_ipa")!
let ipaParser = try IPAParser(ipaURL: ipaTemplatePath)

// Get the path to the folder containing the extracted IPA contents
let appDirectory = try ipaParser.appDirectory()
```

- Build IPA

```swift
// Repackage the previously extracted folder into a new IPA
let toURL = URL(string: "path_to_new_ipa_want_to_place")!
try ipaParser.build(toPath: toURL)
```

### PlistParser

- Modify Info.plist file

```swift
// Path to the XXX.app folder, usually obtained from IPAParser's appDirectory
let toAppDirectory = URL(string: "path_to_app_want_to_place")!

// Replace the value for the specified key in Info.plist and write directly to the file
try PlistParser()
	.replace(key: "CFBundleIdentifier", with: "com.new.bundle.id")
	.replace(key: "CFBundleDisplayName", with: "App新的顯示名稱")
	.build(toPlistURL: toAppDirectory.appendingPathComponent("Info.plist"))
```
