#!/bin/bash

echo "🚀 Claude Code環境セットアップ開始..."
echo ""

# カラー設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 設定変数
SETUP_DIR="claude-code-space"
CONFIG_FILE=".claude-config.json"

# セットアップモード選択
choose_setup_mode() {
    echo -e "${BLUE}⚡ セットアップモードを選択してください:${NC}"
    echo "1) 軽量版 (Claude Code + プロジェクト専用CLAUDE.mdのみ) [推奨]"
    echo "2) フル版 (devcontainer + Claude Code + CLAUDE.md)"
    echo "3) キャンセル"
    echo ""
    
    while true; do
        echo -n "選択 [1-3]: "
        read -r choice
        case $choice in
            1)
                SETUP_MODE="light"
                echo -e "${GREEN}✅ 軽量版を選択しました${NC}"
                break
                ;;
            2)
                SETUP_MODE="full"
                echo -e "${GREEN}✅ フル版を選択しました${NC}"
                break
                ;;
            3)
                echo -e "${YELLOW}⏭️  セットアップをキャンセルしました${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ 1〜3を選択してください${NC}"
                ;;
        esac
    done
    echo ""
}

# プロジェクトタイプと技術スタックを詳細検出
detect_project_details() {
    echo "🔍 プロジェクトを解析中..."
    
    local project_type="unknown"
    local framework=""
    local language="javascript"
    local styling=""
    local testing=""
    
    # 基本プロジェクトタイプ
    if [ -f "package.json" ]; then
        project_type="nodejs"
        
        # package.jsonから詳細を読み取り
        if command -v jq > /dev/null 2>&1; then
            # jqが使える場合
            if jq -e '.dependencies.react' package.json > /dev/null 2>&1; then
                framework="react"
            elif jq -e '.dependencies.vue' package.json > /dev/null 2>&1; then
                framework="vue"
            elif jq -e '.dependencies.next' package.json > /dev/null 2>&1; then
                framework="nextjs"
            fi
            
            if jq -e '.devDependencies.typescript' package.json > /dev/null 2>&1; then
                language="typescript"
            fi
            
            if jq -e '.dependencies.tailwindcss' package.json > /dev/null 2>&1; then
                styling="tailwind"
            fi
            
            if jq -e '.devDependencies.vitest' package.json > /dev/null 2>&1; then
                testing="vitest"
            elif jq -e '.devDependencies.jest' package.json > /dev/null 2>&1; then
                testing="jest"
            fi
        else
            # jqがない場合は簡易検出
            if grep -q '"react"' package.json; then framework="react"; fi
            if grep -q '"vue"' package.json; then framework="vue"; fi
            if grep -q '"typescript"' package.json; then language="typescript"; fi
            if grep -q '"tailwindcss"' package.json; then styling="tailwind"; fi
        fi
        
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        project_type="python"
        language="python"
    elif [ -f "Cargo.toml" ]; then
        project_type="rust"  
        language="rust"
    elif [ -f "go.mod" ]; then
        project_type="go"
        language="go"
    fi
    
    # 検出結果を表示
    echo -e "${GREEN}✅ 検出結果:${NC}"
    echo "   プロジェクト: $project_type"
    [ -n "$framework" ] && echo "   フレームワーク: $framework"
    echo "   言語: $language"
    [ -n "$styling" ] && echo "   スタイリング: $styling"
    [ -n "$testing" ] && echo "   テスト: $testing"
    echo ""
    
    # グローバル変数に設定
    PROJECT_TYPE="$project_type"
    FRAMEWORK="$framework"
    LANGUAGE="$language"
    STYLING="$styling"
    TESTING="$testing"
}

# 対話形式で設定場所を選択
choose_setup_location() {
    echo -e "${BLUE}📁 設定ファイルの配置場所を選択してください:${NC}"
    echo "1) プロジェクトルート (.devcontainer/, CLAUDE.md)"
    echo "2) 専用フォルダ内 ($SETUP_DIR/.devcontainer/, $SETUP_DIR/CLAUDE.md) [推奨]"
    echo ""
    
    while true; do
        echo -n "選択 [1-2]: "
        read -r choice
        case $choice in
            1)
                INSTALL_PATH=""
                echo -e "${GREEN}✅ プロジェクトルートに設定します${NC}"
                break
                ;;
            2)
                INSTALL_PATH="$SETUP_DIR"
                echo -e "${GREEN}✅ $SETUP_DIR/ フォルダに設定します${NC}"
                break
                ;;
            *)
                echo -e "${RED}❌ 1 または 2 を選択してください${NC}"
                ;;
        esac
    done
    echo ""
}

