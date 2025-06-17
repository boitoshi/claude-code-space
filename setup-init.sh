#!/bin/bash

echo "🎯 Claude Code 初期プロジェクトセットアップ開始..."
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

# プロジェクトタイプを選択
choose_project_type() {
    echo -e "${BLUE}🚀 新しいプロジェクトの種類を選択してください:${NC}"
    echo "1) Node.js (Express.js API)"
    echo "2) Node.js (React アプリ)"
    echo "3) Node.js (Vue.js アプリ)"
    echo "4) TypeScript (基本設定)"
    echo "5) Python (Flask/FastAPI)"
    echo "6) Python (Django)"
    echo "7) Rust (基本設定)"
    echo "8) Go (基本設定)"
    echo "9) 汎用プロジェクト"
    echo ""
    
    while true; do
        echo -n "選択 [1-9]: "
        read -r choice
        case $choice in
            1)
                PROJECT_TYPE="nodejs"
                FRAMEWORK="express"
                LANGUAGE="javascript"
                echo -e "${GREEN}✅ Node.js (Express.js) を選択${NC}"
                break
                ;;
            2)
                PROJECT_TYPE="nodejs"
                FRAMEWORK="react"
                LANGUAGE="javascript"
                echo -e "${GREEN}✅ Node.js (React) を選択${NC}"
                break
                ;;
            3)
                PROJECT_TYPE="nodejs"
                FRAMEWORK="vue"
                LANGUAGE="javascript"
                echo -e "${GREEN}✅ Node.js (Vue.js) を選択${NC}"
                break
                ;;
            4)
                PROJECT_TYPE="nodejs"
                FRAMEWORK=""
                LANGUAGE="typescript"
                echo -e "${GREEN}✅ TypeScript を選択${NC}"
                break
                ;;
            5)
                PROJECT_TYPE="python"
                FRAMEWORK="flask"
                LANGUAGE="python"
                echo -e "${GREEN}✅ Python (Flask/FastAPI) を選択${NC}"
                break
                ;;
            6)
                PROJECT_TYPE="python"
                FRAMEWORK="django"
                LANGUAGE="python"
                echo -e "${GREEN}✅ Python (Django) を選択${NC}"
                break
                ;;
            7)
                PROJECT_TYPE="rust"
                FRAMEWORK=""
                LANGUAGE="rust"
                echo -e "${GREEN}✅ Rust を選択${NC}"
                break
                ;;
            8)
                PROJECT_TYPE="go"
                FRAMEWORK=""
                LANGUAGE="go"
                echo -e "${GREEN}✅ Go を選択${NC}"
                break
                ;;
            9)
                PROJECT_TYPE="generic"
                FRAMEWORK=""
                LANGUAGE="generic"
                echo -e "${GREEN}✅ 汎用プロジェクト を選択${NC}"
                break
                ;;
            *)
                echo -e "${RED}❌ 1〜9を選択してください${NC}"
                ;;
        esac
    done
    echo ""
}

# 初期プロジェクトファイルを作成
create_initial_files() {
    echo "📁 初期プロジェクトファイルを作成中..."
    
    case "$PROJECT_TYPE:$FRAMEWORK" in
        "nodejs:express")
            # package.json作成
            cat > package.json << 'EOF'
{
  "name": "my-express-app",
  "version": "1.0.0",
  "description": "Express.js API server",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.7.0"
  },
  "keywords": ["express", "api", "server"],
  "author": "",
  "license": "ISC"
}
EOF

            # server.js作成
            cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// ミドルウェア
app.use(cors());
app.use(express.json());

// ルート
app.get('/', (req, res) => {
  res.json({ message: 'Hello World! Express.js APIが動作中です 🚀' });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// サーバー起動
app.listen(PORT, () => {
  console.log(`🚀 サーバーがポート${PORT}で起動しました`);
});
EOF

            # .env作成
            cat > .env << 'EOF'
PORT=3000
NODE_ENV=development
EOF

            echo -e "${GREEN}✅ Express.js プロジェクトファイルを作成${NC}"
            ;;
            
        "nodejs:react")
            # package.json作成
            cat > package.json << 'EOF'
{
  "name": "my-react-app",
  "version": "1.0.0",
  "description": "React application",
  "main": "src/index.js",
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "dev": "react-scripts start"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1"
  },
  "keywords": ["react", "frontend"],
  "author": "",
  "license": "ISC",
  "browserslist": {
    "production": [">0.2%", "not dead", "not op_mini all"],
    "development": ["last 1 chrome version", "last 1 firefox version", "last 1 safari version"]
  }
}
EOF

            # src/index.js作成
            mkdir -p src
            cat > src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
EOF

            # src/App.js作成
            cat > src/App.js << 'EOF'
import React from 'react';

