#! /bin/bash
#===============================
#
# step2
#
# 2026/02/02 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname | xargs dirname`
. ${TOP}/mo_genome_function2/lib

trap 'kill 0' INT

#====================================
# Parse GhostKOALA

step "2"
#====================================
[ x"${INPUT_G}" = x ] && exit

#--------------------
phase "Parse GhostKOALA"
#--------------------
mkdir -p ${TMP_G}

# 並列処理
lists=`ls ${FAA_DIR}/list_*`
for list in ${lists}
do
	echo " - Handle "`realpath --relative-to=. ${list}`
	${TOP}/mo_genome_function2/get_knum_list_g ${INPUT_G} ${list} ${TMP_G} &
done
echo "Wait parallel operation"
wait
