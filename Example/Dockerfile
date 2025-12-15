# ================================
# Build image
# ================================
FROM swift:5.10-noble AS build

WORKDIR /IPAParser

# 1. 複製整個專案上下文 (包含 Image 庫源碼和 Example 應用)
COPY . .

# 2. 切換到 Example 目錄進行構建
WORKDIR /IPAParser/Example

# 3. 解析依賴並構建
# 注意：Example/Package.swift 的 path: "../" 會指向 /IPAParser (即 IPAParser 庫源碼)
# 目錄名稱現在匹配 Package 名稱，解決 SPM 解析問題
RUN swift package resolve \
    $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

RUN swift build -c release --static-swift-stdlib

# ================================
# Run image
# ================================
FROM ubuntu:noble

# 安裝 runtime 依賴（包含 ImageMagick CLI）
RUN apt-get update && apt-get install -y \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 4. 從 build 階段複製編譯好的執行檔
# 注意路徑變化：現在是在 /IPAParser/Example/.build/release/App
COPY --from=build /IPAParser/Example/.build/release/App ./
# 複製 Resources
COPY --from=build /IPAParser/Example/Resources ./Resources

EXPOSE 8080
CMD ["./App"]
