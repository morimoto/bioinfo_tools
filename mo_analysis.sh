#! /bin/sh
# SPDX-License-Identifier: GPL-2.0
#===============================
#
# mo_analysis.sh
#
#	Core や Singleton 等の情報を出力する
#
#	--- sample.faa ----
#	...
#	MGA_6|YTPLAS18_00060    K02469
#	MGA_7|YTPLAS18_00070    K03664
#	MGA_8|YTPLAS18_00080
#	MGA_9|YTPLAS18_00090
#	...
#	MGA_3815|YTPLAS72_37530
#	MGA_3816|YTPLAS72_37540
#	MGA_3817|YTPLAS72_37550   K07714
#	MGA_3818|YTPLAS72_37560
#	MGA_3819|YTPLAS72_37570
#	...
#	MGA_1|defluvii_00010      K02313
#	MGA_2|defluvii_00020      K02338
#	MGA_3|defluvii_00030      K02470
#	MGA_4|defluvii_00040      K02469
#	...
#	-------------------
#
#		> mo_analysis.sh sample.txt
#
# 2021/10/25 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
FILE=$1
if [ ! -f ${FILE} ]; then
	echo "no such file"
	exit 1
fi

DIR=`basename ${FILE} | cut -d "." -f 1`"_result"
if [ -e ${DIR} ]; then
	echo "You already have ${DIR}"
	exit 1
fi

GLIST=`cat ${FILE} | awk '{print $1}' | cut -d "|" -f 2 | cut -d "_" -f 1 | sort | uniq`
GN=`   cat ${FILE} | awk '{print $1}' | cut -d "|" -f 2 | cut -d "_" -f 1 | sort | uniq | wc -l`
for gl in ${GLIST}
do
	echo "create ${gl}"
	mkdir -p ${DIR}/${gl}

	grep ${gl} ${FILE}							> ${DIR}/${gl}/all_genes.tsv
	grep -w -E "K([0-9]){5}" ${DIR}/${gl}/all_genes.tsv			> ${DIR}/${gl}/all_k_no.tsv
	cat ${DIR}/${gl}/all_k_no.tsv | awk '{print $2}' | sort | uniq -c	> ${DIR}/${gl}/uniq_k.tsv

	gnum=`cat ${DIR}/${gl}/all_genes.tsv | wc -l`
	knum=`cat ${DIR}/${gl}/all_k_no.tsv | wc -l`
	kper=`echo "scale=3; ${knum} * 100 / ${gnum}" | bc`
	kuiq=`cat ${DIR}/${gl}/uniq_k.tsv | wc -l`

	echo "Total  genes       	${gnum}"	>  ${DIR}/${gl}/summary.tsv
	echo "Genes with K No    	${knum}"	>> ${DIR}/${gl}/summary.tsv
	echo "  rate (genes)     	${kper}"	>> ${DIR}/${gl}/summary.tsv
	echo "Uniq K No          	${kuiq}"	>> ${DIR}/${gl}/summary.tsv
done

TMP=/tmp/mo-analysis-$$
cat ${DIR}/*/uniq_k.tsv | awk '{print $2}' | sort | uniq -c | sort -V		> ${TMP}-k_nums

cat ${TMP}-k_nums | grep -w "1"							> ${TMP}-k_single
for gl in ${GLIST}
do
	cat ${DIR}/${gl}/uniq_k.tsv ${TMP}-k_single | awk '{print $2}' | sort | uniq -d	> ${DIR}/${gl}/singleton.tsv

	gnum=`cat ${DIR}/${gl}/all_genes.tsv | wc -l`
	knum=`cat ${DIR}/${gl}/all_k_no.tsv | wc -l`
	sc=`cat ${DIR}/${gl}/singleton.tsv | wc -l`
	rg=`echo "scale=3; ${sc} * 100 / ${gnum}" | bc`
	rk=`echo "scale=3; ${sc} * 100 / ${knum}" | bc`
	echo "Singleton          	${sc}"	>> ${DIR}/${gl}/summary.tsv
	echo "  rate (genes)     	${rg}"	>> ${DIR}/${gl}/summary.tsv
	echo "  rate (K No)      	${rk}"	>> ${DIR}/${gl}/summary.tsv
done

echo "create core"
mkdir -p ${DIR}/core
cat ${TMP}-k_nums | grep -w ${GN} | awk '{print $2}'			> ${TMP}-uniq_core

: > ${TMP}-cores
for core in `cat ${TMP}-uniq_core`
do
	grep ${core} ${FILE} | awk '{print $2}' >> ${TMP}-cores
done
cat ${TMP}-cores  | sort | uniq -c | sort -n				> ${DIR}/core/uniq_core.tsv

CMAX=`cat ${DIR}/core/uniq_core.tsv | wc -l`

echo "Total  core        	${CMAX}"				>  ${DIR}/core/summary.tsv

for k in `cat ${DIR}/core/uniq_core.tsv | awk '{print $2}'`
do
	num=`grep ${k} ${FILE} | awk '{print $1}' | cut -d "|" -f 2 | cut -d "_" -f 1 | sort | uniq -u | wc -l`
	echo ${k} >> ${DIR}/core/scg-${num}
done

: > ${TMP}-scg
for f in `ls -r -v ${DIR}/core/scg-* 2>/dev/null`
do
	num=`echo ${f} | sed -e "s|${DIR}/core/scg-||g"`

	cat ${f} >> ${TMP}-scg

	scg=`cat ${TMP}-scg | wc -l`
	spe=`echo "scale=3; ${scg} * 100 / ${CMAX}" | bc`
	echo "SCG (${num}/${GN})  	${scg}"			>>  ${DIR}/core/summary.tsv
	echo "  rate (${num}/${GN}) 	${spe}"			>>  ${DIR}/core/summary.tsv
done

echo "create Summary"

grep -w -E "K([0-9]){5}" ${FILE} | awk '{print $2}' > ${TMP}-ks
gnum=`cat ${FILE} | wc -l`
knum=`cat ${TMP}-ks | wc -l`
kper=`echo "scale=3; ${knum} * 100 / ${gnum}" | bc`
kuiq=`cat ${TMP}-ks | sort | uniq | wc -l`

echo "Total  genes       	${gnum}"	>  ${DIR}/summary.tsv
echo "Genes with K No    	${knum}"	>> ${DIR}/summary.tsv
echo "  rate (genes)     	${kper}"	>> ${DIR}/summary.tsv
echo "Uniq K No          	${kuiq}"	>> ${DIR}/summary.tsv

sc=`cat ${DIR}/core/uniq_core.tsv | wc -l`
spt=`echo "scale=3; ${sc} * 100 / ${gnum}" | bc`
spk=`echo "scale=3; ${sc} * 100 / ${knum}" | bc`

echo "Total Core         	${sc}"		>> ${DIR}/summary.tsv
echo "  rate (genes)     	${spt}"		>> ${DIR}/summary.tsv
echo "  rate (K No)      	${spk}"		>> ${DIR}/summary.tsv

sc=`cat ${TMP}-k_single | wc -l`
spt=`echo "scale=3; ${sc} * 100 / ${gnum}" | bc`
spk=`echo "scale=3; ${sc} * 100 / ${knum}" | bc`
echo "Total Singleton    	${sc}"		>> ${DIR}/summary.tsv
echo "  rate (genes)     	${spt}"		>> ${DIR}/summary.tsv
echo "  rate (K No)      	${spk}"		>> ${DIR}/summary.tsv

rm ${TMP}*
