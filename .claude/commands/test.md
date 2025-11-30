# Unit Tests

全Featureモジュールのユニットテストを実行します。

## 実行コマンド

```bash
bundle exec fastlane unit_tests
```

## 個別モジュールのテスト

```bash
bundle exec fastlane test_module module:モジュール名
```

利用可能なモジュール:
- AttackTeamListFeature
- CreateAttackTeamFeature
- CreateDefenseTeamFeature
- DefenseTeamListFeature
- FilterUnitsFeature
- SearchViewFeature

## テスト実行を依頼されたら

1. `bundle exec fastlane unit_tests` を実行
2. 失敗したテストがあれば修正
3. 再度テストを実行して全て成功することを確認

## モック生成

テスト用モックはSourceryで自動生成されます。

```bash
# モック再生成が必要な場合
sourcery
```

生成先: `Packages/Mocks/Sources/Generated/`
