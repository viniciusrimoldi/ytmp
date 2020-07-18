# ytmp
Shell script for play youtube with Youtube-DL + Mplayer.


# Descrição
O projeto mantem um __shellscript__ com funções para ouvir música (principal função) do _youtube.com_. O script apresenta função que permitem pesquisa de músicas, playlists ou mesmo album no _music.youtube.com_ com o __mplayer__ no console linux.


# Por que usar esse script?
O fim mais prático é sua simples linguagem, altamente comentado o que permite uma adequação ao uso particular de cada usuário com a simples edição dos arquivos fonte, sem necessidade de compilação para testes e uso.


# Como instalar o __ytmp__?
Baixe e execute o script __install.sh__ contido no projeto.


# Update do __ytmp__?
Para baixar a última versão do script, após instalado o __ytmp__, utilize o comando __.update__.


# Usabilidade
Os comando são inspirados no layout e usabiliade de banco de dados como __sqlite__, onde as chamadas de funções nativas contem um "__.__" (ponto final) seguido do nome da função, por exemplo: __.search nome_musica__.

Ajuda/Listagem de funções pode ser consultado pelo comando: __.help__.


# Comandos básicos
Lista de comando básicos:
- __.help__ --> lista ajuda com todas as funções suportadas.
- __.search__ --> pesquisa música/vídeo no _youtube.com_.
- __.plsearch__ --> pesquisa playlist no _youtube.com_.
- __.masearch__ --> pesquisa álbum no _music.youtube.com_.
- __.play__ --> executa item escolhido da pesquisa.
- __.quit__ --> sai do script.


# Dependências
Dependências presentes para execução do script:
- __youtube-dl__ (<https://ytdl-org.github.io/youtube-dl/index.html>);
- __curl__;
- __lynx__;
- __mplayer__.


# Autor
Vinicius D Sartori Rimoldi (<viniciusrimoldii@gmail.com>).

# Licença
GpL-v3


# Bugs e sugestões
Favor enviar bugs ou sugestões para o email do mantenedor (<viniciusrimoldii@gmail.com>).


# OBS:
O mantenedor não se responsabiliza pelo uso indevido do script com fins de download de vídeos propretários do _youtube.com_ ou _music.youtube.com_. Sendo responsabilidade de uso consciente do próprio usuário.
