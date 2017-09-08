#!/bin/bash
loading_down(){
	array[1]=$(echo "\\")
	array[2]=$(echo "|")
	array[3]=$(echo "/")
	array[4]=$(echo "-")
	SPACE="-"
	LIMITE=$(tput cols)
	COLUNA=$((LIMITE - 15))
	INDICE=0
	CONTADOR=0
	PORCENTAGEM2=0

	clear
	while true ; do
	        INDICE=$(echo "$INDICE + 1" | bc) 
	        tput cup 0 0
	        echo "$PORCENTAGEM2% - ["
	        SPACE=$(echo "$SPACE-")
	        tput cup 0 8
	        echo -e "\e[31;1m$SPACE>\e[m\n"
	        tput cup 0 $COLUNA
	        echo "] ${array[$INDICE]} - Modulo de download"
	        sleep 0.01
	        CONTADOR=$( expr 1 + $CONTADOR)
	        if [ $INDICE = 4 ]; then
	        INDICE=0
	        fi
	        TAMANHO2=$( echo $SPACE | wc -c )
	        TAMANHO=$( echo "$TAMANHO2 - 1 " | bc )
	        COLUNA2=$( expr $COLUNA - 9 )
	        [ $TAMANHO -eq $COLUNA2 ] && break
	        TAMANHO3=$(echo "$TAMANHO + 10" | bc)
	        PORCENTAGEM=$(echo "$TAMANHO3 * 100" | bc )
	        PORCENTAGEM2=$(echo "$PORCENTAGEM / $COLUNA" | bc )
	done
}
loading(){
	array[1]=$(echo "\\")
	array[2]=$(echo "|")
	array[3]=$(echo "/")
	array[4]=$(echo "-")
	SPACE="-"
	LIMITE=$(tput cols)
	COLUNA=$((LIMITE - 15))
	INDICE=0
	CONTADOR=0
	PORCENTAGEM2=0

	clear
	while true ; do
	        INDICE=$(echo "$INDICE + 1" | bc) 
	        tput cup 0 0
	        echo "$PORCENTAGEM2% - ["
	        SPACE=$(echo "$SPACE-")
	        tput cup 0 8
	        echo -e "\e[31;1m$SPACE>\e[m\n"
	        tput cup 0 $COLUNA
	        echo "] ${array[$INDICE]} - Salvando"
	        sleep 0.01
	        CONTADOR=$( expr 1 + $CONTADOR)
	        if [ $INDICE = 4 ]; then
	        INDICE=0
	        fi
	        TAMANHO2=$( echo $SPACE | wc -c )
	        TAMANHO=$( echo "$TAMANHO2 - 1 " | bc )
	        COLUNA2=$( expr $COLUNA - 9 )
	        [ $TAMANHO -eq $COLUNA2 ] && break
	        TAMANHO3=$(echo "$TAMANHO + 10" | bc)
	        PORCENTAGEM=$(echo "$TAMANHO3 * 100" | bc )
	        PORCENTAGEM2=$(echo "$PORCENTAGEM / $COLUNA" | bc )
	done
}


#verificação de usuario root
if [ "$(id -u)" = "0" ]; then
	#preparando apt update
	loading_down
	clear
	apt-get update
	clear
	echo "MODULO DE DOWNLOAD CARREGADO"
	sleep 0.5
	#salvando informações necessarias do sistema
	echo "Pegando nome da maquina"
	loading
	nome=$(hostname)
	#intalar ifconfig para ferramentas da interface de rede
	which ifconfig || apt-get -y install net-tools
	ifconfig
	read -p "Insira o ip da interface de rede com ip fixo: " ip
	loading
	clear
	read -p "Insira a url : " site
	loading
	clear
	clear

	#Preparando um mapeamento estatico

	echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts
	echo $ip" "$nome"."${site,,}" "$nome >> /etc/hosts

	#Instalação

	which samba || apt-get -y install samba
	which krb5-user || apt-get -y install krb5-user
	which krb5-config || apt-get -y install krb5-config
	which libpam-winbind || apt-get -y install libpam-winbind
	which libnss-winbind || apt-get -y install libnss-winbind
	which ntp || apt-get -y install ntp
	which ntpdate || apt-get -y install ntpdate
	which ssh || apt-get -y install ssh

	#parando serviços para alteração 

	systemctl stop samba-ad-dc.service smbd.service nmbd.service winbind.service

	mv /etc/samba/smb.conf /etc/samba/smb.conf.initial

	#inicializando o samba

	samba-tool domain provision --use-rfc2307 --interactive

	#Movendo a configuração kerberus

	mv /etc/krb5.conf /etc/krb5.conf.initial

	ln –s /var/lib/samba/private/krb5.conf /etc/

	#inicializando serviço do ad dc

	systemctl start samba-ad-dc.service

	#setando o dns para exibição

	echo "dns-nameservers $ip" >> /etc/network/interfaces
	echo "dns-search ${site,,}" >> /etc/network/interfaces
	
	#reiniciando interface de rede

	/etc/init.d/networking restart


else
	echo "necessario usuario root" 
fi
