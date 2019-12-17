# CLAUDE.md

Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイドラインです。

## 基本ルール

- **日本語で回答してください**

## MCPサーバー

このプロジェクトでは以下のMCPサーバーを使用します。

### apple-docs

SwiftUIやiOS APIの最新ドキュメントを参照する際は、apple-docs MCPを使用してください。

```
# 使用例
mcp__apple-docs__search_documentation: SwiftUIのViewに関するドキュメントを検索
mcp__apple-docs__get_documentation: 特定のAPIの詳細ドキュメントを取得
```

### XcodeBuildMCP

コード変更後のビルドにはXcodeBuildMCPを使用してください。

```
# 使用例
mcp__XcodeBuildMCP__xcodebuild: プロジェクトをビルド
```

## 開発フロー

コードを変更した際は、以下の順序で実行してください。

1. **SwiftFormat実行**: コードフォーマットを統一
   ```bash
   swiftformat Packages/
   ```

2. **SwiftLint実行**: コーディング規約をチェック
   ```bash
   swiftlint lint Packages/
   ```

3. **XcodeBuildMCPでビルド**: ビルドエラーがないか確認
   ```
   mcp__XcodeBuildMCP__build_sim (scheme: PriconneDB, simulatorName: iPhone 17 Pro)
   ```
   ※ 最新のシミュレータを使用してください

4. **ユニットテスト実行**: テストが通ることを確認
   ```bash
   bundle exec fastlane unit_tests
   ```

## プロジェクト概要

PriconneDBは、プリンセスコネクト Re:Dive プレイヤー向けのiOSアプリです。バトルアリーナのチーム編成を共有・管理できます。Swift + Firebase で構築されています。

## ビルドコマンド

```bash
# プロジェクトを開く（.xcodeprojではなく必ずworkspaceを使用）
open PriconneDB.xcworkspace

# Xcodeでビルド
# Cmd+B: ビルド
# Cmd+R: 実行
# スキーム: PriconneDB

# SwiftLint実行
swiftlint lint Packages/
```

## アーキテクチャ

### モジュール構成 (Swift Package Manager)

`Packages/` 配下にモジュール分割:

```
Packages/
├── AppFeature/              # メインTabView、アプリのエントリーポイント
├── AttackTeamListFeature/   # 攻撃チーム一覧機能
├── CreateAttackTeamFeature/ # 攻撃チーム作成機能
├── CreateDefenseTeamFeature/# 防衛チーム作成機能
├── DefenseTeamListFeature/  # 防衛チーム一覧機能
├── FilterUnitsFeature/      # ユニットフィルター機能
├── SearchViewFeature/       # ユニット検索機能
├── Entity/                  # データモデル (GameUnit, DefenseTeam等)
├── Mocks/                   # テスト用モック（Sourcery生成）
├── MockSupport/             # モックサポートユーティリティ
├── Networking/              # FireStoreClient
├── Storage/                 # UserDefaults永続化
├── SharedViews/             # 共通UIコンポーネント（ToastView等）
└── Resources/               # 画像アセット
```

### 依存関係

```
AppFeature
├── DefenseTeamListFeature
│   ├── Entity
│   ├── Networking
│   ├── Resources
│   ├── SharedViews
│   └── Storage
└── SearchViewFeature
    ├── Entity
    ├── Networking
    ├── Resources
    ├── SharedViews
    └── Storage
```

### MVVMパターン (SwiftUI)

各Featureモジュールの構成:

```
Feature/
├── FeatureView.swift        # View層
├── FeatureViewModel.swift   # ViewModel層 (Inputs/Outputsパターン)
└── Components/              # サブビュー
```

### ViewModel Inputs/Outputsパターン

