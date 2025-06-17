#!/bin/bash

echo "⚡ Claude Code 軽量セットアップ開始..."
echo ""

# カラー設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Claude Codeの自動インストール
install_claude_code() {
    echo "🔧 Claude Codeをインストール中..."
    
    if command -v claude > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Claude Code は既にインストール済みです${NC}"
        return
    fi
    
    if command -v npm > /dev/null 2>&1; then
        npm install -g @anthropic-ai/claude-code
        echo -e "${GREEN}✅ Claude Code をインストールしました${NC}"
    else
        echo -e "${RED}❌ npmが見つかりません。Node.jsをインストールしてください${NC}"
        exit 1
    fi
    echo ""
}

# プロジェクト詳細を検出
detect_project_details() {
    echo "🔍 プロジェクトを解析中..."
    
    PROJECT_TYPE="unknown"
    FRAMEWORK=""
    LANGUAGE="javascript"
    STYLING=""
    TESTING=""
    BUILD_TOOL=""
    
    # package.jsonベースの解析
    if [ -f "package.json" ]; then
        PROJECT_TYPE="nodejs"
        
        # 依存関係から詳細検出
        if grep -q '"react"' package.json; then FRAMEWORK="react"; fi
        if grep -q '"vue"' package.json; then FRAMEWORK="vue"; fi
        if grep -q '"next"' package.json; then FRAMEWORK="nextjs"; fi
        if grep -q '"@angular/core"' package.json; then FRAMEWORK="angular"; fi
        
        if grep -q '"typescript"' package.json; then LANGUAGE="typescript"; fi
        
        if grep -q '"tailwindcss"' package.json; then STYLING="tailwind"; fi
        if grep -q '"styled-components"' package.json; then STYLING="styled-components"; fi
        
        if grep -q '"vitest"' package.json; then TESTING="vitest"; fi
        if grep -q '"jest"' package.json; then TESTING="jest"; fi
        if grep -q '"cypress"' package.json; then TESTING="cypress"; fi
        
        if grep -q '"vite"' package.json; then BUILD_TOOL="vite"; fi
        if grep -q '"webpack"' package.json; then BUILD_TOOL="webpack"; fi
        
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        PROJECT_TYPE="python"
        LANGUAGE="python"
    elif [ -f "Cargo.toml" ]; then
        PROJECT_TYPE="rust"
        LANGUAGE="rust"
    elif [ -f "go.mod" ]; then
        PROJECT_TYPE="go"
        LANGUAGE="go"
    fi
    
    echo -e "${GREEN}✅ 検出結果:${NC}"
    echo "   プロジェクト: $PROJECT_TYPE"
    [ -n "$FRAMEWORK" ] && echo "   フレームワーク: $FRAMEWORK"
    echo "   言語: $LANGUAGE"
    [ -n "$STYLING" ] && echo "   スタイリング: $STYLING"
    [ -n "$TESTING" ] && echo "   テスト: $TESTING"
    [ -n "$BUILD_TOOL" ] && echo "   ビルドツール: $BUILD_TOOL"
    echo ""
}

# npm scriptsを読み取り
get_npm_scripts() {
    if [ ! -f "package.json" ]; then
        return
    fi
    
    # 主要なスクリプトを抽出
    DEV_SCRIPT=""
    BUILD_SCRIPT=""
    TEST_SCRIPT=""
    LINT_SCRIPT=""
    
    if grep -q '"dev"' package.json; then DEV_SCRIPT="npm run dev"; fi
    if grep -q '"start"' package.json && [ -z "$DEV_SCRIPT" ]; then DEV_SCRIPT="npm start"; fi
    if grep -q '"build"' package.json; then BUILD_SCRIPT="npm run build"; fi
    if grep -q '"test"' package.json; then TEST_SCRIPT="npm test"; fi
    if grep -q '"lint"' package.json; then LINT_SCRIPT="npm run lint"; fi
}

