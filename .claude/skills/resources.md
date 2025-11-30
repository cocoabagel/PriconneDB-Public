# Resources モジュール

アプリ全体で使用するカラーと画像アセットを管理するモジュールです。

## 場所

`Packages/Resources/`

## 構成

```
Packages/Resources/
├── Package.swift
└── Sources/
    ├── Resources.swift          # Color/Image extension
    └── Assets.xcassets/         # アセットカタログ
        ├── AccentColor.colorset # アクセントカラー
        ├── Close.imageset
        ├── Placeholder.imageset
        ├── emptyStar.imageset
        ├── filledStar.imageset
        ├── filled6Star.imageset
        ├── logo.imageset
        ├── search.imageset
        ├── smallEmptyStar.imageset
        ├── smallFlledStar.imageset
        ├── smalliFlled6Star.imageset
        └── uniqueEquipment.imageset
```

## 使用方法

### カラー

```swift
import Resources

// アクセントカラー
Text("Hello")
    .foregroundStyle(Color.appAccent)
```

### 画像

```swift
import Resources

// 画像を使用
Image.placeholder
Image.logo
Image.close

// 星アイコン（通常サイズ）
Image.emptyStar
Image.filledStar
Image.filled6Star

// 星アイコン（小サイズ）
Image.smallEmptyStar
Image.smallFilledStar
Image.smallFilled6Star

// その他
Image.search
Image.uniqueEquipment
```

## 新規アセット追加手順

### 1. 画像を追加する場合

1. `Assets.xcassets` に新しい imageset を作成
2. 1x, 2x, 3x の画像を配置
3. `Resources.swift` に静的プロパティを追加:

```swift
public extension Image {
    static let newImage = Image("newImage", bundle: Resources.bundle)
}
```

### 2. カラーを追加する場合

1. `Assets.xcassets` に新しい colorset を作成
2. Light/Dark モードの色を設定
3. `Resources.swift` に静的プロパティを追加:

```swift
public extension Color {
    static let newColor = Color("NewColor", bundle: Resources.bundle)
}
```

## 注意事項

- 必ず `bundle: Resources.bundle` を指定すること（SPMモジュールのため）
- 画像名は `Resources.swift` のプロパティ名と一致させる必要はないが、わかりやすい名前にすること
- 星アイコンは通常サイズ（`filledStar`等）と小サイズ（`smallFilledStar`等）の2種類がある
