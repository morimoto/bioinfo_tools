#! /bin/bash
#===============================
#
# mo_stream_dfast
#
# 2023/01/13 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
OUT=stream_dfast_out
FILES=$@

mkdir -p ${OUT}
for f in $FILES; do
	PREFIX=`echo ${f} | cut -d "-" -f 1`
	dfast --genome $f --minimum_length 200 --offset 100 --aligner blastp --out ${OUT}/$f --locus_tag_prefix ${PREFIX} --cpu 30 --dbroot ~/HDD20/bioinfo_db/DFAST_DB/ --force
done
