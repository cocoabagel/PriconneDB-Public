# Build

コード変更後のビルド検証を行います。

## 実行手順

1. **SwiftFormat実行**
   ```bash
   swiftformat Packages/
   ```

2. **SwiftLint実行**
   ```bash
   swiftlint lint Packages/
   ```

3. **XcodeBuildMCPでビルド**
   ```
   mcp__XcodeBuildMCP__build_sim (scheme: PriconneDB, simulatorName: iPhone 17)
   ```

## ビルドを依頼されたら

1. SwiftFormat → SwiftLint → ビルドの順で実行
2. エラーがあれば修正
3. 全て成功するまで繰り返す
