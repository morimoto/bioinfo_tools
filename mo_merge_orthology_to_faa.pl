#! /usr/bin/perl
#===============================
#
# mo_merge_orthology_to_faa
#
# 2021/11/04 Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
#===============================
$file_faa = shift( @ARGV );
$file_ort = shift( @ARGV );

@LIST = `cat $file_faa`;
foreach $list (@LIST) {
	@data = split( /\t/, $list );
	chomp($data[0]);
	chomp($data[1]);

	if ($data[1] eq "" ) {
		print "$data[0]\n";
		next;
	}

	@ORT = `grep $data[1] ${file_ort}`;
	foreach $ort (@ORT) {
		print "$data[0]\t$data[1]\t${ort}";
	}
}
