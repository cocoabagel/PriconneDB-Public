# MCPツール

PriconneDBプロジェクトで使用するMCPツールの説明です。

## XcodeBuildMCP

Xcodeプロジェクトのビルド、実行、テストを行うMCPツールです。

### ビルド（iOSシミュレータ）

```
mcp__XcodeBuildMCP__build_sim({
    projectPath: "/Users/kbaba/Workbox/PriconneDB/PriconneDB.xcodeproj",
    scheme: "PriconneDB",
    simulatorName: "iPhone 17 Pro"
})
```

### ビルドして実行

```
mcp__XcodeBuildMCP__build_run_sim({
    projectPath: "/Users/kbaba/Workbox/PriconneDB/PriconneDB.xcodeproj",
    scheme: "PriconneDB",
    simulatorName: "iPhone 17 Pro"
})
```

### プロジェクト検出

```
mcp__XcodeBuildMCP__discover_projs({
    workspaceRoot: "/Users/kbaba/Workbox/PriconneDB"
})
```

### スキーム一覧

```
mcp__XcodeBuildMCP__list_schemes({
    projectPath: "/Users/kbaba/Workbox/PriconneDB/PriconneDB.xcodeproj"
})
```

### クリーン

```
mcp__XcodeBuildMCP__clean({
    projectPath: "/Users/kbaba/Workbox/PriconneDB/PriconneDB.xcodeproj",
    scheme: "PriconneDB"
})
```

### シミュレータ一覧

```
mcp__XcodeBuildMCP__list_sims()
```

### テスト実行

```
mcp__XcodeBuildMCP__test_sim({
    projectPath: "/Users/kbaba/Workbox/PriconneDB/PriconneDB.xcodeproj",
    scheme: "PriconneDB",
    simulatorName: "iPhone 17 Pro"
})
```

## apple-docs

Apple公式ドキュメントを検索・取得するMCPツールです。

### ドキュメント検索

```
mcp__apple-docs__search_apple_docs({
    query: "SwiftUI List",
    type: "documentation"
})
```

type:
- `all`: すべて
- `documentation`: APIリファレンス・ガイド
- `sample`: コードサンプル

### ドキュメント詳細取得

```
mcp__apple-docs__get_apple_doc_content({
    url: "https://developer.apple.com/documentation/swiftui/list"
})
```

### テクノロジー一覧

```
mcp__apple-docs__list_technologies({
    category: "App frameworks",
    language: "swift"
})
```

### フレームワークシンボル検索

```
mcp__apple-docs__search_framework_symbols({
    framework: "swiftui",
    symbolType: "struct",
    namePattern: "*View"
})
```

### サンプルコード検索

```
mcp__apple-docs__get_sample_code({
    searchQuery: "SwiftUI animation",
    framework: "SwiftUI"
})
```

### WWDC動画一覧

```
mcp__apple-docs__list_wwdc_videos({
    year: "2024",
    topic: "swiftui-ui-frameworks"
})
```

### WWDCコンテンツ検索

```
mcp__apple-docs__search_wwdc_content({
    query: "@Observable",
    searchIn: "both",
    year: "2024"
})
```

### WWDC動画詳細

```
mcp__apple-docs__get_wwdc_video({
    year: "2024",
    videoId: "10101",
    includeTranscript: true,
    includeCode: true
})
```

## Firebase MCP

Firebase関連の操作を行うMCPツールです。

### 環境情報取得

```
mcp__firebase__firebase_get_environment()
```

### プロジェクト一覧

```
mcp__firebase__firebase_list_projects()
```

### アプリ一覧

```
mcp__firebase__firebase_list_apps({
    platform: "ios"
})
```

### SDK設定取得

```
mcp__firebase__firebase_get_sdk_config({
    platform: "ios"
})
```

### セキュリティルール取得

```
mcp__firebase__firebase_get_security_rules({
    type: "firestore"
})
```

## 開発フロー

コード変更後は以下の順序で実行:

1. **SwiftFormat**: コードフォーマット
   ```bash
   swiftformat Packages/
   ```

2. **SwiftLint**: コーディング規約チェック
   ```bash
   swiftlint lint Packages/
   ```

3. **XcodeBuildMCP**: ビルド確認
   ```
   mcp__XcodeBuildMCP__build_sim({
       projectPath: "/Users/kbaba/Workbox/PriconneDB/PriconneDB.xcodeproj",
       scheme: "PriconneDB",
       simulatorName: "iPhone 17 Pro"
   })
   ```
