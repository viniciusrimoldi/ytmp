#!/bin/bash
#
# DESCRIPTION   Script para executar videos do youtube no terminal. Utiliza o 
#               Youtube-DL + Mplayer para executar os videos. Apresenta suporte
#               para reproducao de videos comuns, playlists. Reproduzindo tanto
#               video ou somente o audio.
#
# AUTHOR        Vinicius D Sartori Rimoldi.
#
# LICENSE       GpL3.
#
# CREATED       201901122222
#
# MODIFICATION	201901191809	Construção de lista a partir de pesquisas diferentes.
#		201906262203	Carregamento de buffer antes de iniciar a reprodução.
#		202005041108    Update para Youtube-dl via curl.
#               202005151744    Add opcao ".favorite" e ".play_fav".
#               202005170530    Arrumado path com variaveis globais.
#               202005170610	Add opcao ".install".
#                               `- Local do youtube-dl para ~/ytmp.d/ .
#               202005231503    Add ".msearch" para pesquisa no music.youtube.com.
#               202006202019    Add ".plsearch" para pesquisa e execucao playlists.



# FAZER:
#	- Carregamento de vídeos de pesquisas diferentes para formar uma sequencia de reprodução.
#       - Ajustar o '.play' para reproduzir o '.msearch'.
#


# CONFIGURACOES PELO CURL: (NAO APLICADO AQUI!!! [para implementacao futura])
#  &itag=250 >>> audio 144
#  &clen=999999 >>> tamanho final do buffer de video
#  &range=0-999999 >>> o tamanho do buffer que sera baixado
#
#  Para buscar linha com url do servidor de video: ytplayer.config.loaded
#




###########################  INICIO DO SCRIPT #############################
#
#
# Captura o pid do script para construir um arquivo para receber o download 
# do youtube-dl.
#
PID_ID=$$;


#
# Variaveis globais. 
#    (OBS: Path de diretorios devem ser adicionados sem "/" no fim do caminho.)
#
DIR_FAV=~/.ytmp.d/favorites.d
DIR_SRC=~/.ytmp.d
FILE_TEMP=/tmp/ytcookie


# Titulo para o terminal.
echo -ne "\033]0;Youtube-Mplayer\007";


#
# Função para executar VÍDEO COMUM com o mplayer e o youtube-dl.
#
F_PLAYER () {
	# Parametros.
	FORMAT="$1";
	URL="$2";

	# Remove o arquivo temporário para que possa assistir outro vídeo.
	[[ -f $FILE_TEMP ]] && rm $FILE_TEMP;

	# Executa vídeo.
	mplayer -msglevel all=5 \
		-cache 8192 \
		-xy 600 \
		-cookies \
		-cookies-file $FILE_TEMP \
		$(exec $DIR_SRC/youtube-dl \
			-f ${FORMAT:-140} \
			-g \
			--cookies=$FILE_TEMP \
			-i $URL );
	echo $URL;
}


#
# Função para executar PLAYLIST com o mplayer e o youtube-dl.
#
F_PL_PLAYER () {
	# Parametros.
	FORMAT="$1";
	URL="$2";

	# Remove o arquivo temporário para que possa assistir outro vídeo.
	[[ -f $FILE_TEMP ]] && rm $FILE_TEMP;

	# Loop para executar a playlist toda.
	while true; do
		ITEM=$((${ITEM:-0} + 1));

		# Executa vídeo.
		mplayer -msglevel all=5 \
			-cache 8192 \
			-xy 600 \
			-cookies \
			-cookies-file $FILE_TEMP \
			$(exec $DIR_SRC/youtube-dl \
				-f ${FORMAT:-140} \
				-g \
				--cookies=$FILE_TEMP \
				--playlist-items $ITEM \
				-i $URL ) || break;
	done
}



