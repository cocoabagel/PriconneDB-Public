#!/bin/bash
#
# ユニットメタデータ更新スクリプト
#
# 使用方法:
#   ./bin/update-metadata.sh [--delete-all] [--dry-run]
#
# オプション:
#   --delete-all  既存のユニットデータを全削除してから追加
#   --dry-run     実際には書き込まず、処理内容を表示のみ
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
UPDATE_METADATA_DIR="$SCRIPT_DIR/UpdateMetadata"
PLIST_PATH="$PROJECT_ROOT/PriconneDB/Assets/GoogleService-Info.plist"

# GoogleService-Info.plistの存在確認
if [ ! -f "$PLIST_PATH" ]; then
    echo "Error: GoogleService-Info.plistが見つかりません"
    echo "期待されるパス: $PLIST_PATH"
    exit 1
fi

echo "GoogleService-Info.plist: $PLIST_PATH"

cd "$UPDATE_METADATA_DIR"

echo "ビルド中..."
swift build

echo ""
echo "実行中..."
GOOGLE_SERVICE_INFO_PLIST="$PLIST_PATH" swift run UpdateMetadata "$@"
