#! /bin/bash
#===============================
#
# mo_add_taxid
#
# mo_{sort_}uniq_split_database 等で作った database_xx を使う
#
#　使い方
#	> mo_add_taxid  my_datalist
#
#　parallel を使う場合
#	split_my_datalist_xx が複数あると想定
#
#		> parallel mo_add_taxid ::: split_my_datalist_*
#
#	コアの数を指定する場合 （例) 12 コア限定
#
#		> parallel --jobs 12 mo_add_taxid ::: split_my_datalist_*
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
# NUMHEAD:	頭文字の何文字分で分割するか　以下のファイルと合わせる事
#		mo_sort_uniq_split_database
#		mo_uniq_split_database
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
		grep -F -m 1 ${line} database_${SUFIX} >> taxid_${FILE}
	else
		echo "$line" >> taxid_${FILE}
	fi
done