#
# While com as opções.
#
while true; do

	echo -ne "\033]0;ytmp\007"; #Modifica título do terminal.

	read -e -p 'ytmp> ' COMAND; #Entrada de comandos.

	case $(echo $COMAND | cut -d' ' -f1) in  # Case com as opcoes.

		.exit|.quit)
			[[ -f $FILE_TEMP ]] && rm $FILE_TEMP; #Exclui arquivo temporário.
			break;
			;; #Fim do .exit


		.favorite)
			# Favorita o video/audio assistido.

			[[ ! -d $DIR_FAV ]] && mkdir -p $DIR_FAV; #Cria diretorio favoritos caso nao exista.

			echo 'NAME FAVORITE:';
			read -e NAME_FAVORITE;

			if [[ ! -f "$DIR_FAV/$NAME_FAVORITE" ]]; then
				echo "$URL_WATCH" > "$DIR_FAV/$NAME_FAVORITE";
			else
				echo 'ERROR: Name already exist!';
			fi
			;; #Fim do .favorite


		.info)
			# Informações sobre um vídeo.

			INFO_SELECTED=${COMAND##.info };

			SELECTED_URL=$(echo -e "$SOURCE_SEARCH" | cut -d'"' -f1 | sed -n ${INFO_SELECTED}p);
			URL_INFO=$(echo 'https://m.youtube.com'"$SELECTED_URL");

			SOURCE_INFO_WATCH=$(youtube-dl --skip-download --dump-json "$URL_INFO" \
						| json_pp -f json -t json -json_opt pretty,latin1 \
						| grep -e '"title" :' \
							-e '"fulltitle" :' \
							-e '"upload_date" :' \
							-e '"description" :' \
							-e '"like_count" :' \
							-e '"uploader" :' \
							-e '"channel_url" :' \
							-e '"dislike_id" :' \
							-e '"duration" :' \
						| sed "s/,$//g");

			INFO_FULLTITLE=$(echo "$SOURCE_INFO_WATCH" | grep -m1 'fulltitle');
			INFO_TITLE=$(echo "$SOURCE_INFO_WATCH" | grep 'title');
			INFO_DURATION=$(echo "$SOURCE_INFO_WATCH" | grep 'duration');
			INFO_LIKE=$(echo "$SOURCE_INFO_WATCH" | grep 'like_count');
			INFO_DISLIKE=$(echo "$SOURCE_INFO_WATCH" | grep 'dislike_id');
			INFO_UPLOADER=$(echo "$SOURCE_INFO_WATCH" | grep 'uploader');
			INFO_CHANNEL=$(echo "$SOURCE_INFO_WATCH" | grep 'channel_url');
			INFO_UPLOAD_DATE=$(echo "$SOURCE_INFO_WATCH" | grep 'upload_date');
			INFO_DESCRIPTION=$(echo "$SOURCE_INFO_WATCH" | grep 'description');

			echo -e "\n$INFO_FULLTITLE\n$INFO_TITLE\n$INFO_DURATION\n$INFO_LIKE\n$INFO_DISLIKE\n$INFO_UPLOADER\n$INFO_CHANNEL\n$INFO_UPLOAD_DATE\n$INFO_DESCRIPTION";

			;; #Fim do .info

		.help)
			echo '.exit                         Exit this program';
			echo '.favorite                     Favorite watched video/audio';
			echo '.fav_play                     Select one favorite to play';
			echo '.info [number-video]          Show info of the video';
			echo '.help                         Show this message';
			echo '.list                         Mounts a play list';
			echo '.mode audio|video             Set output mode';
			echo '.play [number-video|list]     Play the video';
			echo '.quit                         Exit this programm';
			echo '.repeat_search                Repeat previous search';
			echo '.search                       Search video';
			echo '.msearch                      Search album in music.youtube.com';
			echo '.plsearch                     Search playlist';
			echo '.update                       Update ytmp (Youtube-Dl)';

			;; #Fim do .help

		.list)
			# Monta uma playlist.

			# Seleciona os números das listas.
			WATCH_CHOICE=${COMAND##.list}; # Variável com o número dos vídeos passados.


			#
			# Loop capturando as urls dos vídeos.
			#
			for WATCH_SELECTED in $WATCH_CHOICE; do
				SELECTED_URL=$(echo -e "$SOURCE_SEARCH" | cut -d'"' -f1 | sed -n ${WATCH_SELECTED}p);
				URL_WATCH=$(echo 'https://www.youtube.com'"$SELECTED_URL");
				WATCH_LIST=$(echo "${WATCH_LIST}"' '"${URL_WATCH}");
			done

			;; #Fim do .list


		.mode)
			case ${COMAND##.mode } in
				audio) FORMAT_WATCH='140';; #Formato para m4a --> 140 | worstaudio --> seleciona automatica menor qualidade.
				video) FORMAT_WATCH='best[ext=mp4]';;
				*) echo 'Error: output mode not found';;
			esac

			;; #Fim do .mode


		.play)
			# Reproduz o vídeo escolhido.

			echo -ne "\033]0;Ytmp - Play\007"; # Modifica título do terminal.

			WATCH_CHOICE=${COMAND##.play }; # Variável com o número dos vídeos passados.

			if [[ "$WATCH_CHOICE" = "list" ]]; then
				# Executa lista de vídeos de diferentes pesquisas.
			       for WATCH_SELECTED in $WATCH_LIST; do
				       F_PLAYER "$FORMAT_WATCH" "$WATCH_SELECTED";
			       done

		       else # Executa música isoladas de uma mesma pesquisa.

				#
				# Loop com os vídeos selecionados.
				#
				for WATCH_SELECTED in $WATCH_CHOICE; do
					SELECTED_URL=$(echo -e "$SOURCE_SEARCH" | cut -d'"' -f1 | sed -n ${WATCH_SELECTED}p);

					if [[ $CALL_BY = '1' ]]; then # Chamado pela pesquisa video comum.
						#URL_WATCH=$(echo 'https://www.youtube.com'"$SELECTED_URL");

						# Chama função para executar vídeo.
						#F_PLAYER "$FORMAT_WATCH" "$URL_WATCH";
						F_PLAYER "$FORMAT_WATCH" "$SELECTED_URL";
					fi

					if [[ $CALL_BY = '3' ]]; then  # Chamado pelo playlist.
						F_PL_PLAYER "$FORMAT_WATCH" "$SELECTED_URL";
					fi

				done #Fim do loop que executa os vídeos selecionados.
			fi #Fim do if que seleciona lista ou música isolada.

			;; #Fim do .play


		.fav_play)
			# Abre escolha de video/audio favoritos e o reproduz.

			FAV_FILES=$(ls -1 $DIR_FAV/ | cat -n); #Captura os nomes dos favoritos.

			#
			# Ambiente para escolha do favorito.
			#
			echo '* FAVORITES *';
			echo "$FAV_FILES";
			echo 'Select favorite:';
			read -e FAV_CHOICE;


			echo -ne "\033]0;Ytmp - Play\007"; # Modifica título do terminal.


			#
			# Loop com os vídeos selecionados.
			#
			for WATCH_SELECTED in $FAV_CHOICE; do
				SELECTED_FAV=$(echo -e "$FAV_FILES" | cut -f2 | sed -n ${WATCH_SELECTED}p);
				URL_WATCH_FAV=$(cat $DIR_FAV/$SELECTED_FAV);

				# Chama função para executar vídeo.
				F_PLAYER "$FORMAT_WATCH" "$URL_WATCH_FAV";

			done #Fim do loop que executa os vídeos selecionados.

			;; #Fim do .fav_play


		.repeat_search)
			# Repete a pesquisa anterior.

			echo -e "$SOURCE_SEARCH" | cut -d'"' -f2 | cat -n; # Mostra os títulos do resultado para o usuário.

			;; #Fim do .reply

		.search)
			# Pesquisa comum de vídeos.

			SEARCH=${COMAND##*.search }; # Captura os termos da pesquisa.
			while true; do   # Loop ate encontrar resultado.
				SOURCE_SEARCH=$(lynx -source 'https://youtube.com/results?search_query='${SEARCH// /+}'&sp=EgIQAQ%253D%253D' \
					| grep 'class="yt-lockup-content"' \
					| sed "s/>/>\n/g" \
					| grep '<a href="/watch?' \
					| cut -d'"' -f2,8 \
					| iconv -c -f UTF-8 -t ISO-8859-1); # Captura os resultados da pesquisa (link"título).

				if [[ ! -z $SOURCE_SEARCH ]]; then
					echo -e "$SOURCE_SEARCH" | cut -d'"' -f2 | cat -n; # Mostra os títulos do resultado para o usuário.
					break;
				fi
			done
			CALL_BY='1'

			;; #Fim do .search

		.plsearch)
			# Pesquisa de playlists.

			SEARCH=${COMAND##*.plsearch }; # Captura os termos da pesquisa.
			while true; do   # Loop ate encontrar resultado.
				SOURCE_SEARCH=$(lynx -source 'https://youtube.com/results?search_query='${SEARCH// /+}'&sp=EgIQAw%253D%253D' \
					| sed "s/:{\"playlistId\"/\n_AQUI_/g" \
					| grep "^_AQUI_" \
					| cut -d'"' -f2,8 \
					| iconv -c -f UTF-8 -t ISO-8859-1); # Captura os resultados da pesquisa (link"título).

				if [[ ! -z $SOURCE_SEARCH ]]; then
					echo -e "$SOURCE_SEARCH" | cut -d'"' -f2 | cat -n; # Mostra os títulos do resultado para o usuário.
					break;
				fi
			done

			CALL_BY='3';

			;; #Fim do .plsearch


		.msearch)
			# Pesquisa albums de musicas no music.youtube.com.

			SEARCH=${COMAND##*.msearch }; # Captura os termos da pesquisa.

			TERM=$(echo "$SEARCH" | tr ' ' '+');
			FILE_TEMP=/tmp/ytmp.msearch.a;
			FILE_SEARCH_TEMP=/tmp/ytmp.msearch.b;
			URL_BEGIN_YOUTUBE='https://music.youtube.com/playlist?list=';


			KEY=$(curl -s 'https://music.youtube.com/search?q='$TERM \
				-H 'User-Agent: Mozilla/5.0 (X11; Linux i686; rv:68.0) Gecko/20100101 Firefox/68.0' \
				-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
				-H 'Accept-Language: en-US,en;q=0.5' \
				--compressed \
				-H 'DNT: 1' \
				-H 'Connection: keep-alive' \
				-H 'Cookie: VISITOR_INFO1_LIVE=VKMVHnbD634; YSC=-NlVBOqKb0k; PREF=volume=100' \
				-H 'Upgrade-Insecure-Requests: 1' \
				-H 'TE: Trailers' \
				| tr ',' \\n \
				| grep innertube_api_key \
				| cut -d'"' -f4);


			curl -s 'https://music.youtube.com/youtubei/v1/search?alt=json&key='$KEY \
				-H 'User-Agent: Mozilla/5.0 (X11; Linux i686; rv:68.0) Gecko/20100101 Firefox/68.0' \
				-H 'Accept: */*' \
				-H 'Accept-Language: en-US,en;q=0.5' \
				--compressed \
				-H 'Content-Type: application/json' \
				-H 'X-Goog-Visitor-Id: CgtWS01WSG5iRDYzNCiq3pX2BQ%3D%3D' \
				-H 'X-YouTube-Client-Name: 67' \
				-H 'X-YouTube-Client-Version: 0.1' \
				-H 'X-YouTube-Device: cbr=Firefox&cbrver=68.0&ceng=Gecko&cengver=68.0&cos=X11' \
				-H 'X-YouTube-Page-CL: 312071550' \
				-H 'X-YouTube-Page-Label: youtube.music.web.client_20200518_00_RC01' \
				-H 'X-YouTube-Utc-Offset: -600' \
				-H 'X-YouTube-Time-Zone: Etc/GMT+10' \
				-H 'X-YouTube-Ad-Signals: dt=1590023067734&flash=0&frm&u_tz=-600&u_his=4&u_java&u_h=768&u_w=1366&u_ah=768&u_aw=1366&u_cd=24&u_nplug=1&u_nmime=2&bc=29&bih=423&biw=1366&brdim=0%2C0%2C0%2C0%2C1366%2C0%2C1366%2C747%2C1366%2C423&vis=1&wgl=true&ca_type=image' \
				-H 'DNT: 1' \
				-H 'Connection: keep-alive' \
				-H 'Referer: https://music.youtube.com/search?q='$TERM \
				-H 'Cookie: VISITOR_INFO1_LIVE=VKMVHnbD634; YSC=-NlVBOqKb0k; PREF=volume=100' \
				-H 'Pragma: no-cache' \
				-H 'Cache-Control: no-cache' \
				-H 'TE: Trailers' \
				--data '{"context":{"client":{"clientName":"WEB_REMIX","clientVersion":"0.1","hl":"en","gl":"BR","experimentIds":[],"experimentsToken":"","browserName":"Firefox","browserVersion":"68.0","osName":"X11","utcOffsetMinutes":-600,"locationInfo":{"locationPermissionAuthorizationStatus":"LOCATION_PERMISSION_AUTHORIZATION_STATUS_UNSUPPORTED"},"musicAppInfo":{"musicActivityMasterSwitch":"MUSIC_ACTIVITY_MASTER_SWITCH_INDETERMINATE","musicLocationMasterSwitch":"MUSIC_LOCATION_MASTER_SWITCH_INDETERMINATE","pwaInstallabilityStatus":"PWA_INSTALLABILITY_STATUS_UNKNOWN"}},"capabilities":{},"request":{"internalExperimentFlags":[{"key":"force_music_enable_outertube_playlist_detail_browse","value":"true"},{"key":"force_music_enable_outertube_music_queue","value":"true"},{"key":"force_music_enable_outertube_search_suggestions","value":"true"},{"key":"force_music_enable_outertube_tastebuilder_browse","value":"true"}],"sessionIndex":{}},"clickTracking":{"clickTrackingParams":"IhMI35Kf3IHD6QIVGmuRCh3nGgXkMghleHRlcm5hbA=="},"activePlayers":{},"user":{"enableSafetyMode":false}},"query":"'"$SEARCH"'"}' > $FILE_TEMP;


			awk '/"text": "|"playlistId": "/' $FILE_TEMP \
				| awk '/"text": "Albums"/,/"text": "Show all"/' \
				| awk '!/"Start radio"/' \
				| awk '!/"Shuffle play"/' \
				| awk '!/"Add album to library"/' \
				| awk '!/"Save this for later"/' \
				| awk '!/"Add favorites to your library after signing in"/' \
				| awk '!/"Sign in"/' \
				| awk '!/"Remove album from library"/' \
				| awk '!/"Play next"/' \
				| awk '!/"Album will play next"/' \
				| awk '!/"Add to queue"/' \
				| awk '!/"Album added to queue"/' \
				| awk '!/"Go to artist"/' \
				| awk '!/"Add to playlist"/' \
				| awk '!/"Make playlists and share them after signing in"/' \
				| awk '!/"Share"/' \
				| awk '!/"Show all"/' \
				| awk '!/"Albums"/' \
				| awk '!/"Songs"/' \
				| awk '!/"Playlists"/' \
				| awk '!/"Videos"/' \
				| awk '!/"Artists"/' \
				| awk '/"text"|",$/' \
				| awk '!/"RDAMPL/' \
				| uniq -u \
				| cut -d'"' -f2- \
				| tr '\n' ' ' \
				| sed "s/\",/\n/g" \
				| cut -d':' -f2- \
				| sed 's/ text": "/-- (/' \
				| sed 's/" text": "/-/' \
				| sed 's/" text": "/-/' \
				| sed 's/" playlistId": "/)#/' \
				| tr '"' ' ' > $FILE_SEARCH_TEMP;


			# Imprime os albuns encontrados.
			echo 'Result msearch:';
			cat -n $FILE_SEARCH_TEMP | cut -d'#' -f1;

			# Captura a url do album escolhido.
			read -e -p 'choice: ' CHOICE_ALBUM;
			URL_ALBUM=$(cat $FILE_SEARCH_TEMP | sed -n ${CHOICE_ALBUM}p | cut -d'#' -f2-); 


			# Chama função para executar o album.
			F_PLAYER "$FORMAT_WATCH" "${URL_BEGIN_YOUTUBE}${URL_ALBUM}";

			;; #Fim do .msearch


		.install|.update)
			# Install/Update do Youtube-dl.

			if [[ $(bash-4.3$ type -a python > /dev/null 2>&1; echo $?) -eq 1 ]]; then  # Verifica se o usuario tem o python instalado.
				echo 'ERROR: Python not installed!';
				exit 1;
			fi

			curl -# -L https://yt-dl.org/downloads/latest/youtube-dl -o $DIR_SRC/youtube-dl;  # Baixa para o diretorio do ytmp.
			
			chmod 0755 $DIR_SRC/youtube-dl; # Da permissao de execucao ao arquivo.

			;; #Fim do .update
			
		*)
			echo 'Error: command not found';

			;; #Fim do *
	esac
done

# Modifica título do terminal.
echo -ne "\033]0;Thanks for flying ytmp\007"; 
	
exit
