#! /bin/bash
#===============================
#
# step4
#
# 2026/01/30 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname | xargs dirname`
. ${TOP}/mo_genome_function2/lib
. ${TOP}/lib_kegg

trap 'kill 0' INT

#====================================
# Prepare each files

step "4"
#====================================
mkdir -p ${KEGG_DIR}
mkdir -p ${KEGG_KNUM_DIR}
mkdir -p ${KEGG_KNUM_LIST_DIR}

#--------------------
phase "prepare kegg files"
#--------------------
kegg_file_download
cp ${__KEGG_FILE} ${KEGG_FILE}

#--------------------
phase "create genome list"
#--------------------
: > ${GENOME_LIST}_g
[ x"${INPUT_G}" != x ] && (cd ${TMP_G}; ls > ${GENOME_LIST}_g)

: > ${GENOME_LIST}_e
[ x"${INPUT_E}" != x ] && (cd ${TMP_E}; ls > ${GENOME_LIST}_e)

cat ${GENOME_LIST}_g ${GENOME_LIST}_e | sort | uniq > ${GENOME_LIST}
rm ${GENOME_LIST}_*

#--------------------
phase "create knum list"
#--------------------
: > ${KEGG_KNUM_LIST_ALL}_g
[ x"${INPUT_G}" != x ] && cat ${TMP_G}/* | sort | uniq > ${KEGG_KNUM_LIST_ALL}_g

: > ${KEGG_KNUM_LIST_ALL}_e
[ x"${INPUT_E}" != x ] && cat ${TMP_E}/* | sort | uniq > ${KEGG_KNUM_LIST_ALL}_e

cat ${KEGG_KNUM_LIST_ALL}_g ${KEGG_KNUM_LIST_ALL}_e | sort | uniq > ${KEGG_KNUM_LIST_ALL}
rm ${KEGG_KNUM_LIST_ALL}_*

#--------------------
phase "create knum names"
#--------------------
line_num=`cat ${KEGG_KNUM_LIST_ALL} | wc -l`
# 分割数
num=`expr ${line_num} / ${CPU_NUM}`
[ x${num} = x0 ] && num=1

split -l ${num} -d ${KEGG_KNUM_LIST_ALL} ${KEGG_KNUM_LISTS}

# 並列処理
lists=`ls ${KEGG_KNUM_LISTS}*`
for list in ${lists}
do
	echo " - Handle "`realpath --relative-to=. ${list}`
	${TOP}/mo_genome_function2/get_knum_name ${list} ${KEGG_FILE} ${KEGG_KNUM_DIR} ${SINGLE_KNAME} &
done
echo "Wait parallel operation"
wait

rm -fr ${knum_dir}
