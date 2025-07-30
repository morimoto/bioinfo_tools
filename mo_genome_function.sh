#! /bin/bash
#===============================
#
# mo_genome_function
#
#	指定されたファイルを元に K ナンバーのカテゴリや名前、
#	EC 経路を表記し、各ゲノムがその K ナンバーを持っているかどうかの一覧を作る
#
#	${FILE}_genome_function.html と言うファイルに出力する
#	表計算ソフトで開ける
#
#	> mo_genome_function.sh ./user_ko.txt
#	user_ko_genome_function.html
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
function td() {
	TXT=$1
	OPT=$2

	echo -n "<td ${OPT}>${TXT}</td>"
}

TOP=`readlink -f "$0" | xargs dirname`
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

GFILE=${TMP}-file-g	# for GhostKOALA
EFILE=${TMP}-file-e	# for eggNOG-mapper
XFILE=${TMP}-file-x	# for both "GhostKOALA" and "eggNOG-mapper"

# remove DOS return
cat $1 | sed -e "s/\r$//g" > ${GFILE}
cat ${GFILE} > ${XFILE}

OUT=`basename $1 | cut -d "." -f 1`"_genome_function.html"

shift

SPAN=1	# GhostKOALA
if [ x$1 = x-e -a -f $2 ]; then
	SPAN=2	# GhostKOALA + eggNOG-mapper
	cat $2 | grep -v "#" | cut -d "	" -f 1,12 | sed -e "s/ko://g" > ${EFILE}

	cat ${EFILE} >> ${XFILE}
fi

get_kegg
get_genomes ${XFILE}

VER=`tail -n 1 ${KEGG_FILE} | cut -d ":" -f 2`

#
# HEAD
#
echo    "<table border=\"1\">" > ${OUT}

echo -n "<tr>"			>> ${OUT}
td "KEGG_db_version:${VER}"	>> ${OUT}
if [ ${SPAN} = 2 ]; then
	td "G: GhostKOALA<br>E: eggNOG-mapper" >> ${OUT}
fi
echo "</tr>"			>> ${OUT}


echo -n "<tr>"				>> ${OUT}
td "Name A"	"rowspan=\"${SPAN}\""	>> ${OUT}
td "Name B"	"rowspan=\"${SPAN}\""	>> ${OUT}
td "Name C"	"rowspan=\"${SPAN}\""	>> ${OUT}
td "Symbol"	"rowspan=\"${SPAN}\""	>> ${OUT}
td "Name"	"rowspan=\"${SPAN}\""	>> ${OUT}
td "EC"		"rowspan=\"${SPAN}\""	>> ${OUT}
td "K num"	"rowspan=\"${SPAN}\""	>> ${OUT}

for gl in ${GENOME_LIST}
do
	td "${gl}"	"colspan=\"${SPAN}\""	>> ${OUT}

			   grep ${gl} ${GFILE} > ${TMP}-${gl}-g
	[ ${SPAN} = 2 ] && grep ${gl} ${EFILE} > ${TMP}-${gl}-e
done

td "Sum"	"colspan=\"${SPAN}\""	>> ${OUT}
td "Core"	"colspan=\"${SPAN}\""	>> ${OUT}

for gl in ${GENOME_LIST}
do
	td "${gl} Singleton"	"colspan=\"${SPAN}\"" >> ${OUT}
done
echo "</tr>" >> ${OUT}

if [ ${SPAN} = 2 ]; then
	echo "<tr>" >> ${OUT}

	# for Sum, Core
	td "G"	>> ${OUT}	# for GhostKOALA
	td "E"	>> ${OUT}	# for eggNOG-mapper
	td "G"	>> ${OUT}
	td "E"	>> ${OUT}

	# for GENOME, GENOME Singleton
	for gl in ${GENOME_LIST}
	do
		td "G"	>> ${OUT}
		td "E"	>> ${OUT}
		td "G"	>> ${OUT}
		td "E"	>> ${OUT}
	done

	echo "</tr>" >> ${OUT}
fi

#
# Each Knum
#
d=0
div=`expr ${KNUM_NUM} / 60 + 1`
for knum in ${KNUM_LIST}
do
	# for progress
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

		N=`echo "${nlist}" | sed -e "s|	|</td><td>|g"`
		E=
		for ec in ${EC}
		do
			E="${E}<a href=\"https://www.genome.jp/entry/${ec}\">${ec}</a><br>"
		done

		echo -n "<tr><td>${N}</td><td>${E}</td><td><a href=\"https://www.genome.jp/dbget-bin/www_bget?ko:${knum}\">${knum}</a></td>"	>> ${OUT}

		SUMg=0	# for GhostKOALA
		SUMe=0	# for eggNOG-mapper
		for gl in ${GENOME_LIST}
		do
			TXTg="-"
			TXTe="-"

			# for GhostKOALA
			grep -w ${knum} ${TMP}-${gl}-g > /dev/null
			if [ $? = 0 ]; then
				TXTg="+"
				SUMg=`expr ${SUMg} + 1`
			fi

			# for eggNOG-mapper
			if [ ${SPAN} = 2 ]; then
				grep -w ${knum} ${TMP}-${gl}-e > /dev/null
				if [ $? = 0 ]; then
					TXTe="+"
					SUMe=`expr ${SUMe} + 1`
				fi
			fi

			[ ${SPAN} != 2 ] && TXTe=${TXTg}

			COLOR=
			[ ${TXTg} != ${TXTe} ] && COLOR="bgcolor=\"yellow\""

					   td "${TXTg}" "${COLOR}" >> ${OUT}
			[ ${SPAN} = 2 ] && td "${TXTe}" "${COLOR}" >> ${OUT}
		done

		# SUM
		[ ${SPAN} != 2 ] && SUMe=${SUMg}

		COLOR=
		[ ${SUMg} != ${SUMe} ] && COLOR="bgcolor=\"yellow\""

				   td "${SUMg}" "${COLOR}" >> ${OUT}
		[ ${SPAN} = 2 ] && td "${SUMe}" "${COLOR}" >> ${OUT}

		# Core (reuse COLOR)
		Og=" "
		Oe=" "
		[ ${GENOME_NUM} = ${SUMg} ] && Og="1"
		[ ${GENOME_NUM} = ${SUMe} ] && Oe="1"

				   td "${Og}" "${COLOR}" >> ${OUT}
		[ ${SPAN} = 2 ] && td "${Oe}" "${COLOR}" >> ${OUT}

		# Single
		for gl in ${GENOME_LIST}
		do
			Og=" "
			Oe=" "
			if [ ${SUMg} = 1 ]; then
				grep -w ${knum} ${TMP}-${gl}-g > /dev/null
				[ $? = 0 ] && Og="1"
			fi

			if [ ${SPAN} = 2 -a ${SUMe} = 1 ]; then
				grep -w ${knum} ${TMP}-${gl}-e > /dev/null
				[ $? = 0 ] && Oe="1"
			fi

			[ ${SPAN} != 2 ] && Oe=${Og}

			COLOR=
			[ x${Og} != x${Oe} ] && COLOR="bgcolor=\"yellow\""

					   td "${Og}" "${COLOR}" >> ${OUT}
			[ ${SPAN} = 2 ] && td "${Oe}" "${COLOR}" >> ${OUT}
		done

		echo "</tr>" >> ${OUT}

		[ x${LINE1} = x1 ] && break
	done
done
echo "</table>" >> ${OUT}
echo

rm -fr ${TMP}*
