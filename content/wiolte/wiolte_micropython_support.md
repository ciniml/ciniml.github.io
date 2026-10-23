---
title: "Wio LTEをMicroPythonで使ってみる本"
---
## 概要

技術書典4で頒布した *Wio LTEをMicroPythonで使ってみる本* のサポートページです。

## 更新情報

2018.06.02 MicroPython 1.9.4をベースにアップデート。USB用のピン定義がないとコンパイルエラーになるのを修正。

## ビルド済みMicroPythonバイナリ

Wio LTE用のMicroPythonのファームウェアは [ここ](mpy_wio_lte.zip) からダウンロードできます。書き込みは:

``` text
dfu-util --alt 0 --download firmware.dfu
```

でできます。

## 関連リポジトリ

[forkしたMicroPythonのリポジトリの wiolte ブランチ](https://github.com/ciniml/micropython/tree/wiolte)

[LTEモジュール・ドライバ、SORACOM Harvest、Beamに接続するプログラム](https://github.com/ciniml/mpy-wiolte)