# プロジェクト専用CLAUDE.mdを生成
generate_project_claude_md() {
    echo "📝 プロジェクト専用CLAUDE.mdを生成中..."
    
    get_npm_scripts
    
    cat > "CLAUDE.md" << EOF
# Claude Code プロジェクト設定

このファイルはClaude Codeが参照するプロジェクト固有の設定と指示を含んでいます。

## Claude Codeのパーソナリティ設定

あなたは親しみやすく、モチベーションを上げてくれる開発パートナーです。

### コミュニケーションスタイル
- 丁寧だが親しみやすい口調
- 開発者のモチベーションを上げる励ましの言葉を適度に使用
- 技術的な説明は分かりやすく、必要に応じて例えも交える
- 絵文字を適度に使用してフレンドリーな雰囲気を演出（😊 🚀 💡 ✨ 🎉 など）

## プロジェクト概要

**プロジェクトタイプ**: $PROJECT_TYPE
**言語**: $LANGUAGE$([ -n "$FRAMEWORK" ] && echo "
**フレームワーク**: $FRAMEWORK")$([ -n "$STYLING" ] && echo "
**スタイリング**: $STYLING")$([ -n "$TESTING" ] && echo "
**テスト**: $TESTING")$([ -n "$BUILD_TOOL" ] && echo "
**ビルドツール**: $BUILD_TOOL")

## 開発環境

EOF

    # プロジェクトタイプ別の設定を追加
    case $PROJECT_TYPE in
        "nodejs")
            cat >> "CLAUDE.md" << EOF
### Node.js環境
- パッケージマネージャー: npm
- 設定ファイル: package.json$([ -f "tsconfig.json" ] && echo ", tsconfig.json")$([ -f ".eslintrc.js" -o -f ".eslintrc.json" ] && echo ", .eslintrc")

### 便利なコマンド
EOF
            [ -n "$DEV_SCRIPT" ] && echo "- 開発サーバー: \`$DEV_SCRIPT\`" >> "CLAUDE.md"
            [ -n "$BUILD_SCRIPT" ] && echo "- ビルド: \`$BUILD_SCRIPT\`" >> "CLAUDE.md"
            [ -n "$TEST_SCRIPT" ] && echo "- テスト: \`$TEST_SCRIPT\`" >> "CLAUDE.md"
            [ -n "$LINT_SCRIPT" ] && echo "- リント: \`$LINT_SCRIPT\`" >> "CLAUDE.md"
            ;;
        "python")
            cat >> "CLAUDE.md" << EOF
### Python環境
- 依存関係: requirements.txt$([ -f "pyproject.toml" ] && echo " / pyproject.toml")
- 仮想環境: venv推奨

