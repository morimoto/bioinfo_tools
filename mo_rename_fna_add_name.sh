#! /bin/bash
#===============================
#
# mo_rename_fna_add_name.sh
#
#	指定された data_summary.tsv を元に
#	例えば以下のようにファイル名を変更する
#
#		前 : GCA_013407385.1_ASM1340738v1_genomic.fna
#		後 : Nitrosarchaeum_sp.-AC2-GCA_013407385.1-ASM1340738v1.fna
#
#	稀に「Nitrosarchaeum sp.」となっているはずの箇所が「Nitrosarchaeum_sp. AC2」
#	と言うものがある。　この「AC2」は「strain: AC2」として再登場している
#	この場合の「AC2」は自動で削除される
#
#	指定できる ${dir} の位置関係
#	> ls ${dir}
#	GCA_xxx    GCA_xxx   GCA_xxx
#
#	> mo_rename_fna_add_name.sh  ${サマリファイル} ${dir} ${out}
#
# 2024/09/12 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
SUMMARY=$1
DIR=$2
OUT=$3

[ x${SUMMARY} = x ] && echo "No SUMMARY file" && exit
[ x${DIR}     = x ] && echo "No DIR"          && exit
[ x${OUT}     = x ] && echo "No OUT"          && exit

[ ! -f ${SUMMARY} ] && echo "No such file (${SUMMARY})" && exit
[ ! -d ${DIR}     ] && echo "No such out dir (${DIR})" && exit
[ ! -d ${OUT}     ] && echo "No such out dir (${OUT})" && exit

for dir in `ls ${DIR}`
do
	[ ! -d ${DIR}/${dir} ] && continue

	for file in `ls ${DIR}/${dir}`
	do
		[ ! -f ${DIR}/${dir}/${file} ] && continue

		# GCA_017113085.1_ASM1711308v1_genomic.fna -> fna
		ext=${file##*.}

		# ${file} : GCA_017113085.1_ASM1711308v1_genomic.fna
		# ${dir}  : GCA_017113085.1
		# ${asm}  : _ASM1711308v1_genomic.fna
		asm=${file##*${dir}}
		[ "${dir}${asm}" != ${file} ] && continue

		# ${asm}  : ASM1711308v1_genomic.fna
		asm=${asm:1}
		# ${asm}  : ASM1711308v1
		asm=${asm:0:-12}

		line=`grep ${dir} ${SUMMARY} | grep ${asm}`

		nameA=`echo "${line}" | cut -d '	' -f 1` # Nitrosarchaeum koreense
		nameB=`echo "${line}" | cut -d '	' -f 3` # isolate: AH-315-P14

		# "isolate: AH-315-P14" -> " AH-315-P14"
		nameB=`echo ${nameB} | cut -d ":" -f 2`

		# " AH-315-P14" -> "AH-315-P14"
		nameB=${nameB## }

		# nameA : Nitrosarchaeum sp. AC2
		# nameB : AC2
		#
		# nameA : "Nitrosarchaeum sp. AC2" -> "Nitrosarchaeum sp. "
		nameA=${nameA%${nameB}}
		# nameA : "Nitrosarchaeum sp. " -> "Nitrosarchaeum sp."
		nameA=${nameA%% }

		# "xxxx yyyy" -> "xxxx_yyyy"
		nameA=${nameA// /_}
		nameB=${nameB// /_}

		# "xxxx-yyyy" -> "xxxx_yyyy"
		nameA=${nameA//-/_}
		nameB=${nameB//-/_}

		echo "${file} -> ${nameA}-${nameB}-${dir}-${asm}.${ext}"
		cp ${DIR}/${dir}/${file} ${OUT}/${nameA}-${nameB}-${dir}-${asm}.${ext}
	done
done
