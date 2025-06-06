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

# CLAUDE.md を作成
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

# メイン実行
main() {
    echo -e "${YELLOW}🎯 現在のディレクトリ: $(pwd)${NC}"
    echo ""
    
    # 1. プロジェクト解析
    detect_project_details
    
    # 2. 設定場所選択
    choose_setup_location
    
    # 3. 追加スタック選択（Node.jsプロジェクトのみ）
    choose_additional_stack
    
    # 4. ファイル作成
    setup_devcontainer
    setup_claude_md
    save_config
    
    # 5. .gitignore更新（オプション）
    update_gitignore
    
    # 6. 完了メッセージ
    show_completion
}

main