#!/bin/bash

echo "🚀 Claude Code環境セットアップ開始..."

# プロジェクトタイプを検出
detect_project_type() {
    if [ -f "package.json" ]; then
        echo "📦 Node.js プロジェクトを検出"
        return 0
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "🐍 Python プロジェクトを検出"
        return 1
    elif [ -f "Cargo.toml" ]; then
        echo "🦀 Rust プロジェクトを検出"
        return 2
    else
        echo "📁 汎用プロジェクトとして設定"
        return 3
    fi
}

# devcontainer.json を作成
setup_devcontainer() {
    mkdir -p .devcontainer
    
    if detect_project_type; then
        # Node.js用設定
        cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "Claude Code Space",
  "image": "mcr.microsoft.com/devcontainers/javascript-node:22",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-typescript-next",
        "esbenp.prettier-vscode",
        "ms-vscode.vscode-json"
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash"
      }
    }
  },
  "forwardPorts": [3000, 8000],
  "postCreateCommand": "npm install -g @anthropic-ai/claude-code",
  "remoteUser": "node"
}
EOF
    else
        # 汎用設定
        cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "Claude Code Space",
  "image": "mcr.microsoft.com/devcontainers/universal:2",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-typescript-next",
        "esbenp.prettier-vscode"
      ]
    }
  },
  "postCreateCommand": "npm install -g @anthropic-ai/claude-code"
}
EOF
    fi
    
    echo "✅ .devcontainer/devcontainer.json を作成"
}

# CLAUDE.md を作成
setup_claude_md() {
    curl -s https://raw.githubusercontent.com/boitoshi/claude-code-space/main/CLAUDE.md > CLAUDE.md
    echo "✅ CLAUDE.md を作成"
}

# .gitignore に追加
update_gitignore() {
    if [ ! -f ".gitignore" ]; then
        touch .gitignore
    fi
    
    # Claude関連の設定を追加（重複チェック付き）
    if ! grep -q ".claude" .gitignore; then
        echo "" >> .gitignore
        echo "# Claude CLI設定" >> .gitignore
        echo ".claude/" >> .gitignore
        echo ".claude/config.json" >> .gitignore
        echo "✅ .gitignore を更新"
    fi
}

# メイン実行
main() {
    echo "🎯 現在のディレクトリ: $(pwd)"
    
    setup_devcontainer
    setup_claude_md
    update_gitignore
    
    echo ""
    echo "🎉 セットアップ完了！"
    echo ""
    echo "📋 次のステップ:"
    echo "1. Codespacesを再起動してください"
    echo "   → Ctrl+Shift+P → 'Codespaces: Rebuild Container'"
    echo "2. 再起動後、Claude Codeにログイン"
    echo "   → claude auth login"
    echo "3. 開発開始！"
    echo "   → claude"
    echo ""
    echo "✨ 楽しい開発ライフを〜！"
}

main