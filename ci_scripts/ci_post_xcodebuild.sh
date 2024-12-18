#!/bin/bash
set -e

# 環境変数のデバッグ出力
echo "⭐️Environment variables:"
echo "Current directory: $(pwd)"
echo "CI: $CI"
echo "CI_BUILD_ID: $CI_BUILD_ID"
echo "CI_BUILD_NUMBER: $CI_BUILD_NUMBER"
echo "CI_BUILD_URL: $CI_BUILD_URL"
echo "CI_BUNDLE_ID: $CI_BUNDLE_ID"
echo "CI_COMMIT: $CI_COMMIT"
echo "CI_DERIVED_DATA_PATH: $CI_DERIVED_DATA_PATH"
echo "CI_PRIMARY_REPOSITORY_PATH: $CI_PRIMARY_REPOSITORY_PATH"
echo "CI_PRODUCT: $CI_PRODUCT"
echo "CI_PRODUCT_ID: $CI_PRODUCT_ID"
echo "CI_PRODUCT_PLATFORM: $CI_PRODUCT_PLATFORM"
echo "CI_PROJECT_FILE_PATH: $CI_PROJECT_FILE_PATH"
echo "CI_START_CONDITION: $CI_START_CONDITION"
echo "CI_TEAM_ID: $CI_TEAM_ID"
echo "CI_WORKFLOW: $CI_WORKFLOW"
echo "CI_WORKFLOW_ID: $CI_WORKFLOW_ID"
echo "CI_WORKSPACE_PATH: $CI_WORKSPACE_PATH"
echo "CI_XCODE_CLOUD: $CI_XCODE_CLOUD"
echo "CI_XCODE_PROJECT: $CI_XCODE_PROJECT"
echo "CI_XCODE_SCHEME: $CI_XCODE_SCHEME"
echo "CI_XCODEBUILD_ACTION: $CI_XCODEBUILD_ACTION"
echo "CI_XCODEBUILD_EXIT_CODE: $CI_XCODEBUILD_EXIT_CODE"
echo "CI_BRANCH: $CI_BRANCH"
echo "CI_TAG: $CI_TAG"
echo "CI_GIT_REF: $CI_GIT_REF"
echo "CI_PULL_REQUEST_HTML_URL: $CI_PULL_REQUEST_HTML_URL"
echo "CI_PULL_REQUEST_NUMBER: $CI_PULL_REQUEST_NUMBER"
echo "CI_PULL_REQUEST_SOURCE_BRANCH: $CI_PULL_REQUEST_SOURCE_BRANCH"
echo "CI_PULL_REQUEST_SOURCE_COMMIT: $CI_PULL_REQUEST_SOURCE_COMMIT"
echo "CI_PULL_REQUEST_SOURCE_REPO: $CI_PULL_REQUEST_SOURCE_REPO"
echo "CI_PULL_REQUEST_TARGET_BRANCH: $CI_PULL_REQUEST_TARGET_BRANCH"
echo "CI_PULL_REQUEST_TARGET_COMMIT: $CI_PULL_REQUEST_TARGET_COMMIT"
echo "CI_PULL_REQUEST_TARGET_REPO: $CI_PULL_REQUEST_TARGET_REPO"

echo "CI_RESULT_BUNDLE_PATH: $CI_RESULT_BUNDLE_PATH"
echo "CI_TEST_DESTINATION_DEVICE_TYPE: $CI_TEST_DESTINATION_DEVICE_TYPE"
echo "CI_TEST_DESTINATION_RUNTIME: $CI_TEST_DESTINATION_RUNTIME"
echo "CI_TEST_DESTINATION_UDID: $CI_TEST_DESTINATION_UDID"
echo "CI_TEST_PLAN: $CI_TEST_PLAN"
echo "CI_TEST_PRODUCTS_PATH: $CI_TEST_PRODUCTS_PATH"

echo "CI_AD_HOC_SIGNED_APP_PATH: $CI_AD_HOC_SIGNED_APP_PATH"
echo "CI_APP_STORE_SIGNED_APP_PATH: $CI_APP_STORE_SIGNED_APP_PATH"
echo "CI_ARCHIVE_PATH: $CI_ARCHIVE_PATH"
echo "CI_DEVELOPMENT_SIGNED_APP_PATH: $CI_DEVELOPMENT_SIGNED_APP_PATH"
echo "CI_DEVELOPER_ID_SIGNED_APP_PATH: $CI_DEVELOPER_ID_SIGNED_APP_PATH"

# ディレクトリパス
BASE_DIR="/Volumes/workspace/repository"

# ディレクトリ構造を出力（findとlsを使用）
echo "🗂️ ディレクトリ構造:"
cd "$BASE_DIR"
find . -maxdepth 6 -type d | sort | sed -e "s/[^-][^\/]*\// |/g" -e "s/|\([^ ]\)/|-\1/"

