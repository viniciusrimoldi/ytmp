#!/bin/bash
#
# DESCRIPTION   Script para executar videos do youtube no terminal. Utiliza o 
#               Youtube-DL + Mplayer para executar os videos. Apresenta suporte
#               para reproducao de videos comuns, playlists. Reproduzindo tanto
#               video ou somente o audio.
#
# AUTHOR        Vinicius D Sartori Rimoldi    <viniciusrimoldii@gmail.com>
#
# LICENSE       GpL3.
#
# CREATED       202006231158
#



######################## INICIO SCRIPT #############################

#
# Variaveis globais. 
#    (OBS: Path de diretorios devem ser adicionados sem "/" no fim do caminho.)
#
DIR_FAV=~/.ytmp.d/favorites.d
DIR_HIST=~/.ytmp.d/history.d
DIR_SRC=~/.ytmp.d


# Cria diretorio padrao do ytmp.
if [[ ! -d $DIR_SRC ]]; then
	mkdir -p $DIR_SRC;
	mkdir -p $DIR_FAV;
	mkdir -p $DIR_HIST;
fi

# Verifica os programas instalados (dependencias do script).
if [[ $(type -a python > /dev/null 2>&1; echo $?) -eq 1 ]]; then  # Verifica Python.
	echo 'ERROR: Python not installed!';
	exit 1;
fi

if [[ $(type -a mplayer > /dev/null 2>&1; echo $?) -eq 1 ]]; then  # Verifica Mplayer.
	echo 'ERROR: Mplayer not installed!';
	exit 1;
fi

if [[ $(type -a youtube-dl > /dev/null 2>&1; echo $?) -eq 1 ]]; then  # Verifica Youtube-DL.
	echo 'INSTALLING Youtube-DL ...';
	curl -# -L https://yt-dl.org/downloads/latest/youtube-dl \
		-o $DIR_SRC/youtube-dl \
		&& echo 'Youtube-DL installed !'; # Instalado em ~/.ytmp.d/

	chmod 0755 $DIR_SRC/youtube-dl; # Da permissao de execucao ao arquivo.
fi


# Baixa o script do YTMP do GitHub.
curl -# -L 'https://raw.githubusercontent.com/viniciusrimoldi/ytmp/master/ytmp.sh' \
	-o $DIR_SRC/ytmp.sh \
	&& chmod 0755 $DIR_SRC/ytmp.sh \
	&& echo 'Ytmp.sh Installed!' \
	&& `curl -# -L 'https://raw.githubusercontent.com/viniciusrimoldi/ytmp/master/version' -o $DIR_SRC/version`;

# Observacoes para o usuario.
echo;
echo 'Create alias for script:';
echo '$ alias ytmp="bash ~/.ytmp.d/ytmp.sh"';
echo '  (add in your ~/.bashrc to run permanet!)';
echo;

exit 0;
