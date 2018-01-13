Wio LTEでMicroPythonを動かす
============================

概要
------

Seeed StudioのLTE通信モジュール付きボードであるWio LTEで、組み込み向けのPython実装であるMicroPythonを動かしてとりあえずLチカまでしてみた。

`ビルド済みイメージ <mpy-seeed_wio_lte.zip>`_

Wio LTE
----------

Wio LTEは、STMicroelectronicsのCortex-M4Fマイコン *STM32F405* とQuectelのLTE通信モジュール *EC21-J* を搭載したLTEによる通信を用いるシステムを構築するためのプロトタイプ用ボードである。

Seeed Studioが開発・製造しているため、同社のモジュール接続規格である、 *Groove* に準拠したモジュールを接続することができる。

`公式の開発環境 <http://wiki.seeed.cc/Wio_LTE_Cat.1/>`_ としては、Arduino IDEおよび、JavaScriptを使ったプロトタイピング環境である *Espriuno* を `サポート <http://www.espruino.com/WioLTE>`_ している。

`SORACOM <https://soracom.jp/products/wio_lte/>`_、`スイッチサイエンス <https://www.switch-science.com/catalog/3600/>`_、`秋月電子通商 <http://akizukidenshi.com/catalog/g/gM-12855/>`_　などから入手できる。

MicroPythonのビルド
---------------------

WindowsのMSYS2上でビルドを試したが、シンボリックリンクなどいろいろうまくいかないところがあるので、おとなしくWindows10上のWSL上でビルドした。
もちろん、通常のLinuxでも問題ないはずである。

まずは、Linux上で `MicroPythonのリポジトリ <https://github.com/micropython/micropython>`_ からソースコードをcloneする。
また、MicroPython用のライブラリが `micropython-libリポジトリ <https://github.com/micropython/micropython-lib>`_ にあるので、こちらもcloneしておく。このとき、clone先の名前はmicropython-libのままになるようにしておく。

cloneしたMicroPythonのリポジトリのportsディレクトリ以下に、対応しているプラットフォームごとのソースコードやビルド用のスクリプトが配置されている。
Wio LTEはSTM32を使用しているので、 `ports/stm32` ディレクトリに移動する。

`ports/stm32/board` ディレクトリ以下には、対象のボードごとの設定が入っている。標準ではWio LTE用の設定がないため、を `SEEED_WIO_LTE` 等の名前で一番構成の近い *NETDUINO_PLUS_2* のコピーを作成する。。

コピーした SEEED_WIO_LTE ディレクトリの下には、以下のファイルがある。

board_init.c
    ボード固有の初期化コードを含むファイル。今回は使用しないので削除する。

mpconfigboard.h
    UART, SPI, I2CといったMicroPythonがサポートしているペリフェラルの割り当てといったボードの機能を定義するファイル。
    Wio LTEに対応するように変更する必要がある。

mpconfigboard.mk
    ビルドの設定を定義するファイル。Wio LTEは NETDUINO Plus 2と同じ設定を使うので、変更する必要はない。

pins.csv
    GPIOのピンの名称を設定するファイル。必要に応じて変更する。

stm32f4xxx_hal_conf.h
    STM32のHALライブラリを設定するためのファイル。STM32 Cube MXを使って生成したファイルをベースに、MicroPythonで使えるように手を加える必要がある。

上記のファイルを `Wio LTE用に変更したもの <SEEED_WIO_LTE.zip>`_ を置いておくので、boardsディレクトリ以下に展開する。

その後、 `ports/stm32` ディレクトリで ::

    $ make BOARD=SEEED_WIO_LTE

とすると、 `ports/stm32/build-SEEED_WIO_LTE/firmware.dfu` にDFUで書き込むためのイメージが生成される。


書き込み
----------

作成したイメージの書き込みには、Arduino IDEを使った場合と同様に dfu-tool を用いる。

dfu-toolのビルド済みバイナリが `Seeed Studioにのリポジトリ <https://github.com/Seeed-Studio/Seeed_Platform>`_ に用意されているので、これを `ダウンロード <https://github.com/Seeed-Studio/Seeed_Platform/raw/master/stm32_dfu_upload_tool_v1.0.0.tar.bz2>`_ する。
ファイル名は `stm32_dfu_upload_tool_vx.y.z.tar.bz2` である。(x.y.zはバージョン番号)

