#! /bin/bash
#===============================
#
# step6
#
# 2026/02/12 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname | xargs dirname`
. ${TOP}/mo_genome_function2/lib

#====================================
# remove all

step "6"
#====================================
#--------------------
phase "remove working dir"
#--------------------
rm -fr ${TMP}
