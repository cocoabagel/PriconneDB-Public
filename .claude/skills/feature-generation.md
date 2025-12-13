# Feature生成

Sourceryテンプレートを使用した新規Featureモジュールの生成方法です。

## 生成コマンド

```bash
./bin/generate-feature.sh <FeatureName> [ModuleName] [NavigationTitle]

# 例
./bin/generate-feature.sh UserProfile
./bin/generate-feature.sh UserProfile UserProfileFeature "プロフィール"
```

## 引数

| 引数 | 必須 | 説明 | デフォルト |
|------|------|------|-----------|
| FeatureName | ○ | Feature名（PascalCase） | - |
| ModuleName | - | モジュール名 | `<FeatureName>Feature` |
| NavigationTitle | - | ナビゲーションタイトル | FeatureName |

## 生成されるファイル

```
Packages/<ModuleName>/
├── Package.swift              # SPMパッケージ定義
├── Sources/
│   ├── <Name>View.swift       # SwiftUI View
│   └── <Name>ViewModel.swift  # ViewModel（Inputs/Outputsパターン）
└── Tests/                     # テスト用ディレクトリ（空）
```

## テンプレートファイル

```
Templates/
├── Package.stencil     # Package.swiftテンプレート
├── View.stencil        # Viewテンプレート
└── ViewModel.stencil   # ViewModelテンプレート
```

## 生成後の手順

### 1. AppFeatureへの依存追加

`Packages/AppFeature/Package.swift`:

```swift
dependencies: [
    .package(path: "../NewFeature"),
    // ...
],
targets: [
    .target(
        name: "AppFeature",
        dependencies: [
            "NewFeature",
            // ...
        ]
    )
]
```

### 2. 他のFeatureから参照する場合

他のFeatureモジュールからこのFeatureを呼び出す場合は、Environmentモジュールを更新します。

#### ViewBuildable.swift

```swift
@MainActor
public protocol ViewBuildable: Sendable {
    // 既存のメソッド...

    func buildNewFeatureView(param: String) -> AnyView
}
```

#### NewFeatureBuilderView.swift（新規作成）

```swift
import SwiftUI

public struct NewFeatureBuilderView: View {
    @Environment(\.viewBuilder)
    private var viewBuilder

    private let param: String

    public init(param: String) {
        self.param = param
    }

    public var body: some View {
        if let viewBuilder {
            viewBuilder.buildNewFeatureView(param: param)
        } else {
            EmptyView()
        }
    }
}
```

#### PreviewBuilder.swift

```swift
public func buildNewFeatureView(param: String) -> AnyView {
    AnyView(
        Text("NewFeatureView Preview")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    )
}
```

#### AppViewBuilder.swift

```swift
import NewFeature

public func buildNewFeatureView(param: String) -> AnyView {
    AnyView(NewFeatureView(param: param))
}
```

### 3. MainTabViewに追加（タブとして追加する場合）

```swift
Tab("新機能", systemImage: "star") {
    NewFeatureView()
}
```

## 生成されるViewの構造

```swift
import Environment
import SwiftUI

public struct NewFeatureView: View {
    @State private var viewModel: NewFeatureViewModelType = NewFeatureViewModel()

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    public init() {}

    public var body: some View {
        NavigationStack {
            Group {
                if horizontalSizeClass == .regular {
                    iPadLayout      // iPad用2カラムレイアウト
                } else {
                    iPhoneLayout    // iPhone用リストレイアウト
                }
            }
            .navigationTitle("タイトル")
            .task {
                await viewModel.inputs.fetchInitial()
            }
        }
    }
}

#Preview {
    NewFeatureView()
        .environment(\.viewBuilder, PreviewBuilder())
}
```

## 生成されるViewModelの構造

```swift
@MainActor
protocol NewFeatureViewModelInputs {
    func fetchInitial() async
    func fetchMore() async
}

@MainActor
protocol NewFeatureViewModelOutputs {
    var items: [String] { get }
    var isLoading: Bool { get }
    var hasMorePages: Bool { get }
}

@MainActor
protocol NewFeatureViewModelType {
    var inputs: NewFeatureViewModelInputs { get }
    var outputs: NewFeatureViewModelOutputs { get }
}

@MainActor
@Observable
final class NewFeatureViewModel: NewFeatureViewModelType {
    private var _items: [String] = []
    private var _isLoading = false
    private var _hasMorePages = true

    var inputs: NewFeatureViewModelInputs { self }
    var outputs: NewFeatureViewModelOutputs { self }

    init() {}
}
```

## 依存関係

生成されるPackage.swiftには以下の依存関係が含まれます:

- Entity
- Environment
- Networking
- Resources
- SharedViews
- Storage
- Mocks（テスト用）

## カスタマイズ

### テンプレートの編集

`Templates/`ディレクトリ内の`.stencil`ファイルを編集することで、生成されるコードをカスタマイズできます。

Sourceryテンプレート構文:
- `{{ argument.name }}` - 引数の参照
- `{% if condition %}...{% endif %}` - 条件分岐
- `{% for item in items %}...{% endfor %}` - ループ

### 必要に応じて依存関係を調整

生成後、不要な依存関係があればPackage.swiftから削除してください。

```swift
// Networkingが不要な場合
dependencies: [
    "Entity",
    "Environment",
    // "Networking",  // 削除
    "Resources",
    "SharedViews",
    "Storage"
]
```
