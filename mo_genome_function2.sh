#! /bin/bash
#===============================
#
# mo_genome_function2
#
# 2026/01/30 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
TOP=`readlink -f "$0" | xargs dirname`

${TOP}/mo_genome_function2/step1.sh $@
${TOP}/mo_genome_function2/step2.sh
${TOP}/mo_genome_function2/step3.sh
${TOP}/mo_genome_function2/step4.sh
${TOP}/mo_genome_function2/step5.sh
${TOP}/mo_genome_function2/step6.sh
