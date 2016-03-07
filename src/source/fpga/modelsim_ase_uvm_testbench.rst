ModelSim Altera Starter EditionでUVM1.2を使ったテストベンチを実行する
=========================================================================

概要
--------
Qsysのコンポーネントを作って検証するためにSystemVerilogを習得中に、UVMなるフレームワークがあるというのを見て試してみたくなったので、ModelSim Altera Starter Editionで試してみた。

背景
--------
Qsysのコンポーネントの検証のためAvalon BFMを使ったテストベンチをVHDLで書いてみたが、VerilogのAPIと比較して、BFMのIDを渡したうえでコマンド送信のインターフェースを表すsignalを渡す必要があるなど非常に面倒だった。
そこで、Qsysで生成されたシミュレーション用のコードを見ると殆どが*.svの拡張子のSystemVerilogのファイルとなっていたため、SystemVerilogがQsysのテストベンチを書くメインの言語なのだろうと思いSystemVerilogでテストベンチを書いた。

SystemVerilogでテストベンチを書いている最中に、テストベンチ記述のためのなにか良いパッケージがないのかと思って検索したところ、UVMというものがあると分かったので試して見ることにした。

UVMとは
----------
Universal Verification Methodologyの略らしい。多分TLMとかその辺のお仲間だと思っている。詳しくはAccelleraが後悔しているUser Guideを読むと良いはず。
現状、テストベンチ書くためのフレームワーク程度の認識。

テストベンチでの記法
--------------------------
テストベンチのファイルの先頭などで::

	import uvm_pkg::*;
	`include "uvm_macros.svh"

と書いておけばUVMの各種クラスやマクロなどが使えるようになる。
UVMのクラスの使い方とかはあまり理解してないので、適当に検索するべし。

ModelSim-ASEでの使い方
--------------------------------
QuestaSimでの使い方は出てくるけど、Quartusに付いてくる無償版ModelSimである、ModelSim Altera Starter Editionでの使い方は出てこなかったので、いろいろ試行錯誤した結果使えるようになった。

試したModelSim-ASEのバージョンは `10.4b` であるので、他のバージョンではどうなのかは分からない。

まず、UVM自体はModelSimにソースコードが付属しているようなので、ModelSimからコンパイルしておく。UVMのソースコードはModelSimのインストール先ディレクトリを `C:/altera/15.1/modelsim_ase` とすると::

	C:/altera/15.1/modelsim_ase/verilog_src/uvm-1.2/src

に格納されている。このディレクトリは後でよく使うので、::

	set UVM_SRC C:/altera/15.1/modelsim_ase/verilog_src/uvm-1.2/src

などとして変数に設定しておくと良い。

以下のコマンドでUVMをコンパイルする。::

	vlog -sv $UVM_SRC/uvm.sv +incdir+$UVM_SRC $UVM_SRC/dpi/uvm_dpi.cc -ccflags -DQUESTA

UVMのDPIモジュールを一緒に指定すると、付属のgccでコンパイルされるようである。実に便利。
また、`-ccflags` オプションでgccに渡す引数を指定することができる。 
ModelSim用にコンパイルするためには、 `QUESTA` マクロを定義しないと行けないようなので、`-DQUESTA` を指定している。

次に、UVMのライブラリを追加する。::

	vmap uvm $UVM_SRC

最後に、テストベンチをコンパイルする。テストベンチの名前は `testbench.sv` とする。 ::

	vlog -sv testbench.sv -L uvm +incdir+$UVM_SRC

これで、必要なモジュールのコンパイルが出来たので、シミュレーションを実行する。
ここで、シミュレーション実行時にUVMのDPIモジュールを自動的にリンクするようなので、UVMのモジュールが依存しているライブラリをリンクするようにリンカオプションをvsimコマンドの　`-ldflags` オプションで指定する。
UVMはregexとstdc++に依存しているので、::

	vsim -L work -ldflags -lregex -ldflags -lstdc++ testbench


とする。

Qsysのシミュレーションモデルでの使い方
-----------------------------------
Qsysでシミュレーションモデルを生成すると、`simulation/mentor` ディレクトリ下に `msim_setup.tcl` が生成される。
このスクリプトを `source` で読み込むと、 `elab` というコマンドでシミュレーションを開始できるようになる。
このコマンドは内部で `vsim` を呼び出しているが、その際の引数を `USER_DEFINED_ELAB_OPTIONS` 変数で追加できるので、ここに前述の `-ldflags` を書いておけば良い。

実際に以下のようなスクリプトを作成してシミュレーションを行えることを確認した。::

	set UVM_SRC "C:/altera/15.1/modelsim_ase/verilog_src/uvm-1.2/src"
	set TOP_LEVEL_NAME "testbench"
	set USER_DEFINED_ELAB_OPTIONS "-ldflags -lregex -ldflags -lstdc++ +UVM_TESTNAME=test_0"

	cd ./simulation/mentor
	source ./msim_setup.tcl

	com
	vlog -sv $UVM_SRC/uvm.sv +incdir+$UVM_SRC $UVM_SRC/dpi/uvm_dpi.cc -ccflags -DQUESTA
	ensure_lib $UVM_SRC
	vmap uvm $UVM_SRC

	vlog -sv ../../testbench.sv -L uvm -L altera_common_sv_packages +incdir+$UVM_SRC
	elab

	add wave -position end  sim:/testbench/dut/ft245_sync_streaming_dut/clock
	add wave -position end  sim:/testbench/dut/ft245_sync_streaming_dut/reset

	run -all


参考
------

UVM 1.2 User Guide
	http://www.accellera.org/images//downloads/standards/uvm/uvm_users_guide_1.2.pdf

Release Notes For ModelSim Altera 10.0c
	https://www.altera.com/content/dam/altera-www/global/en_US/others/download/os-support/release-notes_10_0c.txt

Using the UVM libraries with Questa
	https://blogs.mentor.com/verificationhorizons/blog/2011/03/08/using-the-uvm-10-release-with-questa/

	UVM1.1用の内容で、1.2ではうまく行かない。

Problem generating "uvm_dpi.dll" for UVM1.2 for QuestaSim 10.2c in 64 bit Windows
	https://verificationacademy.com/forums/uvm/problem-generating-uvmdpi.dll-uvm1.2-questasim-10.2c-64-bit-windows

	dave_59 という人が vlogコマンドでUVMをコンパイルするMakefileをアップロードしている。vlogでのコンパイルの仕方の参考になる。
	