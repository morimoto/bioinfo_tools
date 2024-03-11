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

LINE1=
if [ x"$1" = x"-1" ]; then
	LINE1=1
	shift
fi

TMP=/tmp/mo_genome_function

rm -f ${TMP}*

if [ ! -f $1 ]; then
	echo "no such file"
	exit 1
fi

# remove DOS return
IFILE=${TMP}-file
cat $1 | sed -e "s/\r$//g" > ${IFILE}

OFILE=`basename $1 | cut -d "." -f 1`"_genome_function.tsv"
EFILE=`basename $1 | cut -d "." -f 1`"_genome_function.xls"

get_kegg
get_genomes ${IFILE}

VER=`tail -n 1 ${KEGG_FILE} | cut -d ":" -f 2`

echo    "<table border=\"1\">" > ${EFILE}
echo    "<tr><td>KEGG_db_version:${VER}</td></tr>" >> ${EFILE}
echo -n "<tr><td>Name A</td><td>Name B</td><td>Name C</td><td>Symbol</td><td>Name</td><td>EC</td><td>K num</td>" >> ${EFILE}

echo    "KEGG_db_version:${VER}"				>  ${OFILE}
echo -n "Name A	Name B	Name C	Symbol	Name	EC	K num"	>> ${OFILE}
for gl in ${GENOME_LIST}
do
	echo -n "	${gl}" >> ${OFILE}
	echo -n "<td>${gl}</td>" >> ${EFILE}
	grep ${gl} ${IFILE}	> ${TMP}-${gl}
done

echo -n "	Sum	Core" >> ${OFILE}
echo -n "<td>Sum</td><td>Core</td>" >> ${EFILE}

for gl in ${GENOME_LIST}
do
	echo -n "	${gl} Singleton" >> ${OFILE}
	echo -n "<td>${gl} Singleton</td>" >> ${EFILE}
done
echo >> ${OFILE}
echo "</tr>" >> ${EFILE}

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

		N=`echo "${nlist}" | sed -e "s|	|</td><td>|g"`
		E=
		for ec in ${EC}
		do
			E="${E}<a href=\"https://www.genome.jp/entry/${ec}\">${ec}</a><br>"
		done

		echo -n "<tr><td>${N}</td><td>${E}</td><td><a href=\"https://www.genome.jp/dbget-bin/www_bget?ko:${knum}\">${knum}</a></td>"	>> ${EFILE}

		SUM=0
		for gl in ${GENOME_LIST}
		do
			grep -w ${knum} ${TMP}-${gl} > /dev/null
			if [ $? = 0 ]; then
				echo -n "	+"	>> ${OFILE}
				echo -n "<td>+</td>"	>> ${EFILE}
				SUM=`expr ${SUM} + 1`
			else
				echo -n "	-"	>> ${OFILE}
				echo -n "<td>-</td>"	>> ${EFILE}
			fi
		done

		# SUM
		echo -n "	${SUM}" >> ${OFILE}
		echo -n "<td>${SUM}</td>" >> ${EFILE}

		# Core
		O=
		if [ ${GENOME_NUM} = ${SUM} ]; then
			O="1"
		fi
		echo -n "	${O}" >> ${OFILE}
		echo -n "<td>${O}</td>" >> ${EFILE}

		# Single
		for gl in ${GENOME_LIST}
		do
			O=
			if [ ${SUM} = 1 ]; then
				grep -w ${knum} ${TMP}-${gl} > /dev/null
				[ $? = 0 ] && O="1"
			fi
			echo -n "	${O}" >> ${OFILE}
			echo -n "<td>${O}</td>" >> ${EFILE}
		done

		echo >> ${OFILE}
		echo "</tr>" >> ${EFILE}

		[ x${LINE1} = x1 ] && break
	done
done
echo "</table>" >> ${EFILE}
echo

rm -fr ${TMP}*
