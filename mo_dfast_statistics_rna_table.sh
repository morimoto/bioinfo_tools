#! /bin/bash
#===============================
#
# mo_dfast_statistics_rna_table
#
# 2023/06/19 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
FILE=dfast_statistics_rna_table.xls
FAs=`ls -d *.fa`
ARRs=(
"name"
"Total Sequence Length (bp)"
"Number of Sequences"
"Longest Sequences (bp)"
"N50 (bp)"
"Gap Ratio (%)"
"GCcontent (%)"
"Number of CDSs"
"Average Protein Length"
"Coding Ratio (%)"
"Number of rRNAs"
"Number of tRNAs"
"Number of CRISPRs"
)
TMSG=(
"transfer-messenger RNA"
)
RNAs=(
"tRNA-Pro"
"tRNA-Asn"
"tRNA-Thr"
"tRNA-Gly"
"tRNA-Tyr"
"tRNA-Gln"
"tRNA-Glu"
"tRNA-Ile"
"tRNA-Ala"
"tRNA-Ser"
"tRNA-Arg"
"tRNA-Val"
"tRNA-Lys"
"tRNA-Leu"
"tRNA-Met"
"tRNA-Asp"
"tRNA-Cys"
"tRNA-Phe"
"tRNA-Trp"
"tRNA-His"
)
RRNAs=(
"16S ribosomal RNA"
"23S ribosomal RNA"
"5S ribosomal RNA"
)

# titles
: > ${FILE}
for ((i = 0; i < ${#ARRs[@]}; i++))
do
	echo -n "${ARRs[$i]}	" >> ${FILE}
done
for ((i = 0; i < ${#TMSG[@]}; i++))
do
	echo -n "${TMSG[$i]}	" >> ${FILE}
done
for ((i = 0; i < ${#RNAs[@]}; i++))
do
	echo -n "${RNAs[$i]}	" >> ${FILE}
done
echo -n "num	" >> ${FILE}
for ((i = 0; i < ${#RRNAs[@]}; i++))
do
	echo -n "${RRNAs[$i]}	" >> ${FILE}
done
echo "num" >> ${FILE}

for fa in ${FAs}
do
	# statistics
	echo -n "$fa	" >> ${FILE}
	for d in `cat ${fa}/statistics.txt | cut -d "	" -f 2`
	do
		echo -n "${d}	" >> ${FILE}
	done

	# transfer-messenger
	for ((i = 0; i < ${#TMSG[@]}; i++))
	do
		d=`grep "${TMSG[$i]}" ${fa}/rna.fna | wc -l`
		echo -n "${d}	" >> ${FILE}
	done

	# RNA
	num=0
	for ((i = 0; i < ${#RNAs[@]}; i++))
	do
		d=`grep "${RNAs[$i]}" ${fa}/rna.fna | wc -l`
		echo -n "${d}	" >> ${FILE}
		[ ${d} != 0 ] && num=`expr ${num} + 1`
	done
	echo -n "${num}	" >> ${FILE}

	# ribosomal RNA
	num=0
	for ((i = 0; i < ${#RRNAs[@]}; i++))
	do
		d=`grep "${RRNAs[$i]}" ${fa}/rna.fna | wc -l`
		echo -n "${d}	" >> ${FILE}
		[ ${d} != 0 ] && num=`expr ${num} + 1`
	done
	echo "${num}"	>> ${FILE}
done


