# IPABuilder

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SPM](https://img.shields.io/badge/SPM-Supported-green)

## Introduction

Parse and repackage IPA files.

## SPM Installation

- Add to Package.swift dependencies:

```
.package(name: "IPABuilder", url: "https://github.com/coollazy/IPABuilder.git", from: "1.0.4"),
```

- Add to target dependencies:

```
.product(name: "IPABuilder", package: "IPABuilder"),
```

## Usage

### IPABuilder

- Initialize Builder with IPA

```
// Initialize IPABuilder
let ipaTemplatePath = URL(string: "path_to_your_ipa")!
let ipaBuilder = try IPABuilder(ipaURL: ipaTemplatePath)

// Get the path to the folder containing the extracted IPA contents
let appDirectory = try ipaBuilder.appDirectory()
```

- Build IPA

```
// Repackage the previously extracted folder into a new IPA
let toURL = URL(string: "path_to_new_ipa_want_to_place")!
try ipaBuilder.build(toDirectory: toURL)
```

### PlistBuilder

- Modify Info.plist file

```
// Path to the XXX.app folder, usually obtained from IPABuilder's appDirectory
let toAppDirectory = URL(string: "path_to_app_want_to_place")!

// Replace the value for the specified key in Info.plist and write directly to the file
try PlistBuilder()
	.replace(key: "CFBundleIdentifier", with: "com.new.bundle.id")
	.replace(key: "CFBundleDisplayName", with: "App新的顯示名稱")
	.build(toPlistURL: toAppDirectory.appendingPathComponent("Info.plist"))
```
