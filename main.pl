#!/usr/bin/perl 

use strict;
use warnings;
use Time::localtime;

my ( $clear_screen, $hora_local, $minutos_local, $dia_local, $mes_local, $versao, $OS, $pid );
my ( $cor_fonte, $opcoes, $i, $memoria );
my ( $linha, @array_linha, $contagem_linha, $cor_para_alterar );
my ( @array_pid, $numero_pids, $opcao_pid );
$hora_local = localtime -> hour();
$minutos_local = localtime -> min();
$dia_local = localtime -> mday();
$mes_local = localtime -> mon();
$cor_fonte = '\e[92m';
$OS = $^O;
$pid = $$;

$versao = 'MooNEyes 1.0.11 - windows';
system "title $versao";

###################
if ( $OS eq "darwin" ) {

	$clear_screen = "clear";

} elsif ( $OS eq "MSWin32" ) {

	$clear_screen = "cls";

}

my ( $site, $porta ) = @ARGV;

sub conf() {

	system "$clear_screen";

	print "Checando arquivos...\n\n";

	sleep 1;

	if ( -e "config" ) {

		print "[Checando] \"config\"........... OK\n\n";

		sleep 1;

		return main();
 
	} else {

		print "[CONFIGURACAO INICIAL]\n\n";
		print "Deseja colocar alguma cor especifica\? [DEFAULT: VERDE]\n";
		print "1 = Verde\n2 = Amarelo\n3 = Vermelho\n4 = Branco\n5 = Cyano\n\n";
		print "=> ";
		$cor_fonte = <STDIN>;

		if ( $cor_fonte == 1 ) {

			$cor_fonte = '\e[92m';

			print "Cor definida como => \e[92mVerde\e[0m\n\n";

		} elsif ( $cor_fonte == 2 ) {

			$cor_fonte = '\e[93m';

			print "Cor definida como => \e[93mAmarelo\e[0m\n\n";

		} elsif ( $cor_fonte == 3 ) {

			$cor_fonte = '\e[91m';

			print "Cor definida como => \e[91mVermelho\e[0m\n\n";

		} elsif ( $cor_fonte == 4 ) {

			$cor_fonte = '\e[97m';

			print "Cor definida como => \e[97mBranco\e[0m\n\n";

		} elsif ($cor_fonte == 5 ) {

			$cor_fonte = '\e[96m';

			print "Cor definida como => \e[96mCyano\e[0m\n\n";

		} else {

			$cor_fonte = '\e[92m';

			print "\n\nDefinindo como padrao a cor verde..\n\n";

		}

		open CONF, ">config" or die $!;
		print CONF "COR_FONTE = $cor_fonte\n";
		close CONF;

	}

	sleep 2;

	print "";

}

sub init() {

	if ( @ARGV ) {

		system "$clear_screen";

		print "Iniciando...";

		sleep 1;	

		system "perl init.pl $site $porta";

	} else {

		print "\n\n[\!] Necessario ser passado [ALVO] e [PORTA] [\!]\n";

		sleep 2;

		return main();

	}

}

sub mudar_cor() {

	print "\n\n//------------------------------------------------\n";
	print "Escolha alguma cor especifica [DEFAULT: VERDE]\n";
	print "1 = Verde\n2 = Amarelo\n3 = Vermelho\n4 = Branco\n5 = Cyano\n\n";
	print "=> ";
	$cor_fonte = <STDIN>;

	if ( $cor_fonte == 1 ) {

			$cor_fonte = '\e[92m';

			print "\nCor definida como => \e[92mVerde\e[0m\n\n";

		} elsif ( $cor_fonte == 2 ) {

			$cor_fonte = '\e[93m';

			print "\nCor definida como => \e[93mAmarelo\e[0m\n\n";

		} elsif ( $cor_fonte == 3 ) {

			$cor_fonte = '\e[91m';

			print "\nCor definida como => \e[91mVermelho\e[0m\n\n";

		} elsif ( $cor_fonte == 4 ) {

			$cor_fonte = '\e[97m';

			print "\nCor definida como => \e[97mBranco\e[0m\n\n";

		} elsif ($cor_fonte == 5 ) {

			$cor_fonte = '\e[96m';

			print "\nCor definida como => \e[96mCyano\e[0m\n\n";

		} else {

			$cor_fonte = '\e[92m';

			print "\n\nDefinindo como padrao a cor verde..\n\n";

		}

	$contagem_linha = 0;

	open CONF, "<config" or die $!;

	while ( $linha = <CONF> ) {

		chomp $linha;

		$array_linha[$contagem_linha] = $linha;

		if ( $array_linha[$contagem_linha] =~ /COR_FONTE = (\\e.*)/ ) {

			print "\nCor alterada..\n";

			$memoria = "COR_FONTE = $cor_fonte";

			$array_linha[$contagem_linha] = $memoria;

			sleep 1;

		}

		$contagem_linha++;

	}

	open CONF, ">config" or die $!;
	for ( $i = 0; $i < $contagem_linha; $i++) {

		print CONF "$array_linha[$i]\n";

	}

	close CONF;

	return main();

}

sub kill_pid() {

	@array_pid = `tasklist | findstr /i "perl"`;

	$numero_pids = @array_pid;

	for ( $i = 0; $i < $numero_pids; $i++ ) {

		print "\n[$i] - $array_pid[$i]";

	}

	print "\nSelecione o PID que deseja matar => ";
	$opcao_pid = <STDIN>;

	if ( $opcao_pid > $numero_pids ) {

		print "Nenhuma PID foi cancelada..";

	} elsif ( $opcao_pid < 0 ) {

		print "Nenhuma PID foi cancelada..";

	} else {

		if ( $array_pid[$opcao_pid] =~ /perl.exe (.*) Console/ ) {

			system "tskill $1";

		}

	}

	sleep 1;

	return main();

}

sub user() {



}

sub main() {

	system "$clear_screen";

	print "//------------------------------------------------\n";
	print "//\n";
	print "// [0] - Iniciar MooNEyes\n";
	print "// [1] - Mude a cor das letras\n";
	print "// [2] - Matar Processos (PID)\n";
	print "// [3] - Adicionar usuarios\n";
	print "//\n";
	print "//------------------------------------------------\n";
	print "//\n// => ";
	$opcoes = <STDIN>;

	if ( $opcoes ==  0 ) {

		return init();

	} elsif ( $opcoes ==  1 ) {

		return mudar_cor();

	} elsif ( $opcoes ==  2 ) {

		return kill_pid();

	} else {

		print "Digite entre 0 e 2\n";

		sleep 2;

		return main();

	}

}

return conf();

#############################################
#
#	USE: perl main.pl [SITE] [PORTA]
#
#	Ex:perl main.pl www.google.com 80
#

########## TO DO
#
#
# FAZER O MAIN GERENCIÁVEL COM 2 THREADS ONDE UMA VAI INICIAR OS PROCESSOS [EM ANALISE]
# COLOCAR OPCAO DE AVISO SONORO ( BASH ) [PENDENTE]
# CRIAR MENU GERENCIALVEL [EM ANDAMENTO]
# ADICIONAR MATADOR DE PROCESSOS  [FEITO]
# MUDAR COR [FEITO]
# CHECAGEM DO CONTEÚDO DO config
# ADICIONAR OPCAO DE ADICIONAR USUARIOS DO TELEGRAM E COLOCAR UM FOR COM O NUMERO DE INDICES DO ARRAY PARA FAZER LOOP EM CADA UM USUARIO PASSADO