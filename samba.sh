#! /bin/bash 

echo "Pegando nome da maquina"
nome=$(hostname)
sleep 2
echo "Pegando ip da maquina"
ip=$(ifconfig enp2s0 | grep -B1 "inet end" | awk '{ if ( $1 == "inet" ) {print $3} }')
sleep 2
read -p "Insira a url : " -i site;
echo "Guardando a url"
sleep 2
echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts
echo $ip" "$nome"."$site" "$nome >> /etc/hosts
apt-get -y install samba krb5-user winbind smbclient ldap-utils acl attr ntp
echo "Configurando tudo para você"
echo "#" Relogio Local >> /etc/ntp.conf
echo server 127.127.1.0 >> /etc/ntp.conf
echo fudge 127.127.1.0 stratum 10 >> /etc/ntp.conf
echo "#"Configurações adicionais para o Samba 4 >> /etc/ntp.conf
echo ntpsigndsocket /var/lib/samba/ntp_signd/ >> /etc/ntp.conf
echo restrict default mssntp >> /etc/ntp.conf
echo disable monitor >> /etc/ntp.conf
systemctl restart ntp
systemctl stop nmbd
systemctl stop winbind
mv /etc/samba/smb.conf /etc/samba/smb.conf.old

samba-tool domain provision --use-rfc2307 --interactive

/etc/init.d/samba-ad-dc restart

echo address $ip >> /etc/network/interfaces
echo dns-nameservers $ip >> /etc/network/interfaces
echo dns-search $site >> /etc/network/interfaces
sleep 10





