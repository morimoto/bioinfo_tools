#! /bin/bash
#===============================
#
# mo_add_prefix_to_file
#
#	mo_add_prefix_to_file PREFIX ./*.faa
#
# 2023/01/13 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
PREFIX=$1
shift
LIST=$@

array=(`echo $LIST`) # 配列に格納
digit=${#array[@]}   # 配列の要素数
FMT="%0${#digit}d"

NUM=1
for list in ${LIST}
do
	list=`basename ${list}`
	N=`printf ${FMT} ${NUM}`
	echo "${list} -> ${PREFIX}_${N}-${list}"
	mv ${list} ${PREFIX}_${N}-${list}
	NUM=`expr ${NUM} + 1`
done
