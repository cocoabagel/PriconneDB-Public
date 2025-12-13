# Swift DocC

PriconneDBプロジェクトのドキュメント生成パターンです。

## 概要

DocCはApple公式のドキュメントコンパイラです。Swift/SwiftUIのAPIドキュメントを生成し、静的HTMLとしてホスティングできます。

## ドキュメント生成

### 基本コマンド

```bash
# 1. ドキュメントビルド（.doccarchive生成）
xcodebuild docbuild \
  -scheme PriconneDB \
  -destination 'generic/platform=iOS' \
  -derivedDataPath .build/docbuild

# 2. 静的HTML変換
xcrun docc process-archive transform-for-static-hosting \
  .build/docbuild/Build/Products/Debug-iphoneos/ModuleName.doccarchive \
  --output-path docs/ModuleName \
  --hosting-base-path ModuleName
```

### 全モジュール一括生成

```bash
# ドキュメントビルド
xcodebuild docbuild \
  -scheme PriconneDB \
  -destination 'generic/platform=iOS' \
  -derivedDataPath .build/docbuild

# 各モジュールをHTML変換
for archive in \
  AppFeature AttackTeamListFeature CreateAttackTeamFeature CreateDefenseTeamFeature \
  DefenseTeamListFeature FilterUnitsFeature SearchViewFeature Environment \
  Entity Networking Storage SharedViews Resources; do
  xcrun docc process-archive transform-for-static-hosting \
    ".build/docbuild/Build/Products/Debug-iphoneos/${archive}.doccarchive" \
    --output-path "docs/${archive}" \
    --hosting-base-path "${archive}"
done

# ビルドディレクトリ削除
rm -rf .build/docbuild
```

## ディレクトリ構造

```
docs/
├── index.html              # トップページ（手動作成）
├── AppFeature/
│   ├── css/
│   ├── data/
│   ├── documentation/
│   │   └── appfeature/
│   │       └── index.html
│   ├── img/
│   ├── js/
│   └── index.html
├── Entity/
│   └── documentation/
│       └── entity/
│           ├── attackteam/
│           ├── defenseteam/
│           ├── gameunit/
│           └── index.html
└── ... (各モジュール)
```

## ドキュメントアクセス

### ローカルプレビュー

```bash
cd docs && python3 -m http.server 8000
# ブラウザで http://localhost:8000 を開く
```

### GitHub Pages

1. リポジトリ設定 → Pages → Source: `main` branch, `/docs` folder
2. `https://<username>.github.io/<repo>/` でアクセス可能

## ドキュメントコメント

### 基本構文

```swift
/// ユニットを表すデータモデル
///
/// ゲーム内のキャラクターユニットを表現します。
/// Firestoreの`units`コレクションに対応します。
///
/// - Note: `Sendable`に準拠しており、並行処理で安全に使用できます。
public struct GameUnit: Codable, Identifiable, Sendable {
    /// ユニットの一意識別子
    public let id: String

    /// ユニット名（表示用）
    public let name: String

    /// 隊列位置（小さいほど前衛）
    ///
    /// 値の範囲は通常100〜900です。
    public let position: Int
}
```

### パラメータ・戻り値

```swift
/// 防衛チームを検索します
///
/// 指定されたメンバー名でフィルタリングし、
/// 条件に一致するチームを返します。
///
/// - Parameters:
///   - memberNames: 検索するメンバー名の配列
///   - limit: 取得する最大件数（デフォルト: 20）
/// - Returns: 条件に一致する防衛チームの配列
/// - Throws: `FirestoreError` データ取得に失敗した場合
public func search(memberNames: [String], limit: Int = 20) async throws -> [DefenseTeam]
```

### コード例

```swift
/// チームを作成します
///
/// ## 使用例
///
/// ```swift
/// let team = DefenseTeam(
///     id: UUID().uuidString,
///     members: selectedUnits,
///     memberNames: selectedUnits.map(\.name)
/// )
/// try await client.createTeam(team)
/// ```
///
/// - Parameter team: 作成するチーム
public func createTeam(_ team: DefenseTeam) async throws
```

### ドキュメントカタログ（オプション）

より詳細なドキュメントを書く場合、`.docc`カタログを使用できます:

```
Packages/Entity/
├── Sources/
│   └── Entity/
│       └── GameUnit.swift
└── Entity.docc/
    ├── Entity.md           # モジュール概要
    ├── Articles/
    │   └── GettingStarted.md
    └── Resources/
        └── diagram.png
```

## DocCカタログ

### モジュール概要（Entity.md）

```markdown
# ``Entity``

PriconneDBのデータモデルを提供するモジュールです。

## Overview

このモジュールはFirestoreのドキュメント構造に対応した
Swift構造体を定義しています。

## Topics

### ゲームデータ

- ``GameUnit``
- ``DefenseTeam``
- ``AttackTeam``

### 選択状態

- ``SelectedUnit``
- ``AttackType``
```

### 記事（GettingStarted.md）

```markdown
# Getting Started with Entity

データモデルの基本的な使い方を説明します。

## Overview

EntityモジュールはFirestoreのデータ構造をSwiftで表現します。

## Creating a Defense Team

@Code(name: "CreateTeam.swift") {
    let team = DefenseTeam(
        id: UUID().uuidString,
        members: units,
        memberNames: units.map(\.name),
        lastUpdated: Date()
    )
}
```

## ベストプラクティス

### 1. すべてのpublicシンボルにドキュメントを書く

```swift
// Good
/// ユーザーの選択状態を永続化します
public struct SelectedUnitsStorage { ... }

// Bad
public struct SelectedUnitsStorage { ... }
```

### 2. 省略しない

```swift
// Good
/// 防衛チームの一覧を表示するView
public struct DefenseTeamListView: View { ... }

// Bad
/// 防衛チーム一覧
public struct DefenseTeamListView: View { ... }
```

### 3. 関連シンボルへのリンク

```swift
/// 攻撃チームを作成するView
///
/// ``DefenseTeam``に対する攻撃編成を作成します。
/// 作成後は``AttackTeamListView``に追加されます。
public struct CreateAttackTeamSelectUnitsView: View { ... }
```

## トラブルシューティング

### ドキュメントが生成されない

1. `public`宣言を確認（internal/privateはドキュメント化されない）
2. ドキュメントコメント（`///`）の構文を確認
3. クリーンビルド: `rm -rf .build/docbuild`

### シンボルグラフエラー

```bash
# Xcodeのキャッシュをクリア
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### 静的ホスティングで404

`--hosting-base-path`がデプロイ先のパスと一致しているか確認:

```bash
# GitHub Pagesの場合
--hosting-base-path "PriconneDB/ModuleName"
```
