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
phase "create working dir"
#--------------------
step2_tmp=${TMP}/step2_work
rm   -fr ${step2_tmp}
mkdir -p ${step2_tmp}

#--------------------
phase "prepare separate faa list"
#--------------------
# 行数
line_num=`cat ${INPUT_GENOME_LIST} | wc -l`
# 分割数
num=`expr ${line_num} / ${CPU_NUM}`
[ x${num} = x0 ] && num=1

# ${INPUT_GENOME_LIST} を ${CPU_NUM} に分割
faa_dir=${step2_tmp}/faa_list
mkdir -p ${faa_dir}
grep ".faa$" ${INPUT_GENOME_LIST} | sed -e "s/.faa$//g" > ${faa_dir}/all_list
split -l ${num} -d ${faa_dir}/all_list ${faa_dir}/list_

#--------------------
phase "Parse KNUM from GhostKOALA"
#--------------------
mkdir -p ${TMP_G}

# 並列処理
lists=`ls ${faa_dir}/list_*`
for list in ${lists}
do
	echo " - Handle "`realpath --relative-to=. ${list}`
	${TOP}/mo_genome_function2/get_knum_list_g ${INPUT_G} ${list} ${TMP_G} &
done
echo "Wait parallel operation"
wait

rm -fr ${step2_tmp}
