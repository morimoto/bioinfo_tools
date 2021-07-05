#! /bin/sh
# SPDX-License-Identifier: GPL-2.0
#===============================
#
# mo_uniq_faa
#
#	xxx.faa からユニークなものをピックアップする
#
#	--- sample.faa ----
#	MGA_3|YTPLAS18_00030    K02470
#	MGA_4|YTPLAS18_00040    K02469
#	MGA_5|YTPLAS18_00050
#	MGA_6|YTPLAS18_00060    K02469
#	MGA_7|YTPLAS18_00070    K03664
#	MGA_8|YTPLAS18_00080
#	MGA_9|YTPLAS18_00090
#	MGA_10|YTPLAS18_00100   K02470
#	-------------------
#
#		> mo_uniq_faa sample.faa
#		MGA_7|YTPLAS18_00070    K03664
#
# 2021/07/05 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================

#
# 第１パラメータが xxx.faa ファイル
#
FILE=$1
if [ ! -f ${FILE} ]; then
	echo "no such file"
	exit 1
fi

#
# ユニークな行をピックアップする
#
# awk		: 2 行目をピックアップ
# sort | uniq	: 並び替えてユニークな行だけをピックアップ
#
sort -k 2,2 ${FILE} | uniq -u -f 1 | sort -V
