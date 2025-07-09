#! /bin/bash
#===============================
#
# mo_prodigal.sh
#
#	> mo_prodigal.sh  ./bin.1.orig.fa
#
#	結果は PRODIGAL_OUT に出力される
#
#		PRODIGAL_OUT/bin.1.orig/bin.1.orig.fa
#		PRODIGAL_OUT/bin.1.orig/bin.1.orig.gff
#		PRODIGAL_OUT/bin.1.orig/bin.1.orig.faa
#		PRODIGAL_OUT/bin.1.orig/bin.1.orig_fnn.fa
#
#	prodigal に与えたいオプションはコマンドの最後に追加できる
#	例えば「prodigal ... -p meta」と言う実行をしたい場合
#
#		> mo_prodigal ./bin/1.orig.fa -p meta
#
# 並列化したい場合
#
#	ex) オプション無し
#	> parallel mo_prodigal.sh {} ::: ./*.fa
#
#	ex) オプションあり
#	> parallel mo_prodigal.sh {} -p meta ::: ./*.fa
#
# 2025/07/10 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================

OUT=PRODIGAL_OUT

__FILE=$1
shift
_FILE=`basename ${__FILE}`
FILE=`basename ${_FILE} .fa`

if [ ${FILE}.fa != ${_FILE} ]; then
	echo "xxx.fa only"
	exit
fi

cd `dirname ${__FILE}`

mkdir -p ${OUT}/${FILE}

cat ${FILE}.fa | sed -e "s/^>/>${FILE}_/g" > ${OUT}/${FILE}/${FILE}.fa

cd ${OUT}/${FILE}

prodigal -i ${FILE}.fa -f gff -o ${FILE}.gff -a ${FILE}.faa -d ${FILE}_fnn.fa $@
