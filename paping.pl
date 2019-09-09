#!/usr/bin/perl -w

use IO::Socket::PortState qw ( check_ports );
use JSON::MaybeXS qw ( encode_json );
use WWW::Telegram::BotAPI;
use Time::localtime;

my ( $tempo_ping_regex, $hora_local, $minutos_local, $pacotes_sucesso, $pacotes_falha );
my ( $ms_media0, $ms_media1, $ms_media2, $ms_media3, $media_ms_total, $i );
my ( $checar_porta, $status_porta, $versao, $contador, $cor_fonte, $config );
my ( $saida_json, $config_saida_json, $dados_saida_json );
my ( $telegram_api, $resposta_api_telegram, $comando, $alerta_latencia );
my ( $checar_tamanho_log, $dia_local, $mes_local, $pid );
$pacotes_sucesso = 0;
$pacotes_falha = 0;
$contador = 0;
$alerta_latencia = 0;
$pid = $$;
$versao = 'MooNEyes 1.0.11 - windows';

$telegram_api = WWW::Telegram::BotAPI -> new(

	token => 'YOUR TELEGRAM TOKEN HERE',

);

my %hash_dados_porta = (

	tcp	=> {

		$ping_porta => {},

	}
);

if ( -e "config" ) {

	open CONF, "<config";
	$config = <CONF>;
	close CONF;

	if ( $config =~ /COR_FONTE = \\e(.*)/ ) {

		$cor_fonte = $1;
		$cor_fonte = "\e$cor_fonte";

	} else {

		die $!;
	}

} else {

	die $!;

}

