#! /bin/bash
#===============================
#
# mo_kno_cnt
#
#	各ゲノムに K no が何回搭乗するか数える
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
#		> mo_kno_cnt.sh sample.txt
#
# 2022/10/14 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
KNO=$1
FILE=$2

for k in `cat ${FILE} | awk '{print $1}' | cut -d "|" -f 2 | cut -d "_" -f 1 | sort | uniq`
do
	num=`grep ${k} ${FILE} | grep -w ${KNO} | sort | uniq | wc -l`
	echo "${k}	${num}"
done
