# リリースタスク（初回リリース準備）

> 対象：タスクピラミッド（ゴール達成型タスク管理アプリ）  
> 作成日：2026-02-23  
> MVP リリース目標：2026年6月

---

## Ⅰ. アプリ識別子・名前の設定（必須・最優先）

> `com.example.app` のままではストアに提出できない。  
> 一度公開すると applicationId / Bundle ID は変更不可のため慎重に決定すること。

- [ ] **正式な applicationId / Bundle Identifier を決定する**
  - 例: `com.yourcompany.taskpyramid` / `jp.yourcompany.taskpyramid`
- [ ] Android `applicationId` を変更する
  - ファイル: `android/app/build.gradle.kts` → `applicationId = "com.example.app"`
- [ ] Android `namespace` を変更する
  - ファイル: `android/app/build.gradle.kts` → `namespace = "com.example.app"`
- [ ] Android の Kotlin パッケージディレクトリを変更する
  - 現在: `android/app/src/main/kotlin/com/example/app/MainActivity.kt`
  - `MainActivity.kt` 内の `package` 宣言も合わせて修正
- [ ] iOS `PRODUCT_BUNDLE_IDENTIFIER` を変更する
  - ファイル: `ios/Runner.xcodeproj/project.pbxproj`（Xcode上で変更推奨）
- [ ] `pubspec.yaml` の `description` をアプリの説明に変更する
  - 現在: `"A new Flutter project."`

---

## Ⅱ. アプリ表示名の統一（必須）

> 現在 Android=`"app"`, iOS=`"App"`, Web=`"app"` とバラバラかつデフォルトのまま。

- [ ] Android アプリ名を変更する
  - ファイル: `android/app/src/main/AndroidManifest.xml` → `android:label="app"` を正式名に
- [ ] iOS 表示名を変更する
  - ファイル: `ios/Runner/Info.plist`
  - `CFBundleDisplayName` → 正式名（例: `タスクピラミッド`）
  - `CFBundleName` → 正式名
- [ ] Web タイトルを変更する
  - ファイル: `web/index.html` → `<title>app</title>` を正式名に
  - `apple-mobile-web-app-title` の `content="app"` も変更
  - `<meta name="description">` も正式な説明文に変更
- [ ] Web manifest.json を変更する
  - ファイル: `web/manifest.json`
  - `"name"`: 正式名
  - `"short_name"`: 正式名（短縮）
  - `"description"`: 正式な説明文

---

## Ⅲ. Android リリースビルド署名設定（必須）

> 現在 debug キーで署名されており、Google Play には提出できない。

- [ ] **リリース用 Keystore を作成する**
  - `keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release`
  - Keystore は安全な場所にバックアップすること（紛失するとアプリ更新不可）
- [ ] `android/key.properties` を作成する
  ```
  storePassword=<パスワード>
  keyPassword=<パスワード>
  keyAlias=release
  storeFile=<Keystoreのパス>
  ```
- [ ] `android/app/build.gradle.kts` に署名設定を追加する
  - `signingConfigs` ブロックにリリース用設定を追加
  - `buildTypes.release` で `signingConfig` をリリース用に変更
- [ ] `.gitignore` に `key.properties` を追加する（署名情報の漏洩防止）
- [ ] `.gitignore` に `*.jks` を追加する

---

## Ⅳ. Android 追加設定（推奨）

- [ ] `minSdk` を明示的に設定する（現在 Flutter SDK デフォルト=21）
  - ファイル: `android/app/build.gradle.kts`
  - Hive 等の依存による最低バージョン要件を確認
- [ ] ProGuard / R8 難読化ルールを検討する
  - `android/app/proguard-rules.pro` を作成
  - `build.gradle.kts` の release ブロックで有効化
- [ ] INTERNET パーミッションの要否を確認する
  - 現在 `AndroidManifest.xml` に未設定
  - MVP はオフライン前提だが、Phase2 以降に備えて追加を検討

---

## Ⅴ. iOS 追加設定（推奨）

- [ ] ExportOptions / 配布証明書（Distribution Certificate）を準備する
- [ ] App Store Connect にアプリを登録する
  - Bundle ID 登録
  - アプリ情報入力
- [ ] 必要に応じて `NSAppTransportSecurity` を設定する（HTTP通信がある場合）

---

## Ⅵ. Web テーマ・メタ情報（推奨）

- [ ] `web/manifest.json` の `background_color` をブランドカラーに変更する
  - 現在: `#0175C2`（Flutter デフォルト青）
- [ ] `web/index.html` の `<meta name="theme-color">` をブランドカラーに合わせる
- [ ] Web 用のファビコン・アイコンがカスタム画像に差し替わっていることを確認する
  - ※ `flutter_launcher_icons` で生成済み → 目視確認

---

## Ⅶ. スプラッシュ画面（推奨）

- [ ] Android スプラッシュ画面をカスタマイズする
  - `android/app/src/main/res/drawable/launch_background.xml` — 現在デフォルト白
  - `android/app/src/main/res/drawable-v21/launch_background.xml` — 同上
- [ ] iOS スプラッシュ画面をカスタマイズする
  - `ios/Runner/Base.lproj/LaunchScreen.storyboard`
- [ ] `flutter_native_splash` パッケージの利用を検討する

---

## Ⅷ. ストア提出物の準備（必須）

> ロードマップ（5_roadmap.md）に記載のリリース準備項目

- [ ] **プライバシーポリシーを作成・Webに掲載する**（ストア提出に必須）
- [ ] **利用規約を作成・Webに掲載する**
- [ ] ストア用スクリーンショットを用意する
  - iOS: 6.7インチ（iPhone 15 Pro Max等）、5.5インチ（iPhone 8 Plus等）
  - Android: 主要画面のスクリーンショット
- [ ] ストア用アプリ説明文を作成する（日本語・必要に応じて英語）
- [ ] ストア用キーワード・カテゴリを決定する
  - カテゴリ候補: 仕事効率化
- [ ] 年齢レーティングを登録する
- [ ] Google Play ストアアイコン（512x512）を確認する
  - ソース: `task_pyramid_icon_assets/google_play_512.png`（配置済み）

---

## Ⅸ. バージョン情報（確認）

- [ ] `pubspec.yaml` の `version` を確認・調整する
  - 現在: `1.0.0+1`（初回リリースとして妥当）
- [ ] 価格設定を決定する
  - ロードマップ記載: 1,000円（買い切り）

---

## Ⅹ. 最終確認（リリース直前）

- [ ] `flutter build appbundle --release` でリリースビルドが通ることを確認
- [ ] `flutter build ipa --release` でリリースビルドが通ることを確認
- [ ] 実機（Android / iOS）でリリースビルドの動作確認
- [ ] `release_task.md` の技術品質監査チェックリストを完了する
- [ ] Google Play Console にアップロード・内部テスト
- [ ] App Store Connect にアップロード・TestFlight テスト
