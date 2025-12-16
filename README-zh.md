# IPAParser

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SPM](https://img.shields.io/badge/SPM-Supported-green)
[![CI](https://github.com/coollazy/IPAParser/actions/workflows/ci.yml/badge.svg)](https://github.com/coollazy/IPAParser/actions/workflows/ci.yml)

## 介紹

解析及重新封裝 IPA

## 前置需求

IPAParser 依賴 **ImageMagick** 進行圖片處理（Icon 縮放）。**僅在您需要使用 `replace(icon:)` 功能時才需要安裝。**

- **macOS**:
  ```bash
  brew install imagemagick
  ```

- **Linux (Ubuntu/Debian)**:
  ```bash
  sudo apt-get install imagemagick
  ```

## SPM安裝

- Package.swift 的 dependencies 增加

```swift
.package(url: "https://github.com/coollazy/IPAParser.git", from: "1.1.1"),
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
print(parser.buildNumber())   // e.g. "1"
print(parser.bundleID())      // e.g. "com.example.app"
print(parser.displayName())   // e.g. "我的應用程式"
```

- 修改並壓縮 IPA

```swift
// 支援鏈式調用，一次修改多個屬性，包含 Bundle ID, 顯示名稱, 版本號, Build Number 及 Icon
parser.replace(bundleID: "com.new.id")
      .replace(displayName: "新的 App 名稱")
      .replace(version: "2.0.0")
      .replace(buildNumber: "200")
      .replace(icon: URL(string: "path_to_new_icon.png")!) // 支援本地路徑或遠端 URL

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

## Docker 支援

關於如何使用 Docker 建構與執行範例專案（自動處理所有依賴），請參閱 [Example/README.md](Example/README.md)。
