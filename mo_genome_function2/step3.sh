#! /bin/bash
#===============================
#
# step3
#
# 2026/02/02 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname | xargs dirname`
. ${TOP}/mo_genome_function2/lib

#====================================
# Parse eggNOG-mapper

step "3"
#====================================

[ x"${INPUT_E}" = x ] && exit

#--------------------
phase "parse eggNOG-mapper"
#--------------------
