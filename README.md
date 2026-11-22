# 福田ちえ 公式サイト

静的HTML（ビルド不要）。`main` に push すると Vercel（プロジェクト f-chie）に自動デプロイされます。

| パス | 内容 |
|---|---|
| `/` (index.html, css/, js/, images/, video/) | トップページ |
| （外部）| 地域支え合い研究会の開催記録は Jimdo（www.f-chie.jp の研究会ページ）で管理。トップのボタンから別ウィンドウで開く |
| `/2/*.html` | 議会活動・政策・プロフィール・お問い合わせ等の詳細ページ（トップからリンク） |
| `/api/contact.js` | お問い合わせフォーム送信（Resend） |

旧URL（/4-1/ や /1〜/5）は vercel.json でトップへリダイレクトしています。

## Firebase Hosting（プロジェクト f-chie）
- `firebase.json` / `.firebaserc` に設定。`main` に push すると GitHub Actions（firebase-hosting.yml）で公開します。
- GitHub の Secrets に `FIREBASE_SERVICE_ACCOUNT` が登録されるまでは、公開ステップはスキップされます。
- お問い合わせフォームの送信API（api/）は Vercel 専用のため、Firebase 版では送れず、フォームはメール・電話での案内に切り替わります。
