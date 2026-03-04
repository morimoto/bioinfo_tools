#! /bin/bash
#===============================
#
# step3
#
# 2026/02/02 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname | xargs dirname`
. ${TOP}/mo_genome_function2/lib

#====================================
# Parse eggNOG-mapper

step "3"
#====================================

[ x"${INPUT_E}" = x ] && exit

#--------------------
phase "parse eggNOG-mapper"
#--------------------
mkdir -p ${TMP_E}

# 並列処理
lists=`ls ${FAA_DIR}/list_*`
for list in ${lists}
do
	echo " - Handle "`realpath --relative-to=. ${list}`
	${TOP}/mo_genome_function2/get_knum_list_e ${INPUT_E} ${list} ${TMP_E} &
done
echo "Wait parallel operation"
wait