```swift
@MainActor
protocol ViewModelInputs {
    func fetchInitial() async
    func fetchMore() async
}

@MainActor
protocol ViewModelOutputs {
    var items: [Item] { get }
    var isLoading: Bool { get }
}

@MainActor
protocol ViewModelType: ViewModelInputs, ViewModelOutputs {
    var inputs: ViewModelInputs { get }
    var outputs: ViewModelOutputs { get }
}

@MainActor
@Observable
final class ViewModel: ViewModelType {
    private var _items: [Item] = []
    private var _isLoading = false

    var inputs: ViewModelInputs { self }
    var outputs: ViewModelOutputs { self }
}

// MARK: - ViewModelInputs
extension ViewModel: ViewModelInputs { ... }

// MARK: - ViewModelOutputs
extension ViewModel: ViewModelOutputs {
    var items: [Item] { _items }
    var isLoading: Bool { _isLoading }
}
```

## コーディング規約

### SwiftUI View構造

```swift
public struct FeatureView: View {
    @State private var viewModel = ViewModel()

    // 定数
    private let spacing: CGFloat = 8.0

    // アクセシビリティ対応
    @ScaledMetric(relativeTo: .body)
    private var iconSize: CGFloat = 64.0

    public init() {}

    public var body: some View { ... }
}

// MARK: - Private Views
private extension FeatureView {
    var contentSection: some View { ... }

    func itemCell(_ item: Item) -> some View { ... }
}
```

### 命名規則

- **Float値**: 常に `.0` を付ける（例: `64.0`, `8.0`, `16.0`）
- **Viewプロパティ**: セクションには `Section` サフィックス（例: `teamsSection`, `loadingSection`）
- **バッキングプロパティ**: `_` プレフィックス（例: `_isLoading`）

### SwiftLintルール

設定ファイル: `.swiftlint.yml`（`only_rules`で明示的にルールを指定）

重要なルール:
- `attributes`: 引数付きattributesは別行に配置
- `closure_body_length`: warning 50, error 100
- `trailing_closure`: 末尾クロージャを使用
- `line_length`: warning 195, error 210
- `modifier_order`: 修飾子の順序を統一（`nonisolated(unsafe) private` など）
- `sorted_imports`: import文をアルファベット順にソート
- `private_swiftui_state`: SwiftUIの`@State`は`private`必須

```swift
// Good
@ScaledMetric(relativeTo: .body)
private var iconSize: CGFloat = 64.0

// Bad
@ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 64.0
```

除外されたルール（`.swiftlint.yml`でコメントアウト）:
- `function_default_parameter_at_end`: デフォルト引数の位置を強制しない

### 並行処理

- ViewModelは `@MainActor` を付与
- Networking層は `actor` を使用
- Entityは `Sendable` に準拠
- キャッシュなど変更可能な共有状態は `nonisolated(unsafe)` で明示

```swift
public actor FireStoreClient: FireStoreClientProtocol { ... }
public struct GameUnit: Sendable { ... }

// ViewModelでのキャッシュ参照
nonisolated(unsafe) private let cache: DefenseTeamCacheProtocol
```

## Firebase連携

### Firestoreコレクション

- `teams`: 防衛チーム編成
  - `members`: ユニット配列
  - `memberNames`: ユニット名配列（array-contains検索用）
  - `memberNamesKey`: position順ソート済みユニット名（前方一致検索用）
  - `lastUpdated`: 更新日時
- `units`: ユニットマスタ

### Firestoreクエリパターン

```swift
// 前方一致検索
let prefix = filterUnitNames.joined(separator: ",")
let prefixEnd = prefix + "\u{f8ff}"
query = query
    .whereField("memberNamesKey", isGreaterThanOrEqualTo: prefix)
    .whereField("memberNamesKey", isLessThan: prefixEnd)
```

### Firestore制約

- 不等式フィルタは1フィールドのみ
- `array-contains` は1クエリに1つ
- 不等式使用時は同じフィールドで `orderBy` 必須

## UIパターン

### ページネーション先読み

