#!/bin/bash
set -e

echo "⭐️$CI_XCODEBUILD_ACTION"

echo "⭐️Starting SonarCloud coverage upload process..."

# プロジェクトのルートディレクトリに移動
cd "$CI_PRIMARY_REPOSITORY_PATH"

# 環境変数のデバッグ出力
echo "⭐️Environment variables:"
echo "⭐️CI_DERIVED_DATA_PATH: $CI_DERIVED_DATA_PATH"
echo "⭐️CI_PRIMARY_REPOSITORY_PATH: $CI_PRIMARY_REPOSITORY_PATH"
echo "⭐️Current directory: $(pwd)"

# 複数の場所で.xcresultを検索
echo "⭐️Searching for xcresult files in multiple locations..."
SEARCH_PATHS=(
    "$CI_DERIVED_DATA_PATH/Logs/Test"
    "$CI_DERIVED_DATA_PATH/Build"
    "$CI_DERIVED_DATA_PATH"
)
RESULT_BUNDLE_PATH=$CI_DERIVED_DATA_PATH/Logs/Test/ResultBundle.xcresult

# ファイルまたはディレクトリの存在を確認
if [ -e "$RESULT_BUNDLE_PATH" ]; then
    echo "✅ ResultBundleが見つかりました: $RESULT_BUNDLE_PATH"
    # オプション: ファイルの詳細情報を表示
    ls -l "$RESULT_BUNDLE_PATH"
else
    echo "❌ ResultBundleが見つかりませんでした: $RESULT_BUNDLE_PATH"
fi

XCRESULT_PATH=""
for path in "${SEARCH_PATHS[@]}"; do
    echo "⭐️Searching in: $path"
    if [ -d "$path" ]; then
        ls -la "$path"
        FOUND_PATH=$(find "$path" -name "*.xcresult" -type d 2>/dev/null | head -n 1)
        if [ ! -z "$FOUND_PATH" ]; then
            XCRESULT_PATH="$FOUND_PATH"
            echo "⭐️⭐️⭐️Found xcresult at: $XCRESULT_PATH"
            break
        fi
    fi
done

if [ -z "$XCRESULT_PATH" ]; then
    echo "⭐️Error: No .xcresult file found. Showing directory structure:"
    echo "⭐️DerivedData contents:"
    ls -R "$CI_DERIVED_DATA_PATH"
fi
