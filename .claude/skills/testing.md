# Testing

## フレームワーク

Swift Testing を使用する（XCTestではない）

参考: https://developer.apple.com/documentation/testing

## TDDスタイル

t-wadaスタイルのTDDラインに沿う:

1. Red: 失敗するテストを書く
2. Green: テストを通す最小限の実装
3. Refactor: リファクタリング

## 命名規則

`@Suite`と`@Test`のコメントは、クラス名・メソッド名と同じ内容なら省略する:

```swift
// Good - コメント省略
@Suite
struct SelectedUnitsStorageTests {
    @Test
    func save() { ... }
}

// Bad - 冗長なコメント
@Suite("SelectedUnitsStorageTests")
struct SelectedUnitsStorageTests {
    @Test("save")
    func save() { ... }
}
```

コメントが必要な場合（振る舞いの説明など）:

```swift
@Suite
struct SelectedUnitsStorageTests {
    @Test("空の配列を保存した場合は空配列を返す")
    func saveEmptyArray() { ... }
}
```

## テスト設計

必要最小限のテストのみ書く:

- 正常系の代表的なケース
- 境界値（空、nil、最大値など）
- 異常系で重要なケース

過剰なテストは避ける:

- 同じロジックを複数パターンでテストしない
- 自明な実装のテストは書かない
- フレームワークの機能をテストしない

## 構造

```swift
import Mocks
import Testing
@testable import TargetModule

@Suite
struct SomeFeatureTests {
    // MARK: - Setup

    let sut: SomeFeature
    let mockClient: SomeClientProtocolMock

    init() {
        mockClient = SomeClientProtocolMock()
        sut = SomeFeature(client: mockClient)
    }

    // MARK: - Tests

    @Test
    func fetchData() async throws {
        // Given
        mockClient.fetchDataReturnValue = [.stub]

        // When
        let result = try await sut.fetchData()

        // Then
        #expect(result.count == 1)
    }
}
```

## Mock生成

Sourceryによる自動生成を使用する。

### マーカープロトコル

```swift
import MockSupport

// 通常のMock
public protocol SomeStorageProtocol: AutoMockable {
    func save(data: Data)
    func load() -> Data?
}

// Sendable対応のMock（actor、async関数を持つプロトコル）
public protocol SomeClientProtocol: AutoMockableSendable {
    func fetch() async throws -> [Item]
}
```

### Mock生成コマンド

```bash
sourcery --config .sourcery.yaml
```

生成先: `Packages/Mocks/Sources/Generated/`

### 生成されるMockの構造

```swift
public final class SomeClientProtocolMock: SomeClientProtocol, @unchecked Sendable {
    public init() {}

    // MARK: - fetch
    public var fetchThrowableError: Error?
    public var fetchCallsCount = 0
    public var fetchReturnValue: [Item]!

    public func fetch() async throws -> [Item] {
        if let error = fetchThrowableError {
            throw error
        }
        fetchCallsCount += 1
        return fetchReturnValue
    }
}
```

### Mockの使い方

```swift
@Test
func fetchSuccess() async throws {
    // Given
    mockClient.fetchReturnValue = [.stub]

    // When
    await sut.fetch()

    // Then
    #expect(mockClient.fetchCallsCount == 1)
    #expect(sut.items.count == 1)
}

@Test
func fetchError() async {
    // Given
    mockClient.fetchThrowableError = SomeError.network

    // When
    await sut.fetch()

    // Then
    #expect(sut.items.isEmpty)
}
```
