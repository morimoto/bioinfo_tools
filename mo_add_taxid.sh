#! /bin/bash
#===============================
#
# mo_add_taxid
#
# mo_sort_uniq_split_database と作った database_xx を使う
#
#　使い方
#	> mo_add_taxid  my_datalist
#
#　parallel を使う
#	split_my_datalist_xx が複数あると想定
#
#	> parallel mo_add_taxid ::: split_my_datalist_*
#
#　以下のようなデータを想定
#
#	--- my_datalist ---
#	NLH79192.1
#	HQM32133.1
#	NLW84983.1
#	NLW84982.1
#	...
#
#　上記の場合、「NLW84982.1」 の頭文字「NL」から database_nl を探し、
#　そこからデータを付与し、taxid_my_datalist に書き込む
#
# NUMHEAD:	頭文字の何文字分で分割するか
#		mo_sort_uniq_split_database と合わせる事
#
# 2024/08/09 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
NUMHEAD=2
FILE=$1

# 既に taxid_xx がある場合は終了
ls ./taxid_${FILE} > /dev/null 2>&1
[ $? == 0 ] && echo "Already have taxid_${FILE}" && exit

cat ${FILE} | while read line; do
	SUFIX=`echo ${line,,} | cut -c -${NUMHEAD}` # 小文字にして
	if [ -f database_${SUFIX} ]; then
		grep -m 1 ${line} database_${SUFIX} >> taxid_${FILE}
	else
		echo "$line" >> taxid_${FILE}
	fi
done
