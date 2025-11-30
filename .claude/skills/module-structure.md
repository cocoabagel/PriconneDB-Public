# モジュール構造

PriconneDBプロジェクトのモジュール構造パターンです。

## Package.swiftテンプレート

### Featureモジュール

```swift
// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "FeatureModule",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "FeatureModule",
            targets: ["FeatureModule"]
        )
    ],
    dependencies: [
        .package(path: "../Entity"),
        .package(path: "../Networking"),
        .package(path: "../Resources"),
        .package(path: "../SharedViews"),
        .package(path: "../Storage"),
    ],
    targets: [
        .target(
            name: "FeatureModule",
            dependencies: [
                "Entity",
                "Networking",
                "Resources",
                "SharedViews",
                "Storage",
            ]
        ),
        .testTarget(
            name: "FeatureModuleTests",
            dependencies: ["FeatureModule"]
        )
    ]
)
```

### Coreモジュール（Entity, Storage）

```swift
// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Storage",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "Storage",
            targets: ["Storage"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Storage",
            dependencies: []
        )
    ]
)
```

### Resourcesモジュール

```swift
// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Resources",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "Resources",
            targets: ["Resources"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Resources",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
```

## ディレクトリ構造

### Featureモジュール

```
Packages/FeatureModule/
├── Package.swift
├── Sources/
│   └── FeatureModule/
│       ├── FeatureView.swift
│       ├── FeatureViewModel.swift
│       └── Components/
│           ├── FeatureRow.swift
│           └── FeatureCell.swift
└── Tests/
    └── FeatureModuleTests/
        └── FeatureModuleTests.swift
```

### Resourcesモジュール

```
Packages/Resources/
├── Package.swift
└── Sources/
    └── Resources/
        ├── Resources.swift
        └── Resources/
            └── Assets.xcassets/
                ├── Icons/
                └── Images/
```

## リソースアクセス

### Bundle Extension

```swift
// Resources/Resources.swift
import Foundation

public enum Resources {
    public static let bundle = Bundle.module
}
```

### Image Extension

```swift
import SwiftUI

public extension Image {
    static let placeholder = Image("Placeholder", bundle: Resources.bundle)
    static let smallFilledStar = Image("smallFilledStar", bundle: Resources.bundle)
    static let smallFilled6Star = Image("smallFilled6Star", bundle: Resources.bundle)
    static let uniqueEquipment = Image("uniqueEquipment", bundle: Resources.bundle)
}
```

## モジュール依存関係

### 依存グラフ

```
AppFeature（エントリーポイント）
├── DefenseTeamListFeature
│   ├── Entity
│   ├── Networking
│   │   └── Entity
│   ├── Resources
│   ├── SharedViews
│   │   ├── Entity
│   │   ├── Resources
│   │   ├── Kingfisher
│   │   └── KingfisherWebP
│   └── Storage
└── SearchViewFeature
    ├── Entity
    ├── Networking
    ├── Resources
    ├── SharedViews
    └── Storage
```

### 依存関係ルール

1. **Feature → Core**: FeatureモジュールはCoreモジュール（Entity, Networking, Storage）に依存
2. **Core → External**: Coreモジュールは外部ライブラリに依存可能
3. **Feature ↔ Feature**: Featureモジュール同士は直接依存しない
4. **AppFeature → Feature**: AppFeatureのみが複数のFeatureモジュールを統合

## 共通コンポーネント

### SharedViewsモジュール

再利用可能なUIコンポーネント:

```swift
// SharedViews/UnitIconView.swift
public struct UnitIconView: View {
    private let unit: GameUnit
    private let size: CGFloat

    public init(unit: GameUnit, size: CGFloat) {
        self.unit = unit
        self.size = size
    }

    public var body: some View {
        KFImage(URL(string: unit.defaultIconURL))
            .setProcessors([WebPProcessor.default])
            .placeholder { Image.placeholder }
            .resizable()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
    }
}
```

### Storageモジュール

UserDefaults永続化:

```swift
// Storage/SelectedUnitsStorage.swift
public struct SelectedUnit: Codable, Sendable {
    public let name: String
    public let position: Int

    public init(name: String, position: Int) {
        self.name = name
        self.position = position
    }
}

public struct SelectedUnitsStorage: Sendable {
    private static let key = "selectedUnits"

    public static func save(units: [SelectedUnit]) {
        guard let data = try? JSONEncoder().encode(units) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    public static func load() -> [SelectedUnit] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let units = try? JSONDecoder().decode([SelectedUnit].self, from: data)
        else {
            return []
        }
        return units
    }
}
```

## 新規モジュール追加

### 手順

1. ディレクトリ作成:
```bash
mkdir -p Packages/NewFeature/Sources/NewFeature
mkdir -p Packages/NewFeature/Tests/NewFeatureTests
```

2. Package.swift作成

3. ソースファイル作成:
   - `NewFeatureView.swift`
   - `NewFeatureViewModel.swift`

4. 依存元のPackage.swiftに追加:
```swift
dependencies: [
    .package(path: "../NewFeature"),
],
targets: [
    .target(
        name: "AppFeature",
        dependencies: [
            "NewFeature",
        ]
    ),
]
```

5. Import追加:
```swift
import NewFeature
```

## 外部依存関係

### Kingfisher

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
    .package(url: "https://github.com/yeatse/KingfisherWebP.git", from: "1.0.0"),
],
targets: [
    .target(
        name: "SharedViews",
        dependencies: [
            "Kingfisher",
            .product(name: "KingfisherWebP", package: "KingfisherWebP"),
        ]
    ),
]
```

### Firebase

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.0.0"),
],
targets: [
    .target(
        name: "Networking",
        dependencies: [
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
        ]
    ),
]
```
