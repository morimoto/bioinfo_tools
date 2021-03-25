#! /bin/sh
# SPDX-License-Identifier: GPL-2.0
#===============================
#
# mo_dfast_to_cdspickup
#
# 使い方例)
#	"AmoA" と言う説明文を含む CDS を今いるフォルダの
#	RARx-METABAT__x から見つけ出す
#
#	> ls
#	RAR1-METABAT__1  RAR2-METABAT__2  RAR3-METABAT__3 ...
#
#	> mo_dfast_to_cdspickup.sh AmoA RAR*
#
# 2021/03/22 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================

#
# 第１パラメータがキーワード
# 以降は対象フォルダ
#
KEYWORD=$1
shift
DIR=$*

#
# 各種ファイル
#
TMP=mo_tmp
OUT=mo_cdspickup_${KEYWORD}.xls

#
# MAC の sed (BSD sed) では改行の扱いが面倒くさいので
# GNU sed を使う (あれば)
#
SED=sed
if [ `uname` = "Darwin" ]; then
	which gsed 2>&1 1>/dev/null
	if [ $? = 1 ]; then
		echo "you need to have gnu-sed on Mac, install it"
		echo "	brew install gnu-sed"
		exit
	fi
	SED=gsed
fi

#
# 一時ファイルを初期化
#
: > ${TMP}

#
# 各フォルダを対象
#
for dir in ${DIR}
do
	#
	# - genome.gbk は特殊なフォーマットなので、改行を削除
	# - CDS の部分で改行し直し
	#	CDS    xxxxx ABC    xxx locus_tag=name /note=xxx /note=yyy
	#	CDS    xxxxx BCA xxx locus_tag=name /note=xxx /note=yyy
	#	CDS    xxxxx ABC  xxx locus_tag=name /note=xxx /note=yyy
	#	....
	# - キーワード (= ABC) を含む行をピックアップ
	#	CDS    xxxxx ABC    xxx locus_tag=name /note=xxx /note=yyy
	#	CDS    xxxxx ABC  xxx locus_tag=name /note=xxx /note=yyy
	# - 元の genome.gbk は空白文字が多いため、複数の空白文字を１つの空白文字に変換
	#	CDS xxxxx ABC xxx locus_tag=name /note=xxx /note=yyy
	#	CDS xxxxx ABC xxx locus_tag=name /note=xxx /note=yyy
	# - 上記を一時ファイルに書き出し
	#
	perl -pe 's/\n/ /' ${dir}/genome.gbk | ${SED} "s/CDS /\nCDS /g" | grep -w ${KEYWORD} | sed "s/  */ /g" >> ${TMP}
done

#
# - CDS - locus_tag までを削除
#	name /note=xxx /note=yyy
#	name /note=xxx /note=yyy
# - /note をタブに変換
#	name	xxx	yyy
#	name	xxx	yyy
#
sed "s|^CDS.*/locus_tag=||g" ${TMP} | sed "s|/note=|\t|g" > ${OUT}

# 一時ファイルはいらないので削除
rm ${TMP}
