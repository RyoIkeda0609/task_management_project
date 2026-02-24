# ゴール達成型タスク管理アプリ

> **「目的達成のために、今日やることが分かるアプリ」**

既存のタスク管理アプリでは「何のためのタスクか」が曖昧になりがちです。  
本アプリは **ゴール → マイルストーン → タスク** の 3 階層構造で目標を逆算し、  
今日やるべき行動を明確にすることで継続的な目標達成を支援します。

---

## 主な機能

| 機能               | 概要                                       |
| ------------------ | ------------------------------------------ |
| ゴール管理         | 最上位の目的を作成・編集・削除             |
| マイルストーン管理 | ゴールを中間目標に分解                     |
| タスク管理         | マイルストーンに紐づく具体的な行動を管理   |
| 進捗ダッシュボード | ゴール／マイルストーン単位の達成率を可視化 |
| 本日のタスク       | 今日が期限のタスクを横断的に一覧表示       |

---

## アーキテクチャ

Clean Architecture ベースの 4 層構成を採用しています。

```
lib/
├── domain/          # エンティティ・値オブジェクト・リポジトリインターフェース
├── application/     # ユースケース・プロバイダ定義
├── infrastructure/  # Hive による永続化実装
└── presentation/    # UI（Page / State / ViewModel / Widgets）
```

状態管理には **Riverpod**、永続化には **Hive**、ルーティングには **go_router** を使用しています。

---

## セットアップ

```bash
# 依存パッケージのインストール
cd app
flutter pub get

# テスト実行
flutter test

# 静的解析
flutter analyze

# アプリ起動
flutter run
```

### 動作要件

- Flutter SDK 3.10 以上
- Dart SDK 3.10.8 以上

---

## テスト

```bash
# 全テスト実行
flutter test

# カバレッジ付きで実行
flutter test --coverage

# カバレッジレポートを HTML で確認 (要 lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## ディレクトリ構成

```
app/
├── lib/
│   ├── main.dart
│   ├── domain/
│   │   ├── entities/          # Goal, Milestone, Task
│   │   ├── value_objects/     # ItemTitle, ItemDeadline, Progress など
│   │   ├── repositories/     # リポジトリインターフェース
│   │   └── services/         # ドメインサービス（完了判定など）
│   ├── application/
│   │   ├── use_cases/        # CRUD・検索・進捗計算
│   │   ├── providers/        # Riverpod プロバイダ束ね
│   │   └── exceptions/       # ユースケース固有の例外
│   ├── infrastructure/
│   │   └── repositories/     # Hive 実装
│   └── presentation/
│       ├── pages/            # 各画面の Page / State / ViewModel / Widgets
│       ├── routing/          # go_router 設定
│       ├── state_management/ # StateNotifier / Provider 定義
│       └── theme/            # テーマ定義
├── test/                     # 単体・ウィジェットテスト
├── pubspec.yaml
└── analysis_options.yaml
```

---

## ライセンス

Private — 社内利用
