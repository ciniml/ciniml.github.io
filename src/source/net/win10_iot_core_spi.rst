Windows10 IoT Core on RPi2のSPIのパフォーマンス
===============================================================

概要
------
Windows 10 IoT CoreのSPI経由でセンサデータを取得する際にどれくらいのデータが転送できるかを確認するため、SPIのスループットを計測してみた。
(書きかけ)

作ったもの
---------
ソースコードは `GitHubのリポジトリ <https://github.com/ciniml/IoTCoreIoTest>`_ にて公開している。

* 受信したAdvertisementの送信元BLEデバイスの名前とアドレス、RSSI値を表示するアプリケーション
    - Windows 10 IoT CoreもしくはWindows10TP上で動作する。
* Windows 10 IoT Coreで特定のVID/PIDを持つデバイス用に標準BluetoothドライバをインストールするためのINFファイル生成ツール
    - Windows 10 IoT Coreのシステム上にある *BTH_MC.inf* に後述の手順の加工を施したものを生成する

計測内容
--------
Interface誌の10月号の特集にて、30[MHz]のSPIの信号をRPi2から出力して波形を測定していたので、同様にWindows 10 IoT CoreをSPIマスタとして信号を出力して測定してみた。
SpiDeviceクラスの出力用メソッドには以下の3種類があるため、それぞれでどう変化するかを測定した。

* Write
* TransferFullDuplex
* TransferSequential


結果
-----
とても遅い。
30[MHz]なのでせめて20[Mbps]程度は出てほしいものであるが、1[Mbps]程度しか出ていない。

さすがにもう少しスループットが出るものだと思っていたので、なぜ遅いのか原因を調べてみることにした。

割り込み頻度の測定
---------------
スループットが出ていない原因として考えられるのが、SPIペリフェラルのドライバ(bcmspi.sys)がDMAを使用せず、PIO転送を行っている可能性である。
このような場合、SPIの転送完了割り込みで次のデータを設定している可能性が高いので、割り込みタイミングを確認することにした。

幸い、Windows 10 IoT Coreでは非常に簡単にETW [#etw]_ によるパフォーマンストレースが取得できるので、パフォーマンストレースを取得して解析することにする。

まず、ブラウザから `<RPi2のIPアドレス>:8080` にアクセスしてWebBを表示する。



.. rubric:: 脚注
    
.. [#etw] `第1回　OS機能によるアプリのパフォーマンス測定 <http://www.atmarkit.co.jp/fdotnet/chushin/vsperf_01/vsperf_01_02.html>`_
