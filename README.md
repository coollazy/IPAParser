# IPABuilder

## 介紹

Swift IPA 重新封裝的套件

## SPM安裝

- Package.swift 的 dependencies 增加

```
.package(name: "IPABuilder", url: "https://github.com/coollazy/IPABuilder.git", from: "1.0.4"),
```

- target 的 dependencies 增加

```
.product(name: "IPABuilder", package: "IPABuilder"),
```

## 範例

### IPABuilder

- 解壓縮, 壓縮, 重簽名 IPA

```
// 初始化 IPABuilder
let ipaTemplatePath = URL(string: "path_to_your_ipa")!
let ipaBuilder = try IPABuilder(ipaURL: ipaTemplatePath)

// 取得解壓縮後 IPA 內容的資料夾路徑
let appDirectory = try ipaBuilder.appDirectory()

// 將剛剛解壓縮後的資料夾路徑 重新壓縮成 IPA
let toURL = URL(string: "path_to_new_ipa_want_to_place")!
try ipaBuilder.build(toDirectory: toURL)

// 將剛剛解壓縮後的資料夾路徑 修改憑證內容後 重新壓縮成 IPA
let certificationName = "iPhone Developer: NAME (TEAM_ID)"
let provisionURL = URL(string: "xxx.mobileprovision")!

let toDirectory = URL(string: "path_to_new_signed_ipa_want_to_place")!
try signature(certificationName: certificationName, provisionURL: provisionURL, toDirectory: toDirectory)
```

### IconAssetsBuilder

- 製作 AppIcon.appiconset

```
// 需要提供一個 xcAssets 資料夾, 當作範本
let xcAssetsURL = URL(string: "path_to_template_xcAssets")!

// 新的 Icon 圖檔, 檔案尺寸必須為 2048*2048
let iconSourceURL = URL(string: "path_to_2048_*_2048_icon")!

// XXX.app 的資料夾路徑, 通常使用 IPABuilder 的 appDirectory
let toAppDirectory = URL(string: "path_to_app_want_to_place")!

// 將新的 Icon 圖檔 resize 並放進 toAppDirectory 內
try IconAssetsBuilder(xcAssetsURL: xcAssetsURL)
	.build(sourceURL: iconSourceURL, toDirectory: toAppDirectory)
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