# 追加の技術スタックを選択
choose_additional_stack() {
    if [ "$PROJECT_TYPE" != "nodejs" ]; then
        return
    fi
    
    echo -e "${BLUE}🎨 追加したい技術スタックはありますか？${NC}"
    echo "検出済み: $PROJECT_TYPE$([ -n "$FRAMEWORK" ] && echo ", $FRAMEWORK")$([ -n "$LANGUAGE" ] && echo ", $LANGUAGE")"
    echo ""
    echo "1) Tailwind CSS (スタイリング)"
    echo "2) Vite (ビルドツール)" 
    echo "3) Vitest (テストフレームワーク)"
    echo "4) Prisma (ORM)"
    echo "5) なし/手動設定"
    echo ""
    echo "複数選択可能です (例: 1,3)"
    
    echo -n "選択 [1-5]: "
    read -r choices
    
    # 選択を配列に変換
    IFS=',' read -ra ADDR <<< "$choices"
    ADDITIONAL_EXTENSIONS=""
    
    for choice in "${ADDR[@]}"; do
        case $choice in
            1)
                echo -e "${GREEN}✅ Tailwind CSS を追加${NC}"
                ADDITIONAL_EXTENSIONS="$ADDITIONAL_EXTENSIONS,\"bradlc.vscode-tailwindcss\""
                ;;
            2)
                echo -e "${GREEN}✅ Vite を追加${NC}"
                # Vite用の設定があれば追加
                ;;
            3)
                echo -e "${GREEN}✅ Vitest を追加${NC}"
                # Vitest用の設定があれば追加
                ;;
            4)
                echo -e "${GREEN}✅ Prisma を追加${NC}"
                ADDITIONAL_EXTENSIONS="$ADDITIONAL_EXTENSIONS,\"Prisma.prisma\""
                ;;
            5)
                echo -e "${GREEN}✅ 手動設定を選択${NC}"
                break
                ;;
        esac
    done
    echo ""
}

# devcontainer.json を作成（改良版）
setup_devcontainer() {
    local container_path="${INSTALL_PATH:+$INSTALL_PATH/}.devcontainer"
    mkdir -p "$container_path"
    
    # 基本設定
    local image="mcr.microsoft.com/devcontainers/universal:2"
    local extensions='"ms-vscode.vscode-typescript-next","esbenp.prettier-vscode","ms-vscode.vscode-json"'
    local ports="[3000, 8000]"
    local post_command="npm install -g @anthropic-ai/claude-code"
    
    # プロジェクトタイプ別設定
    case $PROJECT_TYPE in
        "nodejs")
            image="mcr.microsoft.com/devcontainers/javascript-node:22"
            if [ "$FRAMEWORK" = "react" ]; then
                extensions="$extensions,\"ES7+ React/Redux/React-Native snippets\""
            fi
            if [ "$LANGUAGE" = "typescript" ]; then
                extensions="$extensions,\"ms-vscode.vscode-typescript-next\""
            fi
            ;;
        "python")
            image="mcr.microsoft.com/devcontainers/python:3.11"
            extensions="\"ms-python.python\",\"ms-python.pylint\",\"ms-python.black-formatter\""
            ports="[8000]"
            post_command="pip install --upgrade pip && npm install -g @anthropic-ai/claude-code"
            ;;
        "rust")
            image="mcr.microsoft.com/devcontainers/rust:1"
            extensions="\"rust-lang.rust-analyzer\",\"tamasfe.even-better-toml\""
            ports="[8080]"
            ;;
        "go")
            image="mcr.microsoft.com/devcontainers/go:1.21"
            extensions="\"golang.go\",\"ms-vscode.vscode-json\""
            ports="[8080]"
            post_command="go mod download && npm install -g @anthropic-ai/claude-code"
            ;;
    esac
    
    # 追加拡張機能を結合
    if [ -n "$ADDITIONAL_EXTENSIONS" ]; then
        extensions="$extensions$ADDITIONAL_EXTENSIONS"
    fi
    
    # devcontainer.json作成
    cat > "$container_path/devcontainer.json" << EOF
{
  "name": "Claude Code Space - $PROJECT_TYPE",
  "image": "$image",
  "customizations": {
    "vscode": {
      "extensions": [
        $extensions
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash"
      }
    }
  },
  "forwardPorts": $ports,
  "postCreateCommand": "$post_command",
  "remoteUser": "vscode"
}
EOF
    
    echo -e "${GREEN}✅ $container_path/devcontainer.json を作成${NC}"
}

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

