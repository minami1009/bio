# about bio
研究で用いているバイオインフォマティクス関連のプログラム  
Bioinformatics programs used in my research.

# description
## AmpliconSeq_corr.py
16SrRNA菌叢解析における菌間相互作用解析     


## openmm.ipynb
OpenMM（分子動力学計算プログラム）の実行（Colaboratoryで書いているが、当然ローカル環境で実行したほうが早い）

また、OpenMM-setupはローカルで行う必要がある（ラボLinuxマシンで実行）

OpenMMをconda-forgeチャンネルからインストール

$ cd OpenMM

$ conda activate openmm

$ conda install -c conda-forge openmm=7.6 python=3.7 -y

$ openmm-setup

ここからOpenMM-setupをGUIで操作する（以下Webサイト参照）

主に参考にしたWebサイト：
https://hira-labo.com/archives/1544
https://magattaca.hatenablog.com/entry/2022/02/12/201641


## rnaseq.command
RNA-seq解析用のmac/linuxコマンド(ballgown以前)


## RF2NA.command
https://github.com/uw-ipd/RoseTTAFold2NA
日本語のコメントとうまく行かなかった箇所の追加
