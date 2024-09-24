#! /bin/bash
#===============================
#
# mo_uniq_split_database1
#
#　巨大なデータベースをデータの頭文字で分割する
#　その手順の１番目
#　頭文字で分割するためのリストを作成する
#
#　使い方
#
#	以下のような sort / uniq 済みのデータベースを想定
#
#	--- my_sorted_database_file ---
#	0308206A	8058
#	0308206B	8058
#	0308221A	9606
#	0308221B	9606
#	...
#
#	> mo_uniq_split_database1.sh  my_sorted_database_file
#
#	実行後, mo_uniq_split_database1_list ができる
#
# NUMHEAD:	頭文字の何文字分で分割するか
#		mo_add_taxid と合わせる事
#
# 2024/08/09 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
NUMHEAD=2
DATABASE=$1
OUT=mo_uniq_split_database1_list

# 既に ${OUT} がある場合は終了
[ -f ${OUT} ] && echo "Already have ${OUT}" && exit

cat ${DATABASE} | cut -c-${NUMHEAD} | sort | uniq > ${OUT}