function App() {
  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1>🚀 React アプリ開始！</h1>
      <p>Claude Code と一緒に素晴らしいアプリを作りましょう！</p>
      <button onClick={() => alert('Hello World!')}>
        クリックしてね！
      </button>
    </div>
  );
}

export default App;
EOF

            # public/index.html作成
            mkdir -p public
            cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>React App</title>
</head>
<body>
    <div id="root"></div>
</body>
</html>
EOF

            echo -e "${GREEN}✅ React プロジェクトファイルを作成${NC}"
            ;;
            
        "nodejs:")
            # TypeScript基本設定
            cat > package.json << 'EOF'
{
  "name": "my-typescript-project",
  "version": "1.0.0",
  "description": "TypeScript project",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "ts-node src/index.ts",
    "test": "jest"
  },
  "dependencies": {},
  "devDependencies": {
    "typescript": "^5.2.2",
    "ts-node": "^10.9.1",
    "@types/node": "^20.8.0",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.5"
  },
  "keywords": ["typescript"],
  "author": "",
  "license": "ISC"
}
EOF

            # tsconfig.json作成
            cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

            # src/index.ts作成
            mkdir -p src
            cat > src/index.ts << 'EOF'
function main(): void {
  console.log('🚀 TypeScript project started!');
  console.log('Claude Code と一緒に型安全な開発を始めよう！');
}

main();
EOF

            echo -e "${GREEN}✅ TypeScript プロジェクトファイルを作成${NC}"
            ;;
            
        "python:flask")
            # requirements.txt作成
            cat > requirements.txt << 'EOF'
Flask==2.3.3
python-dotenv==1.0.0
Flask-CORS==4.0.0
EOF

            # app.py作成
            cat > app.py << 'EOF'
from flask import Flask, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello World! Flask APIが動作中です 🚀',
        'status': 'success'
    })

@app.route('/api/health')
def health():
    return jsonify({
        'status': 'OK',
        'service': 'Flask API'
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
EOF

            # .env作成
            cat > .env << 'EOF'
PORT=5000
FLASK_ENV=development
EOF

            echo -e "${GREEN}✅ Python Flask プロジェクトファイルを作成${NC}"
            ;;
            
        "rust:")
            # Cargo.toml作成
            cat > Cargo.toml << 'EOF'
[package]
name = "my-rust-project"
version = "0.1.0"
edition = "2021"

[dependencies]
EOF

            # src/main.rs作成
            mkdir -p src
            cat > src/main.rs << 'EOF'
fn main() {
    println!("🚀 Rust project started!");
    println!("Claude Code と一緒に高速で安全な開発を始めよう！");
}
EOF

            echo -e "${GREEN}✅ Rust プロジェクトファイルを作成${NC}"
            ;;
            
        "go:")
            # go.mod作成
            cat > go.mod << 'EOF'
module my-go-project

go 1.21
EOF

            # main.go作成
            cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("🚀 Go project started!")
    fmt.Println("Claude Code と一緒に高効率な開発を始めよう！")
}
EOF

            echo -e "${GREEN}✅ Go プロジェクトファイルを作成${NC}"
            ;;
            
        *)
            # 汎用プロジェクト
            cat > README.md << 'EOF'
# My Project

Claude Code と一緒に始める新しいプロジェクト！

## 開始方法

1. プロジェクトを初期化
2. 必要な依存関係をインストール
3. Claude Code で開発開始！

## Claude Code の使い方

```bash
# 対話モードで開始
claude

# 特定のファイルを指定
claude filename.ext
```

🚀 楽しい開発を始めましょう！
EOF

            echo -e "${GREEN}✅ 汎用プロジェクトファイルを作成${NC}"
            ;;
    esac
    
    # .gitignore作成
    create_gitignore
    
    echo ""
}

# .gitignoreを作成
create_gitignore() {
    case $PROJECT_TYPE in
        "nodejs")
            cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build
dist/
build/

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Claude Code
.claude/
EOF
            ;;
        "python")
            cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
venv/
env/
ENV/

# Environment
.env

# IDE
.vscode/
.idea/

# Claude Code
.claude/
EOF
            ;;
        "rust")
            cat > .gitignore << 'EOF'
# Rust
/target/
Cargo.lock

# IDE
.vscode/
.idea/

# Claude Code
.claude/
EOF
            ;;
        "go")
            cat > .gitignore << 'EOF'
# Go
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out
go.work

# IDE
.vscode/
.idea/

# Claude Code
.claude/
EOF
            ;;
        *)
            cat > .gitignore << 'EOF'
# Claude Code
.claude/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
EOF
            ;;
    esac
}

