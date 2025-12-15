# IPAParser 範例專案

此目錄包含一個範例應用程式，演示如何使用 `IPAParser` 函式庫來解析、修改和重新封裝 IPA 檔案。

## 功能說明

這個範例應用程式執行以下操作：
1.  載入 `Resources/Example.ipa`。
2.  使用載入的 IPA 初始化 `IPAParser`。
3.  將 IPA 的 Bundle ID 修改為 "com.newtest.example"。
4.  將 IPA 的顯示名稱修改為 "新IPA"。
5.  列印 IPA 的當前版本號。
6.  將修改後的 IPA 重新封裝為 `NewExample.ipa`，並儲存到 `output/` 目錄中。

## 如何執行

### 1. 本機執行

若要在您的 macOS 或 Linux 機器上直接執行此範例應用程式：

```bash
# 切換到專案根目錄
cd /path/to/IPAParser

# 編譯範例應用程式 (使用 release 配置)
swift build --product App --package-path Example --configuration release

# 執行範例應用程式
# 它會從執行的目錄相對路徑尋找 Resources/Example.ipa
.build/release/App
```

執行後，您應會在專案根目錄下的 `output/` 目錄中找到一個 `NewExample.ipa` 檔案。

### 2. Docker 執行

此範例也包含一個 `Dockerfile`，用於在 Docker 容器內建構和執行應用程式，以驗證其與 Linux 環境的兼容性。

#### 建構 Docker 映像

**注意：必須從專案根目錄執行此命令，以確保 Docker context 包含完整的專案源碼。**

```bash
# 切換到專案根目錄
cd /path/to/IPAParser

docker build -t ipaparser-example -f Example/Dockerfile .
```

#### 執行 Docker 容器

建構映像後，您可以直接執行容器。應用程式將執行其邏輯然後退出。

```bash
docker run --rm ipaparser-example
```

執行後，`NewExample.ipa` 將在 Docker 容器的 `/app/output/` 目錄中生成。如需存取該檔案，您可能需要修改 `Dockerfile` 將其複製出來或掛載一個 volume 來儲存輸出。對於 CI 驗證，成功執行即已足夠。
