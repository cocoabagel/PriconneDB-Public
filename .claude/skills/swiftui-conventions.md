# SwiftUI コーディング規約

PriconneDBプロジェクトのSwiftUIコーディング規約です。

## View構造

### 基本構造

```swift
public struct FeatureView: View {
    // 1. State/Bindingプロパティ
    @State private var viewModel = ViewModel()
    @State private var isPresented = false

    // 2. 定数 (private let)
    private let maxItems = 5
    private let spacing: CGFloat = 8.0

    // 3. ScaledMetric（アクセシビリティ対応）
    @ScaledMetric(relativeTo: .body)
    private var iconSize: CGFloat = 64.0

    // 4. 公開イニシャライザ
    public init() {}

    // 5. Body
    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("タイトル")
                .task {
                    await viewModel.inputs.fetchInitial()
                }
        }
    }
}

// MARK: - Private Views
private extension FeatureView {
    var content: some View { ... }

    var listSection: some View { ... }

    @ViewBuilder var loadingSection: some View {
        if viewModel.outputs.isLoading {
            ProgressView()
        }
    }

    func itemCell(_ item: Item) -> some View { ... }
}
```

### 命名規則

- **Sectionサフィックス**: Viewプロパティには`Section`を付ける（例: `teamsSection`, `loadingSection`）
- **Float値**: 必ず`.0`を付ける（例: `64.0`, `8.0`, `16.0`）
- **バッキングプロパティ**: `_`プレフィックス（例: `_isLoading`, `_items`）

## ViewModelパターン

### Inputs/Outputsプロトコル

```swift
@MainActor
protocol FeatureViewModelInputs {
    func fetchInitial() async
    func fetchMore() async
    func refresh() async
}

@MainActor
protocol FeatureViewModelOutputs {
    var items: [Item] { get }
    var isLoading: Bool { get }
    var hasMorePages: Bool { get }
}

@MainActor
protocol FeatureViewModelType: FeatureViewModelInputs, FeatureViewModelOutputs {
    var inputs: FeatureViewModelInputs { get }
    var outputs: FeatureViewModelOutputs { get }
}
```

### 実装

```swift
@MainActor
@Observable
final class FeatureViewModel: FeatureViewModelType {
    // プライベートバッキングプロパティ
    private var _items: [Item] = []
    private var _isLoading = false
    private var _hasMorePages = true

    // プロトコル準拠
    var inputs: FeatureViewModelInputs { self }
    var outputs: FeatureViewModelOutputs { self }

    // 依存関係
    private let client: ClientProtocol

    init(client: ClientProtocol = Client()) {
        self.client = client
    }
}

// MARK: - FeatureViewModelInputs
extension FeatureViewModel: FeatureViewModelInputs {
    func fetchInitial() async {
        _isLoading = true
        defer { _isLoading = false }

        do {
            let items = try await client.fetchItems(refresh: true)
            _items = items
            _hasMorePages = !items.isEmpty
        } catch {
            print("エラー: \(error.localizedDescription)")
        }
    }

    func fetchMore() async {
        guard !_isLoading, _hasMorePages else { return }
        // ...
    }

    func refresh() async {
        _hasMorePages = true
        await fetchInitial()
    }
}

// MARK: - FeatureViewModelOutputs
extension FeatureViewModel: FeatureViewModelOutputs {
    var items: [Item] { _items }
    var isLoading: Bool { _isLoading }
    var hasMorePages: Bool { _hasMorePages }
}
```

## ForEachパターン

### Identifiable使用（推奨）

```swift
// Good - Identifiableプロトコル
ForEach(items) { item in
    ItemRow(item: item)
}

// Good - keyPath指定
ForEach(items, id: \.name) { item in
    ItemRow(item: item)
}
```

### indices使用禁止

```swift
// Bad - Index out of rangeの原因
ForEach(items.indices, id: \.self) { index in
    ItemRow(item: items[index])
}
```

## ページネーション

### 先読みパターン

```swift
private extension ListView {
    var prefetchThreshold: Int { 5 }

    func prefetchIfNeeded(currentItem: Item, allItems: [Item]) {
        guard let currentIndex = allItems.firstIndex(where: { $0.id == currentItem.id }) else {
            return
        }

        let remainingItems = allItems.count - currentIndex - 1
        if remainingItems <= prefetchThreshold {
            Task {
                await viewModel.inputs.fetchMore()
            }
        }
    }
}
```

### 使用例

```swift
ForEach(items) { item in
    ItemRow(item: item)
        .onAppear {
            prefetchIfNeeded(currentItem: item, allItems: items)
        }
}
```

## Rowコンポーネント

### 構造

```swift
struct ItemRow: View {
    private let item: Item
    private let maxSlots = 5
    private let spacing: CGFloat = 8.0

    @ScaledMetric(relativeTo: .body)
    private var iconSize: CGFloat = 64.0

    init(item: Item) {
        self.item = item
    }

    var body: some View {
        HStack(spacing: spacing) {
            // コンテンツ
        }
        .padding(.vertical, 4.0)
    }
}
```

## Material & Liquid Glass (iOS 26以上)

### マテリアル背景

```swift
.background(.regularMaterial)
.clipShape(RoundedRectangle(cornerRadius: 24.0))
```

### 空スロットスタイル

```swift
Circle()
    .fill(.ultraThinMaterial)
    .frame(width: iconSize, height: iconSize)
    .overlay {
        Circle()
            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.0)
    }
```

### 検索タブ

```swift
TabView {
    Tab("防衛", systemImage: "shield.fill") {
        DefenseTeamListView()
    }

    Tab(role: .search) {
        SearchView()
    }
}
```

## SwiftLint注意点

### Attributes

引数付きattributesは別行:

```swift
// Good
@ScaledMetric(relativeTo: .body)
private var iconSize: CGFloat = 64.0

// Bad
@ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 64.0
```

引数なしattributesは同一行:

```swift
// Good
@ViewBuilder var content: some View { ... }

// Bad
@ViewBuilder
var content: some View { ... }
```

### 末尾クロージャ

```swift
// Good
SelectedUnitsBar(selectedUnits: units) { unit in
    viewModel.inputs.removeSelection(unit)
}

// Bad
SelectedUnitsBar(
    selectedUnits: units,
    onRemove: { unit in
        viewModel.inputs.removeSelection(unit)
    }
)
```

### Guardフォーマット

```swift
// Good
guard
    let data = UserDefaults.standard.data(forKey: key),
    let items = try? JSONDecoder().decode([Item].self, from: data)
else {
    return []
}

// Bad
guard let data = UserDefaults.standard.data(forKey: key),
      let items = try? JSONDecoder().decode([Item].self, from: data) else {
    return []
}
```