# ROTINA PRINCIPAL
sub main() {

	my @media_ping;

	$hora_local = localtime -> hour();
	$minutos_local = localtime -> min();

	$checar_tamanho_log = "$ping_site\/LOG$ping_site.txt";

	if ( -s "$ping_site\/LOG$ping_site.txt" > 3000000 ) {

		return check();

	}

	$tempo_ping_regex = `ping $ping_site -n 4`;

	for ( $i = 0; $i < 4; $i++) {

		if ( $tempo_ping_regex =~ /[tempo|time]=(.*)ms/g ) { # PING DO MAC /time=(.*) ms/g

			push @media_ping, $1;

			$pacotes_sucesso = $pacotes_sucesso + 1;

		} elsif ( $tempo_ping_regex =~ /Recebidos = 0/g ) {

			system "title CONTACTE O ADMINISTRADOR";

			print "$cor_fonte [\!] FALHA NA CONEXAO [\!]\nContacte imediatamente o administrador\! \e[0m";

			$telegram_api -> sendMessage ({

        		chat_id => 348318386,
        		text => "FALHA NA CONEXAO COM O SERVIDOR.\nPOSSIVELMENTE O SERVIDOR CAIU.\n\nAlvo: $ping_site\nPorta: $ping_porta\nHora: $hora_local:$minutos_local\n\nErro: \"Pacotes Recebidos = 0\"",

    		});

    		sleep 15;

    		return main();

		} elsif ( $tempo_ping_regex =~ /[tempo|time]<1/g ) {

			push @media_ping, 1;

			$pacotes_sucesso = $pacotes_sucesso + 1;

		} elsif ( $tempo_ping_regex =~ /Esgotado o tempo limite do pedido./g ) {

			push @media_ping, 0;

			$pacotes_falha = $pacotes_falha + 1;
			$pacotes_sucesso - 1;

		} else {

			print "\n\nERRO 5\n\n";

			print "$tempo_ping_regex";

			die $!;

		}

	}

	$ms_media0 = $media_ping[0];
	$ms_media1 = $media_ping[1];
	$ms_media2 = $media_ping[2];
	$ms_media3 = $media_ping[3];

	$media_ms_total = $ms_media0 + $ms_media1 + $ms_media2 + $ms_media3;

	$media_ms_total = $media_ms_total / 4;

	$checar_porta = check_ports ( $ping_site, $ping_porta, \%hash_dados_porta );
	$status_porta = $checar_porta -> {tcp}{$ping_porta}{open};

	if ( $status_porta == 1 ) {

		if ( $media_ms_total > 300 ) {

			system "cls";

			print "$cor_fonte [$ping_site] - Media da resposta = $media_ms_total"."ms\nPorta $ping_porta aberta \e[0m \n\n";

			system "title $versao [$ping_site]:$ping_porta - Media de $media_ms_total"."ms";

			open LOG, ">>$ping_site\/LOG$ping_site.txt" or die $!;
			print LOG sprintf "Ping 1: %.02f	|	Ping 2: %.02f	|	Ping 3: %.02f	|	Ping 4: %.02f	||		Media: %.03f		|| [Hora: $hora_local:$minutos_local] [ALTA LATENCIA]\n", $ms_media0, $ms_media1, $ms_media2, $ms_media3, $media_ms_total;
			close LOG;

			if ( $alerta_latencia == 0 ) {

				$telegram_api -> sendMessage ({

					chat_id => 348318386,

					text => "[\!] AVISO [\!]\nALTA LATENCIA DE PING\n\nMedia em milissegundo: $media_ms_total\n\nAlvo: $ping_site\nPorta: $ping_porta\nHora: $hora_local:$minutos_local\n",

				});

				$alerta_latencia = 4;

			} else {

				$alerta_latencia--;

			}

		} else {

			system "cls";

			print "$cor_fonte\[$ping_site] - Media da resposta = $media_ms_total"."ms\nPorta $ping_porta aberta \e[0m \n\n";

			system "title $versao [$ping_site]:$ping_porta - Media de $media_ms_total"."ms";

			open LOG, ">>$ping_site\/LOG$ping_site.txt" or die $!;
			print LOG sprintf "Ping 1: %.02f	|	Ping 2: %.02f	|	Ping 3: %.02f	|	Ping 4: %.02f	||		Media: %.03f		|| [Hora: $hora_local:$minutos_local]\n", $ms_media0, $ms_media1, $ms_media2, $ms_media3, $media_ms_total;
			close LOG;

		}

	} elsif ( $status_porta == 0 ) {

		print "$cor_fonte\n\nERRO 2\n\n";
		print "NAO FOI POSSIVEL SE CONECTAR A PORTA\nCHEQUE A SUA CONEXAO COM A INTERNET\n\e[0m";

		if ( $contador < 2 ) {

			$telegram_api -> sendMessage ({

				chat_id => 348318386,

				text => "[\!] FALHA NA CONEXAO [\!]\nISSO NAO SIGNIFICA QUE O SERVIDOR CAIU\n\nAlvo: $ping_site\nPorta: $ping_porta\nHora: $hora_local:$minutos_local\n\nO programa nao conseguiu se conectar a porta $ping_porta\n\nTentando conexao novamente em 30 segundos...\n[Tentativas de reconexao: $contador]",

			});

			open LOG, ">>$ping_site\/LOG$ping_site.txt" or die $!;
			print LOG sprintf "Ping 1: %.02f	|	Ping 2: %.02f	|	Ping 3: %.02f	|	Ping 4: %.02f	||		Media: %.03f		|| [Hora: $hora_local:$minutos_local] [FALHA NA CONEXAO COM A PORTA]\n", $ms_media0, $ms_media1, $ms_media2, $ms_media3, $media_ms_total;
			close LOG;

			$contador++;

		} else {

			system "cls";

			print "$cor_fonte\n\nERRO 2\n\n";
			print "NAO FOI POSSIVEL SE CONECTAR A PORTA\nTerminando aplicacao\n\e[0m";
			print "Hora => $hora_local:$minutos_local\n\n";

			$telegram_api -> sendMessage ({

				chat_id => 348318386,

				text => "[\!] FALHA NA CONEXAO COM A PORTA DO ALVO [\!]\nISSO NAO SIGNIFICA QUE O SERVIDOR CAIU\n\nAlvo: $ping_site\nPorta: $ping_porta\nHora: $hora_local:$minutos_local\n\nNao foi possivel conctar-se a porta\nChque o servidor ou contacte um administrador e depois reinicie o monitoramento\n[Tentativas de reconexao: $contador]",

			});

			open LOG, ">>$ping_site\/LOG$ping_site.txt" or die $!;
			print LOG sprintf "Ping 1: %.02f	|	Ping 2: %.02f	|	Ping 3: %.02f	|	Ping 4: %.02f	||		Media: %.03f		|| [Hora: $hora_local:$minutos_local] [APLICACAO TERMINADA]\n", $ms_media0, $ms_media1, $ms_media2, $ms_media3, $media_ms_total;
			close LOG;

			die $!;

		}

		sleep 30;

		return main();

	} else {

		print "\n\nERRO 1\n\n";

		die $!;

	}

	$dados_saida_json = {

		alvo 			=> "$ping_site",

		hora 			=> "$hora_local:$minutos_local",

		mediaPing 		=> "$media_ms_total",

		pacotesFalha 	=> "$pacotes_falha",
		pacotesSucesso 	=> "$pacotes_sucesso",

		pid 			=> "$pid",

		ping1 			=> "$ms_media0",
		ping2 			=> "$ms_media1",
		ping3 			=> "$ms_media2",
		ping4 			=> "$ms_media3",

		porta 			=> "$ping_porta",

	};

	$config_saida_json = JSON::MaybeXS -> new ( utf8 => 1, pretty => 1, sort_by => 1 );

	$saida_json = $config_saida_json -> encode ( $dados_saida_json );

	open JSON, ">$ping_site\/output-$ping_site.JSON" or die $!;
	print JSON $saida_json;
	close JSON;

	print "$saida_json";

	$contador = 0;

	return main();


}

