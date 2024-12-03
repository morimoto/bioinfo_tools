#! /bin/bash
#===============================
#
# mo_kno_name
#
#	指定された K no の名前を取得する
#	カテゴリ、シンボル、名前をタブ区切りで表示
#	複数のカテゴリがある場合も全部表記
#
#	カテゴリ名などは KEGG ファイルから取得する
#	KEGG ファイルは１日１回更新する
#
#	(以下はわかりやすくするためにタブを揃えているが、本当はタブは１つ)
#	> mo_kno_name.sh K00001
#	09100 Metabolism	09101 Carbohydrate metabolism			00010 Glycolysis / Gluconeogenesis [PATH:ko00010]			E1.1.1.1, adh	alcohol dehydrogenase [EC:1.1.1.1]
#	09100 Metabolism	09101 Carbohydrate metabolism			00620 Pyruvate metabolism [PATH:ko00620]				E1.1.1.1, adh	alcohol dehydrogenase [EC:1.1.1.1]
#	09100 Metabolism	09103 Lipid metabolism				00071 Fatty acid degradation [PATH:ko00071]				E1.1.1.1, adh	alcohol dehydrogenase [EC:1.1.1.1]
#	09100 Metabolism	09105 Amino acid metabolism			00350 Tyrosine metabolism [PATH:ko00350]				E1.1.1.1, adh	alcohol dehydrogenase [EC:1.1.1.1]
#	09100 Metabolism	09108 Metabolism of cofactors and vitamins	00830 Retinol metabolism [PATH:ko00830]					E1.1.1.1, adh	alcohol dehydrogenase [EC:1.1.1.1]
#	09100 Metabolism	09111 Xenobiotics biodegradation and metabolism	00625 Chloroalkane and chloroalkene degradation [PATH:ko00625]		E1.1.1.1, adh	alcohol dehydrogenase [EC:1.1.1.1]
#	09100 Metabolism	09111 Xenobiotics biodegradation and metabolism	00626 Naphthalene degradation [PATH:ko00626]				E1.1.1.1, adh	alcohol dehydrogenase [EC:1.1.1.1]
#	09100 Metabolism	09111 Xenobiotics biodegradation and metabolism	00980 Metabolism of xenobiotics by cytochrome P450 [PATH:ko00980]	E1.1.1.1, adh	alcohol dehydrogenase [EC:1.1.1.1]
#	09100 Metabolism	09111 Xenobiotics biodegradation and metabolism	00982 Drug metabolism - cytochrome P450 [PATH:ko00982]			E1.1.1.1, adh	alcohol dehydrogenase [EC:1.1.1.1]
#
# 2022/10/31 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname`
. ${TOP}/lib

TMP=/tmp/mo_kno_name

rm -fr ${TMP}

KNUM=$1

get_kegg

LINES=`grep -n -w ${KNUM} ${KEGG_FILE} | cut -d ":" -f 1`
for line in ${LINES}
do
	head -n ${line} ${KEGG_FILE} > ${TMP}
	NAME_A=`grep "^A" ${TMP} | sed -e "s/^A//g" | tail -n 1`
	NAME_B=`grep "^B" ${TMP} | grep "^B  " | sed -e "s/^B\s*//g" | tail -n 1`
	NAME_C=`grep "^C" ${TMP} | grep "^C  " | sed -e "s/^C\s*//g" | tail -n 1`

	KLINE=`tail -n 1 ${TMP} | sed -e "s/^D\s*K[0-9]*\s*//"`
	SYMBOL=`echo ${KLINE} | cut -d ";" -f 1`
	NAME=`echo ${KLINE} | cut -d ";" -f 2 | sed -e "s/^\s*//g"`

	echo "${NAME_A}	${NAME_B}	${NAME_C}	${SYMBOL}	${NAME}"
done

rm -fr ${TMP}
