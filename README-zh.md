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
.package(name: "IPAParser", url: "https://github.com/coollazy/IPAParser.git", from: "1.1.0"),
```

- target 的 dependencies 增加

```swift
.product(name: "IPAParser", package: "IPAParser"),
```

## 使用範例

### IPAParser

- 解壓縮, 壓縮 IPA

```swift
// 初始化 IPAParser
let ipaTemplatePath = URL(string: "path_to_your_ipa")!
let ipaParser = try IPAParser(ipaURL: ipaTemplatePath)

// 取得解壓縮後 IPA 內容的資料夾路徑
let appDirectory = try ipaParser.appDirectory()
```

- 壓縮 IPA

```swift
// 將剛剛解壓縮後的資料夾路徑 重新壓縮成 IPA
let toURL = URL(string: "path_to_new_ipa_want_to_place")!
try ipaParser.build(toPath: toURL)
```

### PlistParser

- 修改 Info.plist 檔案

```swift
// XXX.app 的資料夾路徑, 通常使用 IPAParser 的 appDirectory
let toAppDirectory = URL(string: "path_to_app_want_to_place")!

// 更換 info.plist 的指定 Key 的值, 並直接寫入指定的 Info.plist 檔案內
try PlistParser()
	.replace(key: "CFBundleIdentifier", with: "com.new.bundle.id")
	.replace(key: "CFBundleDisplayName", with: "App新的顯示名稱")
	.build(toPlistURL: toAppDirectory.appendingPathComponent("Info.plist"))
```