ダウンロードしたファイルを展開すると、`stm32_dfu_upload_tool\win`以下にWindows用のバイナリがあるので、どこか使いやすいところにコピーする。
以降、`C:\dev\dfu-util` にコピーしたものとして説明する。

`--list` オプションを付けて実行すると、現在接続されているDFU対象デバイスのリストを表示する。 ::

    > C:\dev\dfu-util\dfu-util --list

    dfu-util 0.8

    Copyright 2005-2009 Weston Schmidt, Harald Welte and OpenMoko Inc.
    Copyright 2010-2014 Tormod Volden and Stefan Schmidt
    This program is Free Software and has ABSOLUTELY NO WARRANTY
    Please report bugs to dfu-util@lists.gnumonks.org

    Found DFU: [0483:df11] ver=2200, devnum=22, cfg=1, intf=0, alt=3, name="@Device Feature/0xFFFF0000/01*004 e", serial="396036853436"
    Found DFU: [0483:df11] ver=2200, devnum=22, cfg=1, intf=0, alt=2, name="@OTP Memory /0x1FFF7800/01*512 e,01*016 e", serial="396036853436"
    Found DFU: [0483:df11] ver=2200, devnum=22, cfg=1, intf=0, alt=1, name="@Option Bytes  /0x1FFFC000/01*016 e", serial="396036853436"
    Found DFU: [0483:df11] ver=2200, devnum=22, cfg=1, intf=0, alt=0, name="@Internal Flash  /0x08000000/04*016Kg,01*064Kg,07*128Kg", serial="396036853436"


`micropython\ports\stm32\build-SEEED_WIO_LTE\firmware.dfu` をビルドしたDFU用イメージのパスとする。 ::


    > C:\dev\dfu-util\dfu-util -i 0 -a 0 -D micropython\ports\stm32\build-SEEED_WIO_LTE\firmware.dfu
    dfu-util 0.8

    Copyright 2005-2009 Weston Schmidt, Harald Welte and OpenMoko Inc.
    Copyright 2010-2014 Tormod Volden and Stefan Schmidt
    This program is Free Software and has ABSOLUTELY NO WARRANTY
    Please report bugs to dfu-util@lists.gnumonks.org

    Match vendor ID from file: 0483
    Match product ID from file: df11
    Opening DFU capable USB device...
    ID 0483:df11
    Run-time device DFU version 011a
    Claiming USB DFU Interface...
    Setting Alternate Setting #0 ...
    Determining device status: state = dfuERROR, status = 10
    dfuERROR, clearing status
    Determining device status: state = dfuIDLE, status = 0
    dfuIDLE, continuing
    DFU mode device DFU version 011a
    Device returned transfer size 2048
    DfuSe interface name: "Internal Flash  "
    file contains 1 DFU images
    parsing DFU image 1
    image for alternate setting 0, (2 elements, total size = 301816)
    parsing element 1, address = 0x08000000, size = 14984
    Download        [=========================] 100%        14984 bytes
    Download done.
    parsing element 2, address = 0x08020000, size = 286816
    Download        [=========================] 100%       286816 bytes
    Download done.
    done parsing DfuSe file

以上で書き込みは完了なので、ボードのリセットボタンを押してリセットする。

Lチカ
------

リセットすると、接続しているPCからは、シリアルポートとストレージとして見えるようになる。

対応するシリアルポートをTeraTermなどで開き、Enterを入力すると、`>>>` のようにPythonのREPLのプロンプトが表示される。

この状態でdir()関数を実行すると、 ::

    >>> dir()
    ['machine', '__name__', 'pyb']
    >>>

のように、グローバル空間にあるシンボルの名前が表示される。
また、以下のコードを入力して実行すると、1秒ごとに　`RX_LED (PB13)` ピンに接続されたLEDが点滅するのを10回繰り返す。 ::

    pin = pyb.Pin('RX_LED')
    pin.init(pin.OUT_PP)
    for i in range(0, 20):
        pin.value(not pin.value())
        pyb.delay(1000)

LTE通信
--------

EC-21の制御コードをMicroPythonに移植していないので、LTE通信はまだできない。

参考
------------

micropython/micropython
    https://github.com/micropython/micropython/

