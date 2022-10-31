#! /bin/bash
#===============================
#
# mo_ec_pass
#
#	指定された EC を通れるかどうかを示す.
#	OK/NG で表記した後、根拠も示す
#
#	オプションで指定する場合
#
#		> mo_ec_passh.sh user_ko.txt 2.2.1.2
#
#	複数の EC を経由する場合は "-" でつなげる
#
#		> mo_ec_passh.sh user_ko.txt 4.4.1.22-1.1.1.284-3.1.2.12
#
#	スペースで区切る事で、複数の経路を同時に指定もできる
#
#		> mo_ec_passh.sh user_ko.txt 2.2.1.2 4.4.1.22-1.1.1.284-3.1.2.12
#
#	分かりやすくファイルに落としておいて、-f で指定もできる
#
#		--- Formaldehyde_to_Formate ---
#		1.2.1.46
#		4.4.1.22-1.1.1.284-3.1.2.12
#		-------------------------------
#
#		> mo_ec_passh.sh user_ko.txt -f Formaldehyde_to_Formate
#
#
#	KEGG ファイルには EC が付いてないものの、KEGG の Web ページでは
#	（なぜか）EC に含まれる K ナンバーも対象に入れたい場合、
#	mo_ec_pass.conf ファイルを作成すると追加できる
#
#		---- mo_ec_pass.conf ----
#		1.14.13.25:K16160,K16162
#		...
#		-------------------------
#
#	この場合、結果には(custom) と表示される
#
#		> mo_ec_passh.sh user_ko.txt -f  GenomeX_to_GenomeY
#		NG : w.x.y.z
#		OK : a.b.c.d-1.14.13.25 (custom)
#		....
#
# 2022/10/31 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f ./mo_analysis.sh | xargs dirname`
. ${TOP}/lib

TMP=/tmp/mo_ec_pass

rm -f ${TMP}*

FILE=$1
if [ ! -f ${FILE} ]; then
	echo "no such file"
	exit 1
fi

shift

if [ "x$1" = "x-f" ]; then
	ECs=`cat $2`
else
	ECs="$@"
fi

for ecs in ${ECs}
do
	CUSTOM=
	for ec in `echo ${ecs} | sed -e "s/-/ /g"`
	do
		opt=`${TOP}/mo_ec_to_kno.sh ${ec} | sed -e "s/^/-e /g"`
		if [ -f ${TOP}/mo_ec_pass.conf ]; then
			opt2=`grep "^${ec}:" ${TOP}/mo_ec_pass.conf | cut -d ":" -f 2 | sed -e "s/,/\n/g" | sed -e "s/^/-e /g"`
			if [ x"${opt2}" != x ]; then
				opt="${opt} ${opt2}"
				CUSTOM=" (custom)"
			fi
		fi
		grep -w ${opt} ${FILE} > ${TMP}-${ec}
		echo $? >> ${TMP}-ret-${ecs}
	done
	grep 0 ${TMP}-ret-${ecs} > /dev/null
	if [ $? = 0 ]; then
		echo -n "OK : "
	else
		echo -n "NG : "
	fi

	echo ${ecs}${CUSTOM}
done

echo "========="

for ecs in ${ECs}
do
	for ec in `echo ${ecs} | sed -e "s/-/ /g"`
	do
		echo
		echo "EC: ${ec}"
		${TOP}/mo_ec_to_kno.sh ${ec}
		if [ -f ${TOP}/mo_ec_pass.conf ]; then
			grep "^${ec}:" ${TOP}/mo_ec_pass.conf | cut -d ":" -f 2 | sed -e "s/,/\n/g" | sed -e "s/$/ (custom)/g"
		fi
		cat ${TMP}-${ec}
	done
done

rm -fr ${TMP}*
