# IPAParser

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SPM](https://img.shields.io/badge/SPM-Supported-green)
[![CI](https://github.com/coollazy/IPAParser/actions/workflows/ci.yml/badge.svg)](https://github.com/coollazy/IPAParser/actions/workflows/ci.yml)

## 介紹

解析及重新封裝 IPA

## SPM安裝

- Package.swift 的 dependencies 增加

```swift
.package(name: "IPAParser", url: "https://github.com/coollazy/IPAParser.git", from: "1.1.1"),
```

- target 的 dependencies 增加

```swift
.product(name: "IPAParser", package: "IPAParser"),
```

## 使用範例

### IPAParser

- 初始化與查詢資訊

```swift
// 初始化 IPAParser
let ipaTemplatePath = URL(string: "path_to_your_ipa")!
let parser = try IPAParser(ipaURL: ipaTemplatePath)

// 取得解壓縮後 IPA 內容的資料夾路徑
let appDirectory = try parser.appDirectory()

// 查詢資訊
print(parser.version())       // e.g. "1.0.0"
print(parser.bundleID())      // e.g. "com.example.app"
print(parser.displayName())   // e.g. "我的應用程式"
```

- 修改並壓縮 IPA

```swift
// 支援鏈式調用，一次修改多個屬性
parser.replace(bundleID: "com.new.id")
      .replace(displayName: "新的 App 名稱")

// 將修改後的內容重新壓縮成 IPA
let toURL = URL(string: "path_to_new_ipa_want_to_place")!
try parser.build(toPath: toURL)
```

### PlistParser

- 直接修改 Info.plist 檔案

```swift
// 指定 Info.plist 的路徑
let infoPlistURL = URL(string: "path/to/Payload/App.app/Info.plist")!

// 更換 Info.plist 的指定 Key 的值, 並直接寫入檔案
try PlistParser(url: infoPlistURL)
    .replace(keyPath: "CFBundleIdentifier", with: "com.new.bundle.id")
    .replace(keyPath: "CFBundleDisplayName", with: "App新的顯示名稱")
    .build(toPlistURL: infoPlistURL)
```
