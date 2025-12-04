#!/bin/bash
#
# 未使用コードチェックスクリプト
#
# 使用方法:
#   ./bin/check-unused-code.sh [オプション]
#
# オプション:
#   --format <format>  出力フォーマット (xcode, json, csv, checkstyle)
#   --scheme <scheme>  対象スキーム (デフォルト: PriconneDB)
#   --quiet            静かなモード
#   --strict           警告を厳格モードで扱う
#   --verbose          冗長な出力
#   --help             ヘルプを表示
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CHECK_UNUSED_CODE_DIR="$SCRIPT_DIR/CheckUnusedCode"

# peripheryの存在確認
if ! command -v periphery &> /dev/null; then
    echo "Error: peripheryがインストールされていません"
    echo "インストール方法: brew install periphery"
    exit 1
fi

cd "$CHECK_UNUSED_CODE_DIR"

echo "ビルド中..."
swift build -c release --quiet

echo ""
swift run -c release CheckUnusedCode "$@"
