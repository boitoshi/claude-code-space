# Claude Code Space

GitHub Codespaces上でClaude Codeを使用するための開発環境テンプレートです。

## 🚀 使い方

### 🎯 Claude Code導入方法（3つのパターン）

#### 🆕 初期プロジェクト作成（新規開発用）
```bash
curl -s https://raw.githubusercontent.com/boitoshi/claude-code-space/main/setup-init.sh | bash
```

**初期プロジェクト作成の特徴：**
- 空のディレクトリで使用
- 技術スタック選択（Express/React/Vue/TypeScript/Python/Rust/Go等）
- プロジェクトテンプレート自動生成
- 選択した技術専用のCLAUDE.md作成
- すぐに開発開始可能

#### ⚡ 軽量版（既存プロジェクト用）
```bash
curl -s https://raw.githubusercontent.com/boitoshi/claude-code-space/main/setup-light.sh | bash
```

**軽量版の特徴：**
- Claude Codeのみインストール（devcontainer不要）
- プロジェクト専用CLAUDE.mdを動的生成
- 既存package.json/tsconfig.json等を解析して最適化
- 軽快で高速な開発環境

#### 🔧 選択式（フル機能）
```bash
curl -s https://raw.githubusercontent.com/boitoshi/claude-code-space/main/setup.sh | bash
```

**選択式セットアップ:**
1. **軽量版** - Claude Code + プロジェクト専用CLAUDE.md
2. **フル版** - devcontainer + Claude Code + CLAUDE.md

**共通機能：**
- プロジェクトタイプを自動検出（Node.js/Python/Rust/Go対応）
- 技術スタック詳細検出（React/Vue/TypeScript/Tailwind等）
- プロジェクト固有のCLAUDE.mdを動的生成
- `.gitignore`を更新

### 1. テンプレートとして使う場合

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/boitoshi/claude-code-space)

または：

1. このリポジトリをフォーク
2. 「Code」→「Codespaces」→「Create codespace on main」をクリック

### 2. Claude Codeの設定

Codespaces起動後、Claude Codeが自動的にインストールされます：

```bash
# Claude Codeにログイン
claude auth login

# APIキーを設定（初回のみ）
# ブラウザが開くのでAnthropicアカウントでログイン
```

### 3. Claude Codeの基本的な使い方

```bash
# 対話モードで開始
claude

# ファイルを指定して開始
claude path/to/file.js

# 特定のディレクトリで開始
claude --directory ./src

# ヘルプを表示
claude --help
```

## 📁 プロジェクト構成

```
.
├── .devcontainer/
│   └── devcontainer.json    # Codespaces設定
├── .gitignore               # Git除外ファイル
├── CLAUDE.md               # Claude Code用指示ファイル
├── package.json            # Node.js設定
└── README.md               # このファイル
```

## 🛠️ 開発環境

- **Node.js**: 22.x
- **Claude Code**: 最新版（自動インストール）
- **VS Code Extensions**: TypeScript、Prettier、JSON

## 💡 導入例

### 🆕 初期プロジェクト作成の使い方

```bash
# 空のディレクトリで実行
mkdir my-new-project && cd my-new-project

# 初期プロジェクト作成スクリプト実行
curl -s https://raw.githubusercontent.com/boitoshi/claude-code-space/main/setup-init.sh | bash

# 選択画面が表示される：
🚀 新しいプロジェクトの種類を選択してください:
1) Node.js (Express.js API)
2) Node.js (React アプリ)
3) Node.js (Vue.js アプリ)
4) TypeScript (基本設定)
5) Python (Flask/FastAPI)
6) Python (Django)
7) Rust (基本設定)
8) Go (基本設定)
9) 汎用プロジェクト

選択 [1-9]: 1

# Express.jsプロジェクトが自動生成される
✅ Express.js プロジェクトファイルを作成
📁 初期プロジェクトファイルを作成中...
📝 プロジェクト専用CLAUDE.mdを生成中...
🎉 初期プロジェクトセットアップ完了！

# すぐに開発開始！
npm install
npm run dev
claude
```

### 🎯 軽量版の使い方（既存プロジェクト）

```bash
# 既存のReactプロジェクトで
cd my-react-app

# 軽量版スニペットをコピペ実行
curl -s https://raw.githubusercontent.com/boitoshi/claude-code-space/main/setup-light.sh | bash

# 出力例：
⚡ Claude Code 軽量セットアップ開始...
🔧 Claude Codeをインストール中...
✅ Claude Code をインストールしました
🔍 プロジェクトを解析中...
✅ 検出結果:
   プロジェクト: nodejs
   フレームワーク: react
   言語: typescript
   スタイリング: tailwind
   テスト: vitest
📝 プロジェクト専用CLAUDE.mdを生成中...
✅ プロジェクト専用 CLAUDE.md を生成
🎉 軽量版セットアップ完了！

# Claude Codeにログイン
claude auth login

# 開発開始！
claude
```

### 🔧 選択式の使い方

```bash
# プロジェクトで選択式セットアップ
curl -s https://raw.githubusercontent.com/boitoshi/claude-code-space/main/setup.sh | bash

# 選択画面が表示される：
⚡ セットアップモードを選択してください:
1) 軽量版 (Claude Code + プロジェクト専用CLAUDE.mdのみ) [推奨]
2) フル版 (devcontainer + Claude Code + CLAUDE.md)
3) キャンセル

選択 [1-3]: 1

# 軽量版が実行される
```

### 📱 対応プロジェクトタイプ

- **Node.js**: `package.json` 検出時
  - フレームワーク: React, Vue, Next.js, Angular
  - 言語: JavaScript, TypeScript
  - スタイリング: Tailwind CSS, Styled Components  
  - テスト: Jest, Vitest, Cypress
  - ビルドツール: Vite, Webpack
- **Python**: `requirements.txt` または `pyproject.toml` 検出時
- **Rust**: `Cargo.toml` 検出時
- **Go**: `go.mod` 検出時
- **汎用**: その他すべてのプロジェクト

### ✨ 新機能

#### 🎨 プロジェクト専用CLAUDE.md動的生成
従来の固定テンプレートではなく、プロジェクトを解析して：
- 使用している技術スタック情報
- 実際のnpm scripts（`npm run dev`, `npm test`等）
- 設定ファイル情報（tsconfig.json, .eslintrc等）
- プロジェクト固有のコーディング規約

これらを含んだCLAUDE.mdを自動生成！

#### ⚡ 軽量版セットアップ
個人開発に特化したdevcontainer不要の軽量版で：
- 高速セットアップ（秒単位）
- Claude Codeのみインストール
- 重いDockerコンテナ不要
- ローカル開発環境と相性抜群

## 💡 Claude Codeの使い方

### コード生成

```bash
claude
> 新しいExpress.jsサーバーを作成してください
```

### コードレビュー

```bash
claude app.js
> このコードの問題点を教えてください
```

### リファクタリング

```bash
claude
> src/フォルダ内のコードをTypeScriptに変換してください
```

## 📚 参考リンク

- [Claude Code公式ドキュメント](https://docs.anthropic.com/en/docs/claude-code)
- [GitHub Codespaces](https://github.com/features/codespaces)
- [Anthropic API](https://console.anthropic.com/)

## 🤝 コントリビューション

1. フォークしてください
2. フィーチャーブランチを作成してください (`git checkout -b feature/amazing-feature`)
3. 変更をコミットしてください (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュしてください (`git push origin feature/amazing-feature`)
5. プルリクエストを開いてください

## 📄 ライセンス

このプロジェクトはISCライセンスの下で公開されています。