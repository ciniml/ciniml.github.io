# ふがふが (www.fugafuga.org)

[Hugo](https://gohugo.io/) で生成している個人サイトです。

- 記事: `content/<カテゴリ>/<名前>.md` → `/<カテゴリ>/<名前>.html`
- カテゴリ: `content/<カテゴリ>/_index.md` → `/<カテゴリ>.html`（`url` で固定）
- 画像: `static/images/`（記事からは `/images/xxx.png` で参照）
- 配布ファイル: `static/` 以下に公開したいパスで配置

書籍から参照しているサポートページの URL は変えないこと。

## ビルドと公開

GitHub Pages は master ブランチの `docs/` を公開しています。生成物は手元でビルドしてコミットします。

```sh
hugo server          # ローカルで確認
scripts/build.sh     # docs/ を生成
git add -A && git commit
git push
```

`.githooks/pre-push` が、push するコミットをビルドした結果とコミット済みの `docs/` を比較し、
一致しなければ push を中止します。clone し直したときは次のコマンドでフックを有効にしてください。

```sh
git config core.hooksPath .githooks
```
