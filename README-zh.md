# IPABuilder

## 介紹

解析及重新封裝 IPA

## SPM安裝

- Package.swift 的 dependencies 增加

```
.package(name: "IPABuilder", url: "https://github.com/coollazy/IPABuilder.git", from: "1.0.4"),
```

- target 的 dependencies 增加

```
.product(name: "IPABuilder", package: "IPABuilder"),
```

## 使用範例

### IPABuilder

- 解壓縮, 壓縮 IPA

```
// 初始化 IPABuilder
let ipaTemplatePath = URL(string: "path_to_your_ipa")!
let ipaBuilder = try IPABuilder(ipaURL: ipaTemplatePath)

// 取得解壓縮後 IPA 內容的資料夾路徑
let appDirectory = try ipaBuilder.appDirectory()
```

- 壓縮 IPA

```
// 將剛剛解壓縮後的資料夾路徑 重新壓縮成 IPA
let toURL = URL(string: "path_to_new_ipa_want_to_place")!
try ipaBuilder.build(toDirectory: toURL)
```

### PlistBuilder

- 修改 Info.plist 檔案

```
// XXX.app 的資料夾路徑, 通常使用 IPABuilder 的 appDirectory
let toAppDirectory = URL(string: "path_to_app_want_to_place")!

// 更換 info.plist 的指定 Key 的值, 並直接寫入指定的 Info.plist 檔案內
try PlistBuilder()
	.replace(key: "CFBundleIdentifier", with: "com.new.bundle.id")
	.replace(key: "CFBundleDisplayName", with: "App新的顯示名稱")
	.build(toPlistURL: toAppDirectory.appendingPathComponent("Info.plist"))
```
