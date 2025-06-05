# Claude Code Space

GitHub Codespaces上でClaude Codeを使用するための開発環境テンプレートです。

## 🚀 使い方

### 🎯 既存プロジェクトに一発導入（おすすめ！）

任意のプロジェクトでターミナルに以下をコピペするだけ：

```bash
curl -s https://raw.githubusercontent.com/boitoshi/claude-code-space/main/setup.sh | bash
```

**これだけで：**
- プロジェクトタイプを自動検出（Node.js/Python/Rust対応）
- 最適な`.devcontainer/devcontainer.json`を生成
- `CLAUDE.md`をダウンロード
- `.gitignore`を更新
- CodespacesですぐにClaude Codeが使用可能に！

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

## 💡 一発導入の使用例

### 🎯 実際の使い方

```bash
# 既存のReactプロジェクトで
cd my-react-app

# スニペットをコピペ実行
curl -s https://raw.githubusercontent.com/boitoshi/claude-code-space/main/setup.sh | bash

# 出力例：
🚀 Claude Code環境セットアップ開始...
📦 Node.js プロジェクトを検出
✅ .devcontainer/devcontainer.json を作成
✅ CLAUDE.md を作成
✅ .gitignore を更新
🎉 セットアップ完了！

# Codespacesを再起動
# → Ctrl+Shift+P → "Codespaces: Rebuild Container"

# Claude Codeにログイン
claude auth login

# 開発開始！
claude
```

### 📱 対応プロジェクトタイプ

- **Node.js**: `package.json` 検出時
- **Python**: `requirements.txt` または `pyproject.toml` 検出時  
- **Rust**: `Cargo.toml` 検出時
- **汎用**: その他すべてのプロジェクト

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