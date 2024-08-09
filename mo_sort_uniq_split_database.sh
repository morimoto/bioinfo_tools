#! /bin/bash
#===============================
#
# mo_sort_uniq_split_database
#
#　使い方
#	> mo_sort_uniq_split_database  my_database_file
#
#　以下のようなデータベースを想定
#
#	--- my_database_file ---
#	0308206A	8058
#	0308206A	8058
#	0308221A	9606
#	0308221A	9606
#	...
#
#　同じ物が並んでいる場合があるので、sort / uniq をかけ
#　頭文字分のファイルに分割する
#　上記の場合、database_03 に分類される
#
# NUMHEAD:	頭文字の何文字分で分割するか
#		mo_add_taxid と合わせる事
#
# 2024/08/09 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
NUMHEAD=2
DATABASE=$1

# 既に database_xx がある場合は終了
ls ./database_* > /dev/null 2>&1
[ $? == 0 ] && echo "Already have database_xx" && exit

sort ${DATABASE} | uniq | while read line; do
	SUFIX=`echo ${line,,} | cut -c -${NUMHEAD}` # 小文字にして
	echo $line >> database_${SUFIX}
done
