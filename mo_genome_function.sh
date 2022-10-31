#! /bin/bash
#===============================
#
# mo_genome_function
#
#	指定されたファイルを元に K ナンバーのカテゴリや名前、
#	EC 経路を表記し、各ゲノムがその K ナンバーを持っているかどうかの一覧を作る
#
#	${FILE}_genome_function.tsv と言うファイルに出力する
#	表計算ソフトで開ける
#
#	> mo_genome_function.sh ./user_ko.txt
#	user_ko_genome_function.tsv
#
#	[FIXME]
#
#	KEGG の Web ページは EC 番号をふって無い K ナンバーも
#	EC として認識するけど、KEGG ファイル自体はふって無い
#	このスクリプトはそれを考慮できない
#	時間が経てば解決する問題かも？
#
# 2022/10/31 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f ./mo_analysis.sh | xargs dirname`
. ${TOP}/lib

TMP=/tmp/mo_genome_function

rm -f ${TMP}*

IFILE=$1
if [ ! -f ${IFILE} ]; then
	echo "no such file"
	exit 1
fi

OFILE=`basename ${IFILE} | cut -d "." -f 1`"_genome_function.tsv"

get_genomes ${IFILE}

VER=`tail -n 1 ${KEGG_FILE} | cut -d ":" -f 2`

echo    "KEGG_db_version:${VER}"				>  ${OFILE}
echo -n "Name A	Name B	Name C	Symbol	Name	EC	K num"	>> ${OFILE}
for gl in ${GENOME_LIST}
do
	echo -n "	${gl}" >> ${OFILE}
	grep ${gl} ${IFILE}	> ${TMP}-${gl}
done

echo -n "	Sum	Core" >> ${OFILE}

for gl in ${GENOME_LIST}
do
	echo -n "	${gl} Singleton" >> ${OFILE}
done
echo >> ${OFILE}

d=0
div=`expr ${KNUM_UNIQ_NUM} / 60 + 1`
for knum in ${KNUM_UNIQ_LIST}
do
	d=`expr \( ${d} + 1 \) \% ${div}`
	[ ${d} = 1 ] && echo -n "."

	NLIST=`${TOP}/mo_kno_name.sh ${knum}`
	OLDIFS=${IFS}
	IFS=$'\n'
	for nlist in ${NLIST}
	do
		IFS=${OLDIFS}

		EC=""
		echo "${nlist}" | grep "\[EC:.*\]$" > /dev/null
		[ $? = 0 ] && EC=`echo -n "${nlist}" | sed -r "s/.*\[EC:(.*)]/\1/g"`
		echo -n "${nlist}	${EC}	${knum}"	>> ${OFILE}

		SUM=0
		for gl in ${GENOME_LIST}
		do
			grep -w ${knum} ${TMP}-${gl} > /dev/null
			if [ $? = 0 ]; then
				echo -n "	+"	>> ${OFILE}
				SUM=`expr ${SUM} + 1`
			else
				echo -n "	-"	>> ${OFILE}
			fi
		done

		# SUM
		echo -n "	${SUM}" >> ${OFILE}

		# Core
		O=
		if [ ${GENOME_NUM} = ${SUM} ]; then
			O="1"
		fi
		echo -n "	${O}" >> ${OFILE}

		# Single
		for gl in ${GENOME_LIST}
		do
			O=
			if [ ${SUM} = 1 ]; then
				grep -w ${knum} ${TMP}-${gl} > /dev/null
				[ $? = 0 ] && O="1"
			fi
			echo -n "	${O}" >> ${OFILE}
		done

		echo >> ${OFILE}
	done
done
echo

rm -fr ${TMP}*
