Wio LTEをMicroPythonで使ってみる本
==================================

概要
------

技術書典4で頒布した *Wio LTEをMicroPythonで使ってみる本* のサポートページです。

ビルド済みMicroPythonバイナリ
------------------------------

Wio LTE用のMicroPythonのファームウェアは `ここ <mpy_wio_lte.zip>`_ からダウンロードできます。書き込みは: 

    dfu-util --alt 0 --download firmware.dfu

でできます。


関連リポジトリ
---------------------

`forkしたMicroPythonのリポジトリの wiolte ブランチ <https://github.com/ciniml/micropython/tree/wiolte>`_

`LTEモジュール・ドライバ、SORACOM Harvest、Beamに接続するプログラム <https://github.com/ciniml/mpy-wiolte>`_