echo -e "\n\n📄 全ファイルリスト (相対パス):"
find . -type f | sort

echo -e "\n\n📊 ディレクトリとファイルのサマリ:"
echo "総ディレクトリ数:"
find . -type d | wc -l

echo "総ファイル数:"
find . -type f | wc -l

echo -e "\n\n🔍 ファイル拡張子の分布:"
find . -type f | sed -e 's/.*\.//' | sort | uniq -c | sort -rn

echo -e "\n\n📋 各ディレクトリの直下のファイルとサブディレクトリ:"
for dir in */; do
    echo -e "\n${dir}内容:"
    ls -1 "$dir"
done

# CI_XCODEBUILD_ACTIONがtest-without-buildingではないため終了
if [ "$CI_XCODEBUILD_ACTION" != "test-without-building" ]; then
    echo "Exiting because $CI_XCODEBUILD_ACTION is not 'test-without-building'."
    exit 0
fi

# デフォルトのリポジトリパス
# FIXME: test-without-buildingのタイミングだとCI_PRIMARY_REPOSITORY_PATHが空になるので暫定対応
REPO_PATH="/Volumes/workspace/repository"

echo "⭐️Install sonar-scanner..."
# 必要なツールのインストール
brew install sonar-scanner jq || {
    echo "Failed to install sonar-scanner or jq"
    exit 1
}

echo "⭐️Starting SonarCloud coverage upload process..."
# プロジェクトのルートディレクトリに移動
cd "$REPO_PATH"

# SonarCloud用の一時ディレクトリとファイル設定
TEMP_DIR="$CI_DERIVED_DATA_PATH/sonar_temp"
mkdir -p "$TEMP_DIR"
COVERAGE_FILE="$TEMP_DIR/coverage.xml"

# カバレッジレポート生成
{
    echo '<?xml version="1.0" ?>'
    echo '<coverage version="1">'
    
    xcrun xccov view --report --json "$CI_RESULT_BUNDLE_PATH" > "$TEMP_DIR/coverage.json"
    
    jq -r '.targets[] | select(.name != null) | .files[] | select(.path != null and (.path | endswith(".swift")) and (.path | contains("Test") | not)) | 
        .path as $path | .functions[] | 
        "\($path)|\(.coveredLines)|\(.executableLines)"' "$TEMP_DIR/coverage.json" | while IFS='|' read -r file_path covered_lines total_lines; do
        echo "  <file path=\"$file_path\">"
        for line in $(seq 1 $total_lines); do
            covered=$([[ $line -le $covered_lines ]] && echo "true" || echo "false")
            echo "    <lineToCover lineNumber=\"$line\" covered=\"$covered\"/>"
        done
        echo "  </file>"
    done
    
    echo '</coverage>'
} > "$COVERAGE_FILE"

echo "⭐️Generated Coverage Files:"
ls -l "$TEMP_DIR"
echo "\n--- Coverage XML Contents (first 50 lines) ---"
head -n 50 "$COVERAGE_FILE"

PROJECT_NAME="SonarSwift"

# sonar-project.properties生成
cat > "$TEMP_DIR/sonar-project.properties" << EOF
sonar.projectKey=${SONAR_PROJECT_KEY}
sonar.organization=${SONAR_ORGANIZATION}
sonar.host.url=https://sonarcloud.io
sonar.sources=${REPO_PATH}
sonar.swift.coverage.reportPath=${COVERAGE_FILE}
sonar.coverageReportPaths=${COVERAGE_FILE}
sonar.exclusions=**/*.generated.swift,**/Pods/**/*,**/*.pb.swift,**/*Tests/**,**Package.swift
sonar.test.inclusions=**/*Tests/**
sonar.swift.file.suffixes=.swift
sonar.scm.provider=git
sonar.sourceEncoding=UTF-8
sonar.projectVersion=${CI_BUILD_NUMBER}
sonar.projectName=${PROJECT_NAME}
sonar.verbose=true
EOF

# SonarCloudスキャン実行
export PATH="$PATH:/usr/local/bin"
command -v sonar-scanner >/dev/null 2>&1 || {
    echo "Error: sonar-scanner not found in PATH (PATH: $PATH)"
    exit 1
}

sonar-scanner \
  -Dsonar.token="$SONAR_TOKEN" \
  -Dsonar.working.directory="$TEMP_DIR/.scannerwork" \
  -Dsonar.branch.name="inspect" \
  -Dproject.settings="$TEMP_DIR/sonar-project.properties" \
  -Dsonar.scm.disabled=true \
  -X

echo "Successfully uploaded coverage to SonarCloud"
