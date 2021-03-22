#! /bin/sh
#===============================
#
# mo_cdspickup_to_faa
#
# 使い方例)
#	"AmoA" をピックアップした mo_cdspickup_AmoA.xls を元に
#	今いるフォルダの RARx-METABAT__x から見つけ出す
#
#	> ls
#	RAR1-METABAT__1  RAR2-METABAT__2  RAR3-METABAT__3 ...
#
#	> mo_cdspickup_to_faa.sh mo_cdspickup_AmoA.xls RAR*
#
# 2021/03/22 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================

#
# 第１パラメータが mo_cdspickup_xxx.xls ファイル
# 以降は対象フォルダ
#
CDSPICK=$1
shift
DIR=$*

#
# 各種ファイル
#
OUT=mo_protein.faa

#
# 出力ファイルを初期化
#
: > ${OUT}

#
# 指定フォルダを元に対象となる protein.faa を追加した
# FILES を作成
#
# RAR1-METABAT__1	-> RAR1-METABAT__1/protein.faa
# RAR2-METABAT__2	-> RAR2-METABAT__2/protein.faa
# RAR3-METABAT__3	-> RAR3-METABAT__3/protein.faa
#
FILES=
for dir in ${DIR}
do
	FILES="${FILES} ${dir}/protein.faa"
done

#
# xls は「CSV」か「テキスト（タブ）」のどちらか
#
#	TAB	: "xxxx"	aaaa	bbbb
#	CSV	: xxxx,aaaa,bbbb
#
# - 初めの区切り文字以降をすべて削除
# - "xxx" だった場合、xxx に変換
#
# 結果として元々 locus_tag だったものの一覧だけが残る
#
LIST=`sed "s/[\t ,].*//g" ${CDSPICK} | sed "s/\"//g"`
for list in ${LIST}
do
	# 指定された locus_tag を持つ行（とその次のゲノム情報行）
	# をピックアップ
	grep -h -A 1 ${list} ${FILES} >> ${OUT}
done
