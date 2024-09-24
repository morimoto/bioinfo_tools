#! /bin/bash
#===============================
#
# mo_uniq_split_database2
#
#　巨大なデータベースをデータの頭文字で分割する
#　その手順の２番目
#　分割リストを元に分割する　１番目の mo_uniq_split_database1 を
#　実行してある事
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
#	> mo_uniq_split_database2.sh  my_sorted_database_file  mo_uniq_split_database1_list
#
#	mo_uniq_split_database1_list は mo_uniq_split_database1 の実行結果で
#	作られたもの
#
#	頭文字分のファイルに分割する
#	上記の場合、database_03 に分類される
#
#
#	並列化する場合は、mo_uniq_split_database1_list を split で分割し、
#	parallel で並列化する
#
#	> split mo_uniq_split_database1_list
#	ls
#	split_mo_uniq_split_database1_list_xx
#
#	> parallel --jobs 12 mo_uniq_split_database2.sh  my_sorted_database_file  ::: mo_uniq_split_database1_list_*
#
# NUMHEAD:	頭文字の何文字分で分割するか
#		mo_add_taxid と合わせる事
#
# 2024/08/09 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
NUMHEAD=2
DATABASE=$1
LIST=$2

# ファイルが無い場合は終了
[ ! -f ${DATABASE} ] && echo "no ${DATABASE}" && exit
[ ! -f ${LIST}     ] && echo "no ${LIST}" && exit

cat ${LIST} | while read list; do
	SUFIX=`echo ${list,,} | cut -c -${NUMHEAD}` # 小文字にして
	echo database_${SUFIX}
	grep -i "^${list}" ${DATABASE} >> database_${SUFIX}
done
