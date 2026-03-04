#! /bin/bash
#===============================
#
# step1
#
# 2026/01/30 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname | xargs dirname`
. ${TOP}/mo_genome_function2/lib

#====================================
# Setup Configs

step "1"
#====================================

#--------------------
phase "create working dir"
#--------------------
[ -e ${TMP} ] && error "${TMP} exist"
rm -fr ${TMP}
mkdir  ${TMP}

#--------------------
phase "parse parameter"
#--------------------
CPU_NUM=8		# number of CPU
INPUT_G=		# input of GhostKOALA
INPUT_E=		# input of eggNOG-mapper
INPUT_GENOME_LIST=	# Genomo file list
SINGLE_KNAME=		# Knum name on HTML

while getopts "1g:e:n:l:" opt; do
	case "$opt" in
		1)
			# HTML output
			SINGLE_KNAME=1
			;;
		g)
			# GhostKOALA
			[ ! -f ${OPTARG} ] && error "file not exist (${OPTARG})"
			INPUT_G=`realpath ${OPTARG}`
			;;
		e)
			# eggNOG-mapper
			[ ! -f ${OPTARG} ] && error "file not exist (${OPTARG})"
			INPUT_E=`realpath ${OPTARG}`
			;;
		n)
			[[ ! ${OPTARG} =~ [0-9]+ ]] && error "not numer (${OPTARG})"
			CPU_NUM=${OPTARG}
			;;
		l)
			[ ! -f ${OPTARG} ] && error "file not exist (${OPTARG})"
			INPUT_GENOME_LIST=`realpath ${OPTARG}`
			;;
		*)
			error "param error"
			exit
	esac
done
shift $((OPTIND - 1))

#--------------------
phase "param check"
#--------------------
if [[ x"${INPUT_G}" == x &&
      x"${INPUT_E}" == x ]]; then
	error "No GhostKOALA / eggNOG-mapper file"
fi

if [[ x"${INPUT_GENOME_LIST}" == x ]]; then
	error "No Genome List"
fi

#--------------------
phase "file format check"
#--------------------
grep -v ".faa$" ${INPUT_GENOME_LIST} > /dev/null
[ $? = 0 ] && error "strange input genome_list"

if [ x"${INPUT_G}" != x ]; then
	#--------------------
	phase " * GhostKOALA / prodigal"
	#--------------------
	cat ${INPUT_G} | egrep -v ".*_.*\.[0-9]+_[0-9]+( K.*$)?" > /dev/null
	[ $? = 0 ] && error "non prodigal format on GhostKOALA"
fi

if [ x"${INPUT_E}" != x ]; then
	#--------------------
	phase " * eggNOG-mapper / prodigal"
	#--------------------
	head -n 20 ${INPUT_E} | grep -v "^#" | egrep -v ".*_.*\.[0-9]+_[0-9]" > /dev/null
	[ $? = 0 ] && error "non prodigal format on eggNOG-mapper"
fi

#--------------------
phase "prepare separate faa list"
#--------------------
# 行数
line_num=`cat ${INPUT_GENOME_LIST} | wc -l`
# 分割数
num=`expr ${line_num} / ${CPU_NUM}`
[ x${num} = x0 ] && num=1

# ${INPUT_GENOME_LIST} を ${CPU_NUM} に分割
mkdir -p ${FAA_DIR}
grep ".faa$" ${INPUT_GENOME_LIST} | sed -e "s/.faa$//g" > ${FAA_DIR}/all_list
split -l ${num} -d ${FAA_DIR}/all_list ${FAA_DIR}/list_

#--------------------
phase "save config"
#--------------------
echo "CPU_NUM=${CPU_NUM}"			>  ${CONFIG}
echo "SINGLE_KNAME=${SINGLE_KNAME}"		>> ${CONFIG}
echo "INPUT_G=${INPUT_G}"			>> ${CONFIG}
echo "INPUT_E=${INPUT_E}"			>> ${CONFIG}
echo "INPUT_GENOME_LIST=${INPUT_GENOME_LIST}"	>> ${CONFIG}
echo "OUTPUT=mo_genome_function2_output.html"	>> ${CONFIG}
