#! /bin/bash
#===============================
#
# mo_add_group group list.tsv
#
#	出力は result-list.tst
#
#	group: グループファイル
#		----------------------
#		Group	Function
#		Carbon metabolism	glycolysis
#		Carbon metabolism	gluconeogenesis
#		Carbon metabolism	TCA Cycle
#		Oxidative phosphorylation (Nuo, ATPases)	NAD(P)H-quinone oxidoreductase
#		Oxidative phosphorylation (Nuo, ATPases)	NADH-quinone oxidoreductase
#		Oxidative phosphorylation (Nuo, ATPases)	Na-NADH-ubiquinone oxidoreductase
#		...
#	list.tsv: ターゲットファイル
#		デリミタはタブ
#		----------------------
#		Function	glycolysis	gluconeogenesis	TCA Cycle...
#		LAS006	 0.78	 0.78	 0.62	 0	 0.0	 0.33...
#		LAS007	 0.67	 0.78	 0.75	 0	 0.98	 0.17...
#
# 2025/06/16 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
GROUP=$1
LIST=$2
TMP=/tmp/mo_add_group_$$

[ ! -f ${GROUP} ] && echo "No such file ${GROUP}" && exit
[ ! -f ${LIST} ]  && echo "No such file ${LIST}"  && exit

# remove 1st "Function"
FUNCTION=`head -n 1 ${LIST} | cut -d "	" -f 2-`

IFS_BACKUP=$IFS
IFS='	'

echo -n "Group	" > ${TMP}
for func in ${FUNCTION}
do
	grp=`grep "${func}" ${GROUP} | head -n 1 | cut -d "	" -f 1`
	echo -n "${grp}	" >> ${TMP}
done
IFS=${IFS_BACKUP}

echo		>> ${TMP}
cat ${LIST}	>> ${TMP}
mv ${TMP} result-`basename ${LIST}`
