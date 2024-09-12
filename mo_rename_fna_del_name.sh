#! /bin/bash
#===============================
#
# mo_rename_fna_del_name
#
#	mo_rename_fna_add_name でつけた名前から指定した部分でリネームする
#	上では以下のような命名になっている
#
#		1        2        3      4
#		${nameA}-${nameB}-${dir}-${asm}.${ext}
#
#	残す場所を指定する。　例えば ${nameA}, ${dir} を残す場合、
#
#		> mo_rename_fna_del_name ${IN} ${OUT} 1 3
#
# 2024/09/12 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
IN=$1
OUT=$2
shift 2
PARAM=$@

TMP=/tmp/mo_rename_fna_del_name.$$

[ x${IN}  = x ] && echo "No IN"  && exit
[ x${OUT} = x ] && echo "No OUT" && exit

[ ! -d ${IN}  ] && echo "No such out dir (${IN})" && exit
[ ! -d ${OUT} ] && echo "No such out dir (${OUT})" && exit

# 残す場所は 1 〜 4
for param in ${PARAM}
do
	if [ ${param} != 1 -a \
	     ${param} != 2 -a \
	     ${param} != 3 -a \
	     ${param} != 4 ]; then
		echo "del param error (${param})"
		exit
	fi
done


: > ${TMP}
for param in ${PARAM}
do
	echo ${param} >> ${TMP}
done

LIST=`sort -n ${TMP} | uniq`
rm ${TMP}

# 何回消したか
for org in `ls ${IN}`
do
	# ${nameA}-${nameB}-${dir}-${asm}.${ext} -> ${ext}
	ext=${org##*.}
	# ${nameA}-${nameB}-${dir}-${asm}.${ext} -> ${nameA}-${nameB}-${dir}-${asm}
	org=${org%.${ext}}

	file=""
	for l in ${LIST}
	do
		file=${file}-`echo ${org} | cut -d "-" -f ${l}`
	done

	# -${xxx} -> ${xxx}
	file=${file#*-}

	[ -f ${OUT}/${file}.${ext} ] && echo "** overwride **"
	echo "${org}.${ext} -> ${file}.${ext}"
	cp ${IN}/${org}.${ext} ${OUT}/${file}.${ext}
done