### 便利なコマンド
- 仮想環境作成: \`python -m venv venv\`
- 仮想環境有効化: \`source venv/bin/activate\`
- 依存関係インストール: \`pip install -r requirements.txt\`
EOF
            ;;
        "rust")
            cat >> "CLAUDE.md" << EOF
### Rust環境
- パッケージマネージャー: cargo
- 設定ファイル: Cargo.toml

### 便利なコマンド
- ビルド: \`cargo build\`
- 実行: \`cargo run\`
- テスト: \`cargo test\`
EOF
            ;;
        "go")
            cat >> "CLAUDE.md" << EOF
### Go環境
- パッケージマネージャー: go mod
- 設定ファイル: go.mod

### 便利なコマンド
- ビルド: \`go build\`
- 実行: \`go run .\`
- テスト: \`go test ./...\`
- 依存関係整理: \`go mod tidy\`
EOF
            ;;
    esac

    # 共通設定を追加
    cat >> "CLAUDE.md" << EOF


## コーディング規約

### 基本方針
- 読みやすく保守しやすいコードを心がける
- プロジェクトの既存パターンに合わせる
- 適切なコメントとドキュメント作成

EOF

    # 言語別のコーディング規約
    case $LANGUAGE in
        "javascript"|"typescript")
            cat >> "CLAUDE.md" << EOF
### JavaScript/TypeScript
- インデント: 2スペース
- セミコロン: 使用する
- 引用符: シングルクォート推奨
- 命名規則: camelCase
EOF
            ;;
        "python")
            cat >> "CLAUDE.md" << EOF
### Python
- インデント: 4スペース
- 命名規則: snake_case
- PEP 8に準拠
- 型ヒント推奨
EOF
            ;;
        "rust")
            cat >> "CLAUDE.md" << EOF
### Rust
- インデント: 4スペース
- 命名規則: snake_case
- rustfmtを使用
- クリッピーを活用
EOF
            ;;
        "go")
            cat >> "CLAUDE.md" << EOF
### Go
- インデント: タブ
- 命名規則: camelCase（関数）、PascalCase（公開型）
- gofmtを使用
- golintを活用
EOF
            ;;
    esac

    cat >> "CLAUDE.md" << EOF

## 推奨ワークフロー

1. **新機能開発時**
   - フィーチャーブランチを作成
   - Claude Codeで設計・実装を相談
   - テストケースも含めて開発

2. **バグ修正時**
   - 問題の再現手順を整理
   - Claude Codeで原因分析を依頼
   - 修正後は回帰テストを実行

3. **リファクタリング時**
   - 既存コードの問題点を特定
   - Claude Codeで改善案を検討
   - 段階的に安全にリファクタリング

## セキュリティとベストプラクティス

- 機密情報やAPIキーは環境変数を使用
- 依存関係は定期的に更新
- セキュリティ脆弱性をチェック
- コミット前に$([ -n "$LINT_SCRIPT" ] && echo "lintと")テストを実行

## よくあるタスク

### コード生成
「新しい○○機能を実装してください」
「○○のためのユーティリティ関数を作成してください」

### コードレビュー
「このコードの問題点や改善点を教えてください」
「パフォーマンスを向上させる方法はありますか？」

### デバッグ
「このエラーの原因と解決方法を教えてください」
「なぜこの処理が期待通りに動作しないのでしょうか？」

---

🎉 このプロジェクトでClaude Codeを活用して、効率的な開発を進めましょう！
EOF

    echo -e "${GREEN}✅ プロジェクト専用CLAUDE.mdを生成しました${NC}"
    echo ""
}

# .gitignoreの更新
update_gitignore() {
    if [ ! -f ".gitignore" ]; then
        return
    fi
    
    echo -e "${BLUE}📝 .gitignoreにClaude Code設定を追記しますか？${NC}"
    echo -n "[y/N]: "
    read -r choice
    
    case $choice in
        [Yy]*)
            if ! grep -q ".claude" .gitignore; then
                echo "" >> .gitignore
                echo "# Claude Code設定" >> .gitignore
                echo ".claude/" >> .gitignore
                echo ".claude/config.json" >> .gitignore
                echo -e "${GREEN}✅ .gitignoreを更新しました${NC}"
            else
                echo -e "${YELLOW}⏭️  Claude Code設定は既に存在します${NC}"
            fi
            ;;
        *)
            echo -e "${YELLOW}⏭️  .gitignoreの更新をスキップしました${NC}"
            ;;
    esac
    echo ""
}

# 完了メッセージ
show_completion() {
    echo ""
    echo -e "${GREEN}🎉 軽量セットアップ完了！${NC}"
    echo ""
    echo -e "${BLUE}📁 作成されたファイル:${NC}"
    echo "   📄 CLAUDE.md (プロジェクト専用設定)"
    echo ""
    echo -e "${YELLOW}📋 次のステップ:${NC}"
    echo "1. Claude Codeにログイン"
    echo "   → claude auth login"
    echo "2. 開発開始！"
    echo "   → claude"
    echo ""
    echo -e "${GREEN}✨ 軽量だから$([ "$PROJECT_TYPE" != "unknown" ] && echo "$PROJECT_TYPE")開発がサクサク進むよ〜！${NC}"
}

# メイン実行
main() {
    echo -e "${YELLOW}🎯 現在のディレクトリ: $(pwd)${NC}"
    echo ""
    
    # Claude Codeインストール
    install_claude_code
    
    # プロジェクト解析
    detect_project_details
    
    # プロジェクト専用CLAUDE.md生成
    generate_project_claude_md
    
    # .gitignore更新（オプション）
    update_gitignore
    
    # 完了メッセージ
    show_completion
}

main