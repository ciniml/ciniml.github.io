Windows10 64bitでQuartus Prime (Lite) 17.1付属のIntel HLS Compilerを試す
==============================================================================

概要
--------
Intel HLS Compilerがクローズドβからオープンβ、もとい正式公開されたので、Windows10 64bitでサンプルの実行まで試した。


背景
--------
Intel HLS Compilerがリリースされたと聞いて、Vivado HLSみたいなツールを想像してQuartusをインストールして立ち上げて、Toolメニューを見てもそれっぽいものがない。

おかしいなと思っていると、リファレンスマニュアルのURLがTwitterに流れてきたので、必須要件とインストール方法を確認すると、どうも `i++` なるぐぐらびりてぃの低いコマンドが追加されたようであった。
しかも、必須要件 [1]_ として

* Linux版: GCC 4.4.7
* Windows版: Visual Studio Professional 2010

とか書いてある始末である。

Visual Studio Professional 2010とか使えるライセンスを持っているかつHLSに興味を示す人はそんなに多くないと思ったので、とりあえず Visual Studio 2010 Express で動かせるようにする手順を調べた。

.. [1] https://www.altera.co.jp/content/altera-www/global/en_us/index/documentation/ewa1462479481465.html#lpd1467738276041

必要なもの
----------

* Windows7以降の `64bit` OS (未確認：筆者はWin10 Pro Fall Creators Update適用後でしか試していない)
    - どうも、Intel HLS Compilerのライブラリが64bitでコンパイルされているらしい。
* Quartus Prime 17.1 (Lite)
* ModelSim Altera Starter Edition
    - IntelのサイトからDLして入れておく。
* Visual Studio 2010 Express
    - `ここ <https://www.visualstudio.com/ja/vs/older-downloads/?rr=https%3A%2F%2Fwww.google.co.jp%2F>`_ からダウンロードできる。
    - ただし、Microsoftアカウントが必要 (MSDN Subscriptionは必要ない)
* Microsoft Windows SDK for Windows 7 and .NET Framework 4 のISOイメージ (以降Windows 7 SDKのISOイメージと呼ぶ)
    - Visual Studio 2010 Expressには64bit版コンパイラが含まれないので、Windows SDKに入っている64bit版コンパイラが必要
    - `ここ <https://www.microsoft.com/en-us/download/details.aspx?id=8442>`_ からダウンロードできる。
    - GRMSDK_EN_DVD.iso にチェックを入れて *Next* を押す。

Quartus Primeのインストール手順は特に書かないのでインストールしておくこと。

Visual Studio 2010 Expressはインストーラに従って特にオプションを変更することなくインストールすれば問題ないはずである。

Windows SDKのインストール
--------------------------

Windows 10でWindows 7 SDKを普通に入れようとすると、.NET Frameworkがプレリリース版が入っているので肝心の64bit版C++コンパイラがインストールできないとか言われる。
Fall Creators Updateだけの現象かもしれないが、回避策を書いておく。
以下の手順に従えば、要らないものが入らないので一石二鳥である。

1. Windows 7 SDKのISOイメージをマウントする。(Windows 10なら、ダブルクリックするなどして開けば勝手にマウントする。)
2. Setupディレクトリ以下の次のディレクトリにあるMSIインストーラを実行してインストールする。
    * vc_stdamd64
    * vc_stdx86
    * WinSDKBuild

これでWindows 7 SDKから必要最低限のパッケージをインストールすることができる。

環境設定用バッチファイル
--------------------------

以降、Quartus Prime 17.1 Liteを ``C:\intelFPGA_lite\17.1`` にインストールしたものとして説明するので適宜読み替えていただきたい。

Intel HLS Compilerを実行するには、コマンドプロンプト上で ``C:\intelFPGA_lite\17.1\hls\init_hls.bat`` を実行して、環境変数を設定する必要がある。
ただし、init_hls.batを実行する前にVC++のコンパイラやヘッダ、ライブラリ、ModelSimへのパスを通しておく必要がある。

面倒だったので `バッチファイル <https://gist.github.com/ciniml/60ccbf916da60cc728df6500c847ef26>`_ を作っておいたので確認の上使っていただければと思う。

バッチファイルの先頭の::

    @set INTELFPGA_DIR=C:\intelFPGA_lite
    @set INTELFPGA_VER=17.1
    @set INTELFPGA_ROOT=%INTELFPGA_DIR%\%INTELFPGA_VER%
    @set MODELSIM_TYPE=modelsim_ase

の部分は環境に合わせて適宜変更する必要がある。

``INTELFPGA_DIR`` はQuartusをインストールしたディレクトリのフルパスを指定する。

``MODELSIM_TYPE`` はModelSim Altera Starter Editionを入れた場合は ``modelsim_ase`` 、Altera Editionの場合は ``modelsim_ae`` とする。

Intel HLS Compilerの実行
---------------------------

上記のバッチファイルを実行すると、Intel HLS Compilerを使用できる状態のコマンドプロンプトが開く。
とりあえずサンプルを実行するために、どこか適当な作業用ディレクトリに移動する。

その後、::

    robocopy /S /E "%HLS_ROOT%\examples\*" .
    cd counter
    build test-msvc
    test-msvc.exe

とすることで、counterサンプルのコピー、ビルド、実行を行うことができる。
サンプルを実行しても、PASSEDと表示されるだけなので何かよくわからないが。

また、buildコマンドに test-fpga と指定すると、高位合成の結果をModelSimを使ってシミュレーションするようである。これもPASSEDと表示されるだけなのでよくわからない。

とりあえずコード見てみるしかないようである。


参考
------

Visual C++ 2010 Expressで64bitコンパイル
    http://d.hatena.ne.jp/torutk/20100927/p1

Intel High Level Synthesis Compiler Prerequisites
    https://www.altera.co.jp/content/altera-www/global/en_us/index/documentation/ewa1462479481465.html#lpd1467738276041