```swift
var prefetchThreshold: Int { 5 }

func prefetchIfNeeded(currentItem: Item, allItems: [Item]) {
    guard let currentIndex = allItems.firstIndex(where: { $0.id == currentItem.id }) else {
        return
    }
    let remainingItems = allItems.count - currentIndex - 1
    if remainingItems <= prefetchThreshold {
        Task { await viewModel.inputs.fetchMore() }
    }
}
```

### ForEachでIdentifiable使用

```swift
// Good - Identifiable使用
ForEach(teams) { team in
    TeamRow(team: team)
}

// Bad - indices使用（Index out of rangeの原因）
ForEach(teams.indices, id: \.self) { index in
    TeamRow(team: teams[index])
}
```

### Liquid Glassスタイル (iOS 26+)

```swift
// マテリアル背景
.background(.regularMaterial)
.clipShape(RoundedRectangle(cornerRadius: 24.0))

// より透明度が高いマテリアル（iPad 2カラムなど）
.background(.thinMaterial)

// 検索タブ
Tab(role: .search) {
    SearchView()
}
```

### Toast通知

SharedViewsの`ToastView`を使用してフィードバックを表示:

```swift
// ViewModelにtoast状態を追加
private var _toastMessage: ToastMessage?
var toastMessage: ToastMessage? { _toastMessage }

func showToast(_ toast: ToastMessage) {
    _toastMessage = toast
}

// Viewで.toast()モディファイアを使用
.toast($viewModel.outputs.toastMessage)

// 成功・エラー・警告・情報の4種類
ToastMessage(message: "保存しました", style: .success)
ToastMessage(message: "エラーが発生しました", style: .error)
```

### iPad対応（2カラムレイアウト）

`horizontalSizeClass`でiPad/iPhoneを判別:

```swift
@Environment(\.horizontalSizeClass)
private var horizontalSizeClass

var body: some View {
    if horizontalSizeClass == .regular {
        iPadLayout
    } else {
        iPhoneLayout
    }
}

// iPadでは LazyVGrid で2カラム表示
var iPadLayout: some View {
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16.0) {
            ForEach(items) { item in
                ItemRow(item: item)
            }
        }
    }
}
```

### コンテキストメニュー（長押し操作）

iPadでスワイプ削除が使えない場合などに使用:

```swift
.contextMenu {
    Button(role: .destructive) {
        // 削除処理
    } label: {
        Label("削除", systemImage: "trash")
    }
}
```

## 主要な依存関係

### Swift Package Manager

- **Firebase**: FirebaseFirestore
- **Kingfisher**: 画像読み込み + WebP対応
- **KingfisherWebP**: WebPプロセッサ

### 画像読み込み

```swift
KFImage(URL(string: unit.iconURL))
    .setProcessors([WebPProcessor.default])
    .placeholder { Image.placeholder }
    .fade(duration: 0.2)
    .resizable()
```

## よくあるタスク

### 新規Featureモジュール追加

1. `Packages/` に新規ディレクトリ作成
2. `Package.swift` 作成（iOS .v26, swift-tools-version: 6.2）
3. View, ViewModel作成
4. AppFeatureの依存関係に追加

### Firestoreマイグレーション

```swift
// PriconneDBApp.swiftに一時的に追加
.task {
    await migrateSomeField()
}

@MainActor
private func migrateSomeField() async {
    let db = Firestore.firestore()
    let snapshot = try await db.collection("teams").getDocuments()
    for document in snapshot.documents {
        // 更新処理
    }
}
```

## テスト

### ユニットテスト実行

fastlaneを使用してユニットテストを実行します。

```bash
# 全モジュールのテストを実行
bundle exec fastlane unit_tests

# 個別モジュールのテストを実行
bundle exec fastlane test_module module:DefenseTeamListFeature
```

### テスト対象モジュール

- AttackTeamListFeature
- CreateAttackTeamFeature
- CreateDefenseTeamFeature
- DefenseTeamListFeature
- FilterUnitsFeature
- SearchViewFeature