# プロジェクト専用CLAUDE.mdを生成
generate_project_claude_md() {
    echo "📝 プロジェクト専用CLAUDE.mdを生成中..."
    
    cat > "CLAUDE.md" << EOF
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
**フレームワーク**: $FRAMEWORK")

このプロジェクトは Claude Code 専用初期テンプレートから作成されました。

## 開発環境

EOF

    # プロジェクトタイプ別の設定を追加
    case "$PROJECT_TYPE:$FRAMEWORK" in
        "nodejs:express")
            cat >> "CLAUDE.md" << EOF
### Node.js + Express.js環境
- パッケージマネージャー: npm
- フレームワーク: Express.js
- 設定ファイル: package.json, server.js

### 便利なコマンド
- 開発サーバー: \`npm run dev\`
- 本番サーバー: \`npm start\`
- テスト: \`npm test\`
- 依存関係インストール: \`npm install\`

### 開発のヒント
- \`server.js\` がメインのサーバーファイル
- \`/api/health\` で動作確認可能
- 環境変数は \`.env\` ファイルで管理
EOF
            ;;
        "nodejs:react")
            cat >> "CLAUDE.md" << EOF
### Node.js + React環境
- パッケージマネージャー: npm
- フレームワーク: React
- 設定ファイル: package.json

### 便利なコマンド
- 開発サーバー: \`npm start\`
- ビルド: \`npm run build\`
- テスト: \`npm test\`
- 依存関係インストール: \`npm install\`

### 開発のヒント
- \`src/App.js\` がメインコンポーネント
- \`src/index.js\` がエントリーポイント
- \`public/index.html\` がHTMLテンプレート
EOF
            ;;
        "nodejs:")
            cat >> "CLAUDE.md" << EOF
### TypeScript環境
- パッケージマネージャー: npm
- 言語: TypeScript
- 設定ファイル: package.json, tsconfig.json

### 便利なコマンド
- 開発実行: \`npm run dev\`
- ビルド: \`npm run build\`
- 本番実行: \`npm start\`
- テスト: \`npm test\`

### 開発のヒント
- \`src/index.ts\` がエントリーポイント
- TypeScriptの型チェックを活用
- \`dist/\` にコンパイル結果が出力
EOF
            ;;
        "python:flask")
            cat >> "CLAUDE.md" << EOF
### Python + Flask環境
- パッケージマネージャー: pip
- フレームワーク: Flask
- 設定ファイル: requirements.txt, app.py

### 便利なコマンド
- 依存関係インストール: \`pip install -r requirements.txt\`
- 開発サーバー: \`python app.py\`
- 仮想環境作成: \`python -m venv venv\`
- 仮想環境有効化: \`source venv/bin/activate\`

### 開発のヒント
- \`app.py\` がメインのFlaskアプリケーション
- \`/api/health\` で動作確認可能
- 環境変数は \`.env\` ファイルで管理
EOF
            ;;
        "rust:")
            cat >> "CLAUDE.md" << EOF
### Rust環境
- パッケージマネージャー: cargo
- 設定ファイル: Cargo.toml

### 便利なコマンド
- ビルド: \`cargo build\`
- 実行: \`cargo run\`
- テスト: \`cargo test\`
- 依存関係追加: \`cargo add <crate>\`

### 開発のヒント
- \`src/main.rs\` がエントリーポイント
- Rustの所有権システムを活用
- \`cargo fmt\` でフォーマット
EOF
            ;;
        "go:")
            cat >> "CLAUDE.md" << EOF
### Go環境
- パッケージマネージャー: go mod
- 設定ファイル: go.mod

### 便利なコマンド
- ビルド: \`go build\`
- 実行: \`go run .\`
- テスト: \`go test ./...\`
- 依存関係整理: \`go mod tidy\`

### 開発のヒント
- \`main.go\` がエントリーポイント
- Goの並行処理を活用
- \`go fmt\` でフォーマット
EOF
            ;;
        *)
            cat >> "CLAUDE.md" << EOF
### 汎用プロジェクト環境
- このプロジェクトは汎用テンプレートから作成されました
- 必要に応じて技術スタックを追加してください

### 開発のヒント
- README.mdから開発を始めましょう
- Claude Codeに相談して最適な構成を決めましょう
EOF
            ;;
    esac

    # 共通設定を追加
    cat >> "CLAUDE.md" << EOF

## コーディング規約

### 基本方針
- 読みやすく保守しやすいコードを心がける
- 適切なコメントとドキュメント作成
- テスト駆動開発（TDD）を推奨

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

## Claude Code活用のヒント

### 最初にやること
1. 「このプロジェクトの構成を説明して」と聞いてみる
2. 「何から始めればいい？」と相談する
3. 「この技術スタックでのベストプラクティスを教えて」と質問する

### 開発中に便利な質問
- 「このコードをレビューして改善点を教えて」
- 「○○機能を実装したいけど、どう設計すればいい？」
- 「このエラーの原因と解決方法を教えて」
- 「パフォーマンスを向上させる方法はある？」

---

🎉 Claude Code と一緒に素晴らしいプロジェクトを作りましょう！
まずは「このプロジェクトについて教えて」と聞いてみてください 😊
EOF

    echo -e "${GREEN}✅ プロジェクト専用 CLAUDE.md を生成${NC}"
    echo ""
}

# 完了メッセージとNext Steps
show_completion() {
    echo ""
    echo -e "${GREEN}🎉 初期プロジェクトセットアップ完了！${NC}"
    echo ""
    echo -e "${BLUE}📁 作成されたファイル:${NC}"
    
    case "$PROJECT_TYPE:$FRAMEWORK" in
        "nodejs:express")
            echo "   📄 package.json (Express.js設定)"
            echo "   📄 server.js (メインサーバー)"
            echo "   📄 .env (環境変数)"
            ;;
        "nodejs:react")
            echo "   📄 package.json (React設定)"
            echo "   📁 src/ (ソースコード)"
            echo "   📄 src/App.js (メインコンポーネント)"
            echo "   📁 public/ (静的ファイル)"
            ;;
        "nodejs:")
            echo "   📄 package.json (TypeScript設定)"
            echo "   📄 tsconfig.json (TypeScript設定)"
            echo "   📁 src/ (ソースコード)"
            ;;
        "python:"*)
            echo "   📄 requirements.txt (依存関係)"
            echo "   📄 app.py (メインアプリ)"
            echo "   📄 .env (環境変数)"
            ;;
        "rust:")
            echo "   📄 Cargo.toml (Rust設定)"
            echo "   📁 src/ (ソースコード)"
            ;;
        "go:")
            echo "   📄 go.mod (Go設定)"
            echo "   📄 main.go (メインファイル)"
            ;;
        *)
            echo "   📄 README.md (プロジェクト説明)"
            ;;
    esac
    
    echo "   📄 .gitignore (Git除外設定)"
    echo "   📄 CLAUDE.md (Claude Code専用設定)"
    echo ""
    
    echo -e "${YELLOW}📋 次のステップ:${NC}"
    echo "1. Claude Codeにログイン"
    echo "   → claude auth login"
    
    case "$PROJECT_TYPE:$FRAMEWORK" in
        "nodejs:"*)
            echo "2. 依存関係をインストール"
            echo "   → npm install"
            echo "3. 開発サーバーを起動"
            if [ "$FRAMEWORK" = "express" ]; then
                echo "   → npm run dev"
            else
                echo "   → npm start"
            fi
            ;;
        "python:"*)
            echo "2. 仮想環境を作成・有効化"
            echo "   → python -m venv venv"
            echo "   → source venv/bin/activate"
            echo "3. 依存関係をインストール"
            echo "   → pip install -r requirements.txt"
            echo "4. アプリを起動"
            echo "   → python app.py"
            ;;
        "rust:")
            echo "2. プロジェクトを実行"
            echo "   → cargo run"
            ;;
        "go:")
            echo "2. プロジェクトを実行"
            echo "   → go run ."
            ;;
    esac
    
    echo "$([ "$PROJECT_TYPE" != "generic" ] && echo "$(( $(echo "1 2 3 4" | wc -w) + 1 ))." || echo "2.") Claude Codeで開発開始！"
    echo "   → claude"
    echo ""
    echo -e "${GREEN}✨ 新しいプロジェクトで素晴らしいものを作りましょう！${NC}"
    echo -e "${BLUE}💡 最初に Claude Code に「このプロジェクトについて教えて」と聞いてみてください${NC}"
}

# メイン実行
main() {
    echo -e "${YELLOW}🎯 現在のディレクトリ: $(pwd)${NC}"
    
    # 空のディレクトリかチェック
    if [ "$(ls -A .)" ]; then
        echo -e "${RED}⚠️  このディレクトリは空ではありません${NC}"
        echo -e "${YELLOW}💡 空のディレクトリで実行することをお勧めします${NC}"
        echo ""
        echo -n "続行しますか？ [y/N]: "
        read -r choice
        case $choice in
            [Yy]*)
                echo -e "${GREEN}✅ 続行します${NC}"
                ;;
            *)
                echo -e "${YELLOW}⏭️  セットアップを中止しました${NC}"
                exit 0
                ;;
        esac
    fi
    echo ""
    
    # Claude Codeインストール
    install_claude_code
    
    # プロジェクトタイプ選択
    choose_project_type
    
    # 初期ファイル作成
    create_initial_files
    
    # プロジェクト専用CLAUDE.md生成
    generate_project_claude_md
    
    # 完了メッセージ
    show_completion
}

main