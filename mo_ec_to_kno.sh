#! /bin/bash
#===============================
#
# mo_ec_to_kno
#
#	EC 番号を入れると、必要な K ナンバーの一覧を返す
#
#	> mo_ec_to_kno 2.2.1.2
#	K00616
#	K13810
#
# 2022/10/31 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname`
. ${TOP}/lib

get_kegg

#    1.2.3.4
# -> 1\.2\.3\.4
EC=`echo $1 | sed -e "s/\./\\\\\./g"`

grep -w ${EC} ${KEGG_FILE} | awk '{print $2}' | sort | uniq
