# Update Unit Metadata

Firestoreのユニットメタデータを更新します。

## 実行コマンド

```bash
# ドライラン（確認用）
./bin/update-metadata.sh --dry-run

# 実際に更新
./bin/update-metadata.sh

# 全削除してから追加
./bin/update-metadata.sh --delete-all
```

## ユニットデータの追加・編集

`bin/UpdateMetadata/Sources/UnitData.swift` を編集してください。

```swift
Unit(name: "ユニット名", position: 100, starRank: 5, uniqueEquipment: true,
     star3IconURL: "https://...", star6IconURL: "https://...")
```

フィールド:
- `position`: 隊列位置（小さいほど前衛）
- `starRank`: 最大星ランク（5 or 6）
- `uniqueEquipment`: 専用装備の有無
- `star6IconURL`: 星6がない場合は省略可

## メタデータ更新を依頼されたら

1. `bin/UpdateMetadata/Sources/UnitData.swift` に新規ユニットを追加
2. ビルド確認: `cd bin/UpdateMetadata && swift build`
3. `./bin/update-metadata.sh --dry-run` で確認
4. 問題なければ `./bin/update-metadata.sh` で実行