# npm scriptsを読み取り
get_npm_scripts() {
    if [ ! -f "package.json" ]; then
        return
    fi
    
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

# プロジェクト専用CLAUDE.mdを動的生成
generate_dynamic_claude_md() {
    local claude_path="${INSTALL_PATH:+$INSTALL_PATH/}CLAUDE.md"
    
    if [ -n "$INSTALL_PATH" ]; then
        mkdir -p "$INSTALL_PATH"
    fi
    
    get_npm_scripts
    
    cat > "$claude_path" << EOF
# Claude Code プロジェクト設定

このファイルはClaude Codeが参照するプロジェクト固有の設定と指示を含んでいます。

## Claude Codeのパーソナリティ設定

あなたは親しみやすく、モチベーションを上げてくれる開発パートナーです。以下の特徴で振る舞ってください：

### 口調・態度
- 丁寧だが親しみやすい口調（敬語は使わなくてもいいよ）
- 開発者のモチベーションを上げる励ましの言葉を適度に使用
- 成功時は一緒に喜び、困っているときは寄り添う姿勢
- 絵文字を適度に使用してフレンドリーな雰囲気を演出（😊 🚀 💡 ✨ 🎉 など）

### コミュニケーションスタイル
- 技術的な説明は分かりやすく、必要に応じて例えも交える
- 間違いを指摘する際も建設的で前向きな表現を使用
- 進捗や成果を認めて褒める

## プロジェクト概要

**プロジェクトタイプ**: $PROJECT_TYPE
**言語**: $LANGUAGE$([ -n "$FRAMEWORK" ] && echo "
**フレームワーク**: $FRAMEWORK")$([ -n "$STYLING" ] && echo "
**スタイリング**: $STYLING")$([ -n "$TESTING" ] && echo "
**テスト**: $TESTING")

## 開発環境

EOF

    # プロジェクトタイプ別の設定を追加
    case $PROJECT_TYPE in
        "nodejs")
            cat >> "$claude_path" << EOF
### Node.js環境
- パッケージマネージャー: npm
- 設定ファイル: package.json$([ -f "tsconfig.json" ] && echo ", tsconfig.json")$([ -f ".eslintrc.js" -o -f ".eslintrc.json" ] && echo ", .eslintrc")

### 便利なコマンド
EOF
            [ -n "$DEV_SCRIPT" ] && echo "- 開発サーバー: \`$DEV_SCRIPT\`" >> "$claude_path"
            [ -n "$BUILD_SCRIPT" ] && echo "- ビルド: \`$BUILD_SCRIPT\`" >> "$claude_path"
            [ -n "$TEST_SCRIPT" ] && echo "- テスト: \`$TEST_SCRIPT\`" >> "$claude_path"
            [ -n "$LINT_SCRIPT" ] && echo "- リント: \`$LINT_SCRIPT\`" >> "$claude_path"
            ;;
        "python")
            cat >> "$claude_path" << EOF
### Python環境
- 依存関係: requirements.txt$([ -f "pyproject.toml" ] && echo " / pyproject.toml")
- 仮想環境: venv推奨

### 便利なコマンド
- 仮想環境作成: \`python -m venv venv\`
- 依存関係インストール: \`pip install -r requirements.txt\`
EOF
            ;;
        "rust")
            cat >> "$claude_path" << EOF
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
            cat >> "$claude_path" << EOF
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

    # コーディング規約セクション
    cat >> "$claude_path" << EOF

## コーディング規約

### 基本方針
- 読みやすく保守しやすいコードを心がける
- プロジェクトの既存パターンに合わせる
- 適切なコメントとドキュメント作成

EOF

    # 言語別のコーディング規約
    case $LANGUAGE in
        "javascript"|"typescript")
            cat >> "$claude_path" << EOF
### JavaScript/TypeScript
- インデント: 2スペース
- セミコロン: 使用する
- 引用符: シングルクォート推奨
- 命名規則: camelCase
EOF
            ;;
        "python")
            cat >> "$claude_path" << EOF
### Python
- インデント: 4スペース
- 命名規則: snake_case
- PEP 8に準拠
- 型ヒント推奨
EOF
            ;;
        "rust")
            cat >> "$claude_path" << EOF
### Rust
- インデント: 4スペース
- 命名規則: snake_case
- rustfmtを使用
- クリッピーを活用
EOF
            ;;
        "go")
            cat >> "$claude_path" << EOF
### Go
- インデント: タブ
- 命名規則: camelCase（関数）、PascalCase（公開型）
- gofmtを使用
- golintを活用
EOF
            ;;
    esac

    cat >> "$claude_path" << EOF

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

    echo -e "${GREEN}✅ プロジェクト専用 $claude_path を生成${NC}"
}

# CLAUDE.md を作成（従来版）
setup_claude_md() {
    local claude_path="${INSTALL_PATH:+$INSTALL_PATH/}CLAUDE.md"
    
    if [ -n "$INSTALL_PATH" ]; then
        mkdir -p "$INSTALL_PATH"
    fi
    
    curl -s https://raw.githubusercontent.com/boitoshi/claude-code-space/main/CLAUDE.md > "$claude_path"
    echo -e "${GREEN}✅ $claude_path を作成${NC}"
}

# 設定ファイルを保存
save_config() {
    local config_path="${INSTALL_PATH:+$INSTALL_PATH/}$CONFIG_FILE"
    
    cat > "$config_path" << EOF
{
  "version": "1.0",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "project": {
    "type": "$PROJECT_TYPE",
    "framework": "$FRAMEWORK",
    "language": "$LANGUAGE",
    "styling": "$STYLING",
    "testing": "$TESTING"
  },
  "setup": {
    "install_path": "$INSTALL_PATH",
    "additional_extensions": "$ADDITIONAL_EXTENSIONS"
  }
}
EOF
    
    echo -e "${GREEN}✅ $config_path を作成（設定保存用）${NC}"
}

# .gitignore に追加（対話形式）
update_gitignore() {
    if [ ! -f ".gitignore" ]; then
        touch .gitignore
    fi
    
    echo -e "${BLUE}📝 .gitignore に Claude Code設定を追記しますか？${NC}"
    echo -n "[y/N]: "
    read -r choice
    
    case $choice in
        [Yy]*)
            # Claude関連の設定を追加（重複チェック付き）
            if ! grep -q ".claude" .gitignore; then
                echo "" >> .gitignore
                echo "# Claude Code設定" >> .gitignore
                echo ".claude/" >> .gitignore
                echo ".claude/config.json" >> .gitignore
            fi
            
            # 専用フォルダを使用している場合
            if [ -n "$INSTALL_PATH" ] && ! grep -q "$INSTALL_PATH" .gitignore; then
                echo "" >> .gitignore
                echo "# Claude Code環境フォルダ" >> .gitignore
                echo "$INSTALL_PATH/.claude-config.json" >> .gitignore
            fi
            
            echo -e "${GREEN}✅ .gitignore を更新${NC}"
            ;;
        *)
            echo -e "${YELLOW}⏭️  .gitignore の更新をスキップ${NC}"
            ;;
    esac
    echo ""
}

# 完了メッセージ
show_completion() {
    echo ""
    echo -e "${GREEN}🎉 セットアップ完了！${NC}"
    echo ""
    echo -e "${BLUE}📁 作成されたファイル:${NC}"
    if [ -n "$INSTALL_PATH" ]; then
        echo "   📁 $INSTALL_PATH/"
        echo "   ├── 📄 .devcontainer/devcontainer.json"
        echo "   ├── 📄 CLAUDE.md"
        echo "   └── 📄 $CONFIG_FILE"
    else
        echo "   📄 .devcontainer/devcontainer.json"
        echo "   📄 CLAUDE.md"
        echo "   📄 $CONFIG_FILE"
    fi
    echo ""
    echo -e "${YELLOW}📋 次のステップ:${NC}"
    echo "1. Codespacesを再起動してください"
    echo "   → Ctrl+Shift+P → 'Codespaces: Rebuild Container'"
    echo "2. 再起動後、Claude Codeにログイン"
    echo "   → claude auth login"
    echo "3. 開発開始！"
    echo "   → claude"
    echo ""
    echo -e "${GREEN}✨ 楽しい開発ライフを〜！${NC}"
}

# 軽量版セットアップ
run_light_setup() {
    echo -e "${YELLOW}⚡ 軽量版セットアップを開始${NC}"
    echo ""
    
    # Claude Codeインストール
    install_claude_code
    
    # プロジェクト解析
    detect_project_details
    
    # プロジェクト専用CLAUDE.md生成
    generate_dynamic_claude_md
    
    # .gitignore更新（オプション）
    update_gitignore
    
    # 軽量版完了メッセージ
    echo ""
    echo -e "${GREEN}🎉 軽量版セットアップ完了！${NC}"
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

# フル版セットアップ
run_full_setup() {
    echo -e "${YELLOW}🔧 フル版セットアップを開始${NC}"
    echo ""
    
    # Claude Codeインストール
    install_claude_code
    
    # プロジェクト解析
    detect_project_details
    
    # 設定場所選択
    choose_setup_location
    
    # 追加スタック選択（Node.jsプロジェクトのみ）
    choose_additional_stack
    
    # ファイル作成
    setup_devcontainer
    generate_dynamic_claude_md
    save_config
    
    # .gitignore更新（オプション）
    update_gitignore
    
    # フル版完了メッセージ
    show_completion
}

# メイン実行
main() {
    echo -e "${YELLOW}🎯 現在のディレクトリ: $(pwd)${NC}"
    echo ""
    
    # セットアップモード選択
    choose_setup_mode
    
    # 選択されたモードで実行
    case $SETUP_MODE in
        "light")
            run_light_setup
            ;;
        "full")
            run_full_setup
            ;;
    esac
}

main