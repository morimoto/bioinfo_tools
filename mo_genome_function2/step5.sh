#! /bin/bash
#===============================
#
# step5
#
# 2026/02/04 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname | xargs dirname`
. ${TOP}/mo_genome_function2/lib
. ${TOP}/lib_kegg

trap 'kill 0' INT

#====================================
# Output to HTML

step "5"
#====================================
span=0

#--------------------
phase "output HEADER"
#--------------------
table_s				${HTML}

__ver=`kegg_version ${KEGG_FILE}`
tr_s				${HTML}
td "KEGG_db_version:${__ver}"	${HTML}

if [ x"${INPUT_G}" != x ]; then
	td "G: GhostKOALA"	${HTML}
	span=`expr ${span} + 1`
fi
if [ x"${INPUT_E}" != x ]; then
	td "E: eggNOG-mapper"	${HTML}
	span=`expr ${span} + 1`
fi
tr_e				${HTML}

#--------------------
phase "output Title"
#--------------------
tr_s		${HTML}
td "K num"	${HTML}	"rowspan=\"${span}\""
td "Name A"	${HTML}	"rowspan=\"${span}\""
td "Name B"	${HTML}	"rowspan=\"${span}\""
td "Name C"	${HTML}	"rowspan=\"${span}\""
td "Symbol"	${HTML}	"rowspan=\"${span}\""
td "Name"	${HTML}	"rowspan=\"${span}\""
td "EC"		${HTML}	"rowspan=\"${span}\""
for gl in `cat ${GENOME_LIST}`
do
	td "${gl}" ${HTML}	"colspan=\"${span}\""
done
td "SUM"	${HTML}	"colspan=\"${span}\""

tr_e		${HTML}

if [ x${span} = x2 ]; then
	tr_s	${HTML}
	# for GENOME_LIST
	for gl in `cat ${GENOME_LIST}`
	do
		td "G"	${HTML}
		td "E"	${HTML}
	done
	# for SUM
	td "G"	${HTML}
	td "E"	${HTML}
	tr_e	${HTML}
fi

#--------------------
phase "parse each Knum"
#--------------------
# 並列処理
lists=`ls ${KEGG_KNUM_LISTS}*`
for list in ${lists}
do
	echo " - Handle "`realpath --relative-to=. ${list}`
	${TOP}/mo_genome_function2/html_knum ${list} &
done
echo "Wait parallel operation"
wait

#--------------------
phase "draw knum list"
#--------------------
knum_all=`cat ${KEGG_KNUM_LIST_ALL}`
for knum in ${knum_all}
do
	for num in `(cd ${KEGG_KNUM_DIR}/${knum}; ls)`
	do
		cat ${KEGG_KNUM_DIR}/${knum}/${num}/tr >> ${HTML}
	done
done

#--------------------
phase "End"
#--------------------
table_e		${HTML}