### ViewModelテストの書き方

Swift Testingフレームワークを使用します。

```swift
import Entity
import Foundation
import Mocks
import Testing
@testable import SomeFeature

@Suite
@MainActor
struct SomeViewModelTests {
    let mockClient: FireStoreClientProtocolMock
    let sut: SomeViewModel

    init() {
        mockClient = FireStoreClientProtocolMock()
        sut = SomeViewModel(client: mockClient)
    }

    @Test
    func fetchItems() async {
        // Given
        let items = [Item.stub()]
        mockClient.fetchItemsReturnValue = items

        // When
        await sut.inputs.fetchItems()

        // Then
        #expect(mockClient.fetchItemsCallsCount == 1)
        #expect(sut.outputs.items.count == 1)
    }
}
```

重要なポイント:
- `@Suite` と `@MainActor` を構造体に付与
- `Foundation` をインポート（`NSError`等を使用する場合）
- `Mocks` モジュールのモッククラスを使用
- Given/When/Then パターンでテストを記述

## 複雑なタスクの進め方

複雑なタスク（新規機能追加、大規模リファクタリング等）は、以下の手順で進めてください。

### 1. Planモードで計画を立てる

`EnterPlanMode` を使用して計画モードに入り、実装方針を策定します。

計画モードでは以下を行います:
- コードベースの調査（Glob, Grep, Read）
- 既存パターンの把握
- 実装ステップの洗い出し
- 影響範囲の特定

計画が完成したら `ExitPlanMode` でユーザーの承認を得ます。

### 2. サブエージェントに実装を任せる

`Task` ツールを使用してサブエージェントに実装を委任します。

```
Task({
    subagent_type: "general-purpose",
    description: "Implement feature X",
    prompt: "詳細な実装指示..."
})
```

サブエージェントの種類:
- `general-purpose`: 複雑なマルチステップタスク、コード検索
- `Explore`: コードベース探索、ファイル検索、キーワード検索

### 3. 並列実行

独立したタスクは並列で実行して効率化します。

```
// 複数のTaskを同時に呼び出し
Task({ subagent_type: "Explore", prompt: "検索タスク1" })
Task({ subagent_type: "Explore", prompt: "検索タスク2" })
```

### 例: 新規Featureモジュール追加

1. **Plan**: 既存モジュール構造を調査、依存関係を確認
2. **Task 1**: Package.swift作成
3. **Task 2**: View/ViewModel作成
4. **Task 3**: 依存元モジュールの更新
5. **検証**: SwiftFormat → SwiftLint → ビルド

## ユニットメタデータ更新

Firestoreの`units`コレクションを更新するCLIツールがあります。

### 場所

```
bin/
├── update-metadata.sh       # 実行スクリプト
└── UpdateMetadata/          # Swift Package
    └── Sources/
        ├── main.swift       # エントリーポイント
        ├── Unit.swift       # Unitモデル
        └── UnitData.swift   # ユニットデータ定義
```

### 使用方法

```bash
# ドライラン（実際には書き込まない）
./bin/update-metadata.sh --dry-run

# データを追加
./bin/update-metadata.sh

# 既存データを全削除してから追加
./bin/update-metadata.sh --delete-all
```

### 新規ユニット追加

`bin/UpdateMetadata/Sources/UnitData.swift` に追加:

```swift
Unit(name: "ユニット名", position: 100, starRank: 5, uniqueEquipment: true,
     star3IconURL: "https://...", star6IconURL: "https://...")
```

- `position`: 隊列位置（小さいほど前衛）
- `starRank`: 最大星ランク（5 or 6）
- `uniqueEquipment`: 専用装備の有無
- `star6IconURL`: 星6がない場合は省略可

## 重要な設定

- 対象iOS: 26.0以上
- Swiftツールバージョン: 6.2
- Bundle ID: com.ayakosayama.PriconneDB
