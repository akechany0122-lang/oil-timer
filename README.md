# Oil Timer

ガラスの中をオイルがしずくになって流れ落ちる、癒しのWebオイルタイマー。

**▶ https://akechany0122-lang.github.io/oil-timer/**

- タイマーを上下にドラッグ（またはボタン）でひっくり返すとスタート
- 左右にドラッグでガラスの奥行きを見る
- 8種類のデザイン（階段・水車・レイン・3連・シーソー・風車・ジグザグ・振り子）とカラー
- 1分〜60分（自由設定も可）。長い時間でも、しずくのリズムはそのままにオイルの減り方で時間を刻みます
- **背景なしでデスクトップに置く**：デスクトップアプリ（無料）をダウンロード
  - Mac：[OilTimer-mac.zip](https://github.com/akechany0122-lang/oil-timer/releases/download/desktop/OilTimer-mac.zip)（展開して「アプリケーション」へ。初回は「システム設定 → プライバシーとセキュリティ → このまま開く」）
  - Windows：[OilTimer-Setup-win.exe](https://github.com/akechany0122-lang/oil-timer/releases/download/desktop/OilTimer-Setup-win.exe)（警告が出たら「詳細情報 → 実行」）
  - 一度起動すると、サイトの「デスクトップに置く」ボタンから今のデザイン・色・時間のまま開きます
- Chrome / Edge では、アプリなしでも小窓でデスクトップに浮かべられます

`index.html` ひとつで動きます（three.js を CDN から読み込み）。

`electron/` はデスクトップアプリ（Mac / Windows）のソースです。`main` に変更を push すると GitHub Actions が自動でビルドし、リリース「desktop」に添付します。

`desktop/` は macOS 専用の軽量版（Swift）のソースです（`bash desktop/build.sh` でビルド）。