sub check() {

	print "\n\nRenovando arquivos..";

	$dia_local = localtime -> mday();
	$mes_local = localtime -> mon();

	sleep 1;

	system "rename $ping_site\\LOG$ping_site.txt LOG$ping_site.txt.bak-$dia_local-$mes_local";

	return main();

}

return main();

#
#
# FIM DO CODE PARA WINDOWS

# ORGANIZAR O CÓDIGO [EM ANDAMENTO]
# PORTSCAN PARA OBTER BOOLEAN PARA SABER SE PORTA ESTA RESPONDENDO OU NÃO [FEITO]
# AUTO-COMPLEMENTO DE STRING PARA SEMPRE RETORNAR VALOR COM "www." [SEM NECESSIDADE ATUALMENTE]
# ADICIONAR SAÍDA EM JSON ( PESQUISAR NA INTERNET ) [FEITO]
# ADICIONAR VERIFICAÇÃO DE CONTEÚDO DE RETORNO [FEITO]
# ADICIONAR CÓDIGOS DE ERRO SEMPRE QUE POSSÍVEL [FEITO]
# ADICIONAR VALOR DE RETORNO PARA CADA OPERAÇÃO PARA VERIFICAR COM AUTENTICIDADE SE A CONEXÃO ESTÁ FUNCIONANDO [FEITO]
#
# EDIÇÃO V1

# ADICIONAR QUANTIDADE TOTAL E POR CADA REQUISIÇÃO DE PACOTES PERDIDOS NO PING [FEITO]
# COR PARA O FORMATO DE SAÍDA NO TERMINAL [FEITO]
# ADIOCIONAR EVAL PARA QUE O PROGRAMA NÃO PARE CASO NÃO CONECTE A PORTA DESEJADA E CONTINUE DANDO A MÉDIA [SEM NECESSIDADE ATUALMENTE]
# RECEBER VALOR PID DO PROCESSO PARA FINALIZAÇÃO DA CHECAGEM [FEITO]
# VERIFICAR SE A MÉDIA ESTÁ ACIMA DE 300ms PARA AVISAR VIA TELEGRAM [FEITO]
# ADICIONAR DADOS DE ERRO NO LOG E NO ARQUIVO JSON
# CONSERTAR BUG DO USO DA MEMÓRIA ( REF: https://stackoverflow.com/questions/8924142/how-to-free-memory-in-perl ) [EM AVALIAÇÃO]
#
# EDIÇÃO 1.1

# RE-EXECUTAR MAIN.PL PARA GERAR UM NOVO CABEÇALHO DE LOG
#
# EDIÇÃO 1.1.1

# FAZER CHECAGEM DE PING E PORTA EM TEMPO REAL ( USAR DUAS VARIAVEIS PARA GUARDAR VALOR NOVO E VALOR ANTIGO E IR SOMANDO E FAZEDO MÉDIA COM NÚMERO DE CONTAGEM ( $i ) PARA SEMPRE DAR RETORNO EM TEMPO REAL ) [SEM NECESSIDADE ATUALMENTE]
# ADICONAR OPÇÃO DE ESCOLHER MAIS DE UMA PORTA PARA O MESMO SITE ALVO DO PING
# ADICIONAR LOG AO PROGRAMA ( limite máximo de 3MB para cada log ) [FEITO]
# ADICIONAR LOG DE ERRO
# FAZER O PROGRAMA ABRIR O PAPING EM UMA NOVA JANELA
# CRIAR MANAGER IGUAL AO CCH [FEITO]
# PASSAR ARGUMENTOS AGOARA PARA O PAPING.PL ATRAVÉS DO @ARGV[0], @ARGV[1] ( SITE, PORTA ) [FEITO]
# ADICIONAR VERIFICAÇÃO DE CONFIGURAÇÃO A CADA LOOP PARA SABER SE QUER NOTIFICAÇÃO VIA E-MAIL OU TELEGRAM OU OS DOIS
#
# EDIÇÃO V2

# BUGS CONSERTADOS
#
# RETORNO 6 AO NÃO CONSEGUIR RESOLVER A REGEX DO PING [SOLUCIONADO]
# BUG DOS PACOTES ENVIADOS E FALHAS [SOLUCIONADO]
# BUG DO "A sintaxe do nome do arquivo, do nome do diretório ou do rótulo do volume está incorreta." [SOLUCIONADO]
# BUG DA FALHA NA CONEXÃO COM O SERVIDOR ( CONTACTE IMEDIATAMENTE O ADMINISTRADOR )
# BUG DO "RENEVANDO OS ARQUIVOS" EM QUE ELE TENTAVA CRIAR UM ARQUIVO COM O MESMO NOME DE UM ARQUIVO JÁ EXISTENTE [SOLUCIONADO]
# NOTIFICAÇÃO DE ALTA LATENCIA DE PING [SOLUCIONADO]
# BUG DA COR [SOLUCIONADO]
