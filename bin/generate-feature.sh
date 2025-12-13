#!/bin/bash
set -e

# View/ViewModel雛形生成スクリプト
# Usage: ./bin/generate-feature.sh <FeatureName> [ModuleName] [NavigationTitle]
# Example: ./bin/generate-feature.sh UserProfile UserProfileFeature "プロフィール"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$PROJECT_ROOT/Templates"

# 引数チェック
if [ -z "$1" ]; then
    echo "Usage: $0 <FeatureName> [ModuleName] [NavigationTitle]"
    echo ""
    echo "Arguments:"
    echo "  FeatureName     - Feature名 (例: UserProfile)"
    echo "  ModuleName      - モジュール名 (省略時: <FeatureName>Feature)"
    echo "  NavigationTitle - ナビゲーションタイトル (省略時: FeatureName)"
    echo ""
    echo "Example:"
    echo "  $0 UserProfile"
    echo "  $0 UserProfile UserProfileFeature \"プロフィール\""
    exit 1
fi

FEATURE_NAME="$1"
MODULE_NAME="${2:-${FEATURE_NAME}Feature}"
NAV_TITLE="${3:-$FEATURE_NAME}"
AUTHOR="${USER:-Developer}"
DATE=$(date "+%Y/%m/%d")

# 出力先ディレクトリ
MODULE_DIR="$PROJECT_ROOT/Packages/$MODULE_NAME"
SOURCES_DIR="$MODULE_DIR/Sources"
TESTS_DIR="$MODULE_DIR/Tests"

echo "Generating feature: $FEATURE_NAME"
echo "  Module: $MODULE_NAME"
echo "  Title: $NAV_TITLE"
echo "  Output: $MODULE_DIR"
echo ""

# Sourceryがインストールされているか確認
if ! command -v sourcery &> /dev/null; then
    echo "Error: sourcery is not installed."
    echo "Install with: brew install sourcery"
    exit 1
fi

# 出力ディレクトリ作成
mkdir -p "$SOURCES_DIR"
mkdir -p "$TESTS_DIR"

# Package.swift生成
echo "Generating Package.swift..."
sourcery \
    --templates "$TEMPLATES_DIR/Package.stencil" \
    --sources "$TEMPLATES_DIR" \
    --output "$MODULE_DIR/Package.swift" \
    --args "name=$FEATURE_NAME,module=$MODULE_NAME" \
    --disableCache

# View生成
echo "Generating ${FEATURE_NAME}View.swift..."
sourcery \
    --templates "$TEMPLATES_DIR/View.stencil" \
    --sources "$TEMPLATES_DIR" \
    --output "$SOURCES_DIR/${FEATURE_NAME}View.swift" \
    --args "name=$FEATURE_NAME,module=$MODULE_NAME,title=$NAV_TITLE,author=$AUTHOR,date=$DATE" \
    --disableCache

# ViewModel生成
echo "Generating ${FEATURE_NAME}ViewModel.swift..."
sourcery \
    --templates "$TEMPLATES_DIR/ViewModel.stencil" \
    --sources "$TEMPLATES_DIR" \
    --output "$SOURCES_DIR/${FEATURE_NAME}ViewModel.swift" \
    --args "name=$FEATURE_NAME,module=$MODULE_NAME,author=$AUTHOR,date=$DATE" \
    --disableCache

# Sourceryのヘッダーコメントを削除
for file in "$MODULE_DIR/Package.swift" "$SOURCES_DIR/${FEATURE_NAME}View.swift" "$SOURCES_DIR/${FEATURE_NAME}ViewModel.swift"; do
    if [ -f "$file" ]; then
        # "// DO NOT EDIT" と "// Generated using Sourcery" から始まる行を削除
        sed -i '' '/^\/\/ DO NOT EDIT/d' "$file"
        sed -i '' '/^\/\/ Generated using Sourcery/d' "$file"
        # 先頭の空行を削除
        sed -i '' '1{/^$/d;}' "$file"
    fi
done

echo ""
echo "生成されたファイル:"
echo "  - $MODULE_DIR/Package.swift"
echo "  - $SOURCES_DIR/${FEATURE_NAME}View.swift"
echo "  - $SOURCES_DIR/${FEATURE_NAME}ViewModel.swift"
echo ""
echo "次のステップ:"
echo "  1. AppFeatureのPackage.swiftにモジュールの依存関係を追加"
echo "  2. 他のFeatureからこのFeatureを呼び出す場合:"
echo "     - EnvironmentモジュールにBuilderViewを追加"
echo "     - ViewBuildableプロトコルにbuildメソッドを追加"
echo "     - AppViewBuilderとPreviewBuilderに実装を追加"
echo "  3. 機能のロジックを実装"
