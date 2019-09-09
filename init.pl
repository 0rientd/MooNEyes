#!/usr/bin/perl 

use strict;
use warnings;
use Time::localtime;

my ( $clear_screen, $hora_local, $minutos_local, $dia_local, $mes_local, $versao, $OS, $pid );
$hora_local = localtime -> hour();
$minutos_local = localtime -> min();
$dia_local = localtime -> mday();
$mes_local = localtime -> mon();
$OS = $^O;
$pid = $$;

$versao = 'MooNEyes 1.0.11 - windows';

###################
if ( $OS eq "darwin" ) {

	$clear_screen = "clear";

} elsif ( $OS eq "MSWin32" ) {

	$clear_screen = "cls";

}

system "$clear_screen";

my ( $site, $porta ) = @ARGV;

if ( $site, $porta ) {

	if ( -d "$site" ) {

		open FILE, ">>", "$site\/LOG$site.txt" or die $!;
		print FILE "==========================================================================================================\n";
		print FILE "Data LOG MooNEyes | $site\n";
		print FILE "Versao: $versao\n";
		print FILE "Data: $dia_local/$mes_local - Hora: $hora_local:$minutos_local\n";
		print FILE "ProcessID: $pid\n";
		print FILE "===\n\n";
		print FILE "__________________________________________________________________________________________________________\n";
		close FILE;

		our ( $ping_site )	= ( $site );
		our ( $ping_porta ) = ( $porta );

		do "./paping.pl";

	} else {

		mkdir "$site" or die $!;

		open FILE, ">>", "$site\/LOG$site.txt" or die $!;
		print FILE "===\n";
		print FILE "Data LOG MooNEyes | $site\n";
		print FILE "Versao: $versao\n";
		print FILE "Data: $dia_local/$mes_local - Hora: $hora_local:$minutos_local\n";
		print FILE "===\n\n";
		close FILE;

		our ( $ping_site ) = ( $site );
		our ( $ping_porta ) = ( $porta );

		do "./paping.pl";

	}

} else {

	warn "ERRO 5\n";

	die;

}

#############################################
#
#	USE: perl main.pl [SITE] [PORTA]
#
#	Ex:perl main.pl www.google.com 80
#
