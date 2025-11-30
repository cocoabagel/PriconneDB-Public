# Firestore設計パターン

PriconneDBプロジェクトのFirestore設計パターンです。

## FireStoreClient

### Actorパターン

```swift
public protocol FireStoreClientProtocol: Sendable {
    func fetchAllUnits() async throws -> [GameUnit]
    func fetchDefenseTeams(refresh: Bool, filterUnitNames: [String]) async throws -> [DefenseTeam]
}

public actor FireStoreClient: FireStoreClientProtocol {
    private let db: Firestore
    private let pageSize: Int
    private var lastDocument: DocumentSnapshot?

    public init(
        db: Firestore = Firestore.firestore(),
        pageSize: Int = 25
    ) {
        self.db = db
        self.pageSize = pageSize
    }
}
```

### ページネーション

```swift
public func fetchItems(refresh: Bool = false) async throws -> [Item] {
    if refresh {
        lastDocument = nil
    }

    var query: Query = db.collection("items")
        .order(by: "lastUpdated", descending: true)
        .limit(to: pageSize)

    if let lastDocument {
        query = query.start(afterDocument: lastDocument)
    }

    let snapshot = try await query.getDocuments()
    lastDocument = snapshot.documents.last

    return snapshot.documents.compactMap(Item.init(document:))
}
```

## クエリパターン

### 前方一致検索

FirestoreにはLIKE検索がないため、範囲クエリで前方一致を実現:

```swift
let prefix = "検索文字列"
let prefixEnd = prefix + "\u{f8ff}"  // Unicode最大文字

query = query
    .whereField("searchKey", isGreaterThanOrEqualTo: prefix)
    .whereField("searchKey", isLessThan: prefixEnd)
```

### Array Contains

配列内の要素を検索:

```swift
// 1つの値のみ指定可能
query = query.whereField("memberNames", arrayContains: "ユニット名")

// 複数値はarray-contains-any（OR条件）
query = query.whereField("tags", arrayContainsAny: ["tag1", "tag2"])
```

## Firestore制約

### 不等式フィルタ

1クエリで不等式フィルタは**1フィールドのみ**:

```swift
// Good - 1フィールド
query = query
    .whereField("memberNamesKey", isGreaterThanOrEqualTo: prefix)
    .whereField("memberNamesKey", isLessThan: prefixEnd)

// Bad - 2フィールド（エラー）
query = query
    .whereField("memberNamesKey", isGreaterThanOrEqualTo: prefix)
    .whereField("lastUpdated", isGreaterThan: startDate)
```

### OrderBy制約

不等式フィルタ使用時は同じフィールドでorderBy必須:

```swift
// Good
query = query
    .whereField("memberNamesKey", isGreaterThanOrEqualTo: prefix)
    .whereField("memberNamesKey", isLessThan: prefixEnd)
    .order(by: "memberNamesKey")

// Bad - orderByフィールドが一致しない
query = query
    .whereField("memberNamesKey", isGreaterThanOrEqualTo: prefix)
    .order(by: "lastUpdated")  // エラー！
```

### Array-Contains制約

1クエリに1つのみ:

```swift
// Good
query = query.whereField("memberNames", arrayContains: "ユニット名")

// Bad - 2つのarray-contains
query = query
    .whereField("memberNames", arrayContains: "ユニット1")
    .whereField("memberNames", arrayContains: "ユニット2")  // エラー！
```

## 検索用フィールド設計

### Array検索用フィールド

```
memberNames: ["ユニットA", "ユニットB", "ユニットC"]
```

- array-containsで1ユニット検索可能
- 複数ユニットAND検索はクライアント側でフィルター

### 前方一致検索用フィールド

```
memberNamesKey: "ユニットA,ユニットB,ユニットC"
```

- position順でソートしてカンマ区切り
- 検索時も同じ順序でソートして連結
- 範囲クエリで前方一致

## マイグレーションスクリプト

### 基本構造

```swift
@MainActor
private func migrateField() async {
    let db = Firestore.firestore()

    do {
        let snapshot = try await db.collection("teams").getDocuments()
        print("ドキュメント数: \(snapshot.documents.count)")

        var successCount = 0
        var skipCount = 0

        for document in snapshot.documents {
            // 既に存在する場合はスキップ
            if document.data()["newField"] != nil {
                skipCount += 1
                continue
            }

            do {
                // 新しいフィールド値を計算
                let newValue = calculateNewValue(from: document.data())

                try await document.reference.updateData([
                    "newField": newValue
                ])
                successCount += 1
            } catch {
                print("エラー: \(error)")
            }
        }

        print("成功: \(successCount), スキップ: \(skipCount)")
    } catch {
        print("失敗: \(error)")
    }
}
```

### 実行方法

```swift
// PriconneDBApp.swift
@main
struct PriconneDBApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .task {
                    // TODO: マイグレーション完了後に削除
                    await migrateField()
                }
        }
    }
}
```

## Entity設計

### Sendable準拠

```swift
public struct GameUnit: Sendable {
    public var name: String
    public var position: Int
    public var starRank: Int
    // ...
}
```

### Equatable

```swift
extension GameUnit: Equatable {
    public static func == (lhs: GameUnit, rhs: GameUnit) -> Bool {
        lhs.position == rhs.position && lhs.name == rhs.name
    }
}
```

### Identifiable

```swift
public struct DefenseTeam: Sendable, Identifiable {
    public var id: String {
        let memberNames = members.map(\.name).joined(separator: "-")
        let timestamp = String(created.timeIntervalSince1970)
        return "\(memberNames)-\(timestamp)"
    }
    // ...
}
```

### Documentイニシャライザ

```swift
public init?(document: QueryDocumentSnapshot) {
    guard
        let name = document.data()["name"] as? String,
        let position = document.data()["position"] as? Int
    else {
        return nil
    }

    self.name = name
    self.position = position
}
```

## 複合クエリの対処法

フィルター有無で異なるクエリを使い分け:

```swift
public func fetchItems(filterNames: [String] = []) async throws -> [Item] {
    var query: Query = db.collection("items")

    if !filterNames.isEmpty {
        // フィルター指定時: 検索フィールドで絞り込み
        let prefix = filterNames.joined(separator: ",")
        let prefixEnd = prefix + "\u{f8ff}"
        query = query
            .whereField("searchKey", isGreaterThanOrEqualTo: prefix)
            .whereField("searchKey", isLessThan: prefixEnd)
            .order(by: "searchKey")
    } else {
        // フィルターなし: 日付順で取得
        query = query
            .order(by: "lastUpdated", descending: true)
    }

    query = query.limit(to: pageSize)
    // ...
}
```
