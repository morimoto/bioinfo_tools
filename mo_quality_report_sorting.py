#! /usr/bin/env python3
#===============================
#
# mo_quality_report_sorting
#
#	> mo_quality_report_sorting.py A B C D X
#
#		A : report file		(ex. quality_report.tsv)
#		B : Completeness	(ex. 90.1)
#		C : Contamination	(ex. 5.0)
#		D : output dir		(ex. /tmp)
#		X : array of files
#
# 2024/09/18 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
import sys
import os
import subprocess

def exec(cmd):
    child = subprocess.Popen(cmd, shell=True,
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = child.communicate()

    return stdout.decode('utf8')


if (len(sys.argv) < 3):
    raise Exception("param error")

# ignore command name
sys.argv.pop(0)

report =       sys.argv.pop(0)
comp_t = float(sys.argv.pop(0))
cont_t = float(sys.argv.pop(0))
dir    =       sys.argv.pop(0)

if (not os.path.isfile(report)):
    raise Exception("report is not file")

if (not os.path.isdir(dir)):
    raise Exception("dir not exist")

for file in sys.argv:
    # file : hoge/xxxx.fna
    out = exec("grep {} {}".format(os.path.splitext(os.path.basename(file))[0], report))
    if (not len(out)):
        continue

    # array[0] : name
    # array[1] : Completeness
    # array[2] : Contamination
    array = out.split()

    if ("{}.fna".format(array[0]) != os.path.basename(file)):
        continue

    comp = float(array[1])
    cont = float(array[2])

    if (comp < comp_t):
        continue

    if (cont > cont_t):
        continue

    print("{} - {} - {}".format(comp, cont, array[0]))
    exec("mv {} {}".format(file, dir))
