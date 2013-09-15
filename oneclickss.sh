#!/bin/bash
# Script function : One click to install shadowscoks.
# Original author : yoo@yoo.hk
# Tested on Ubuntu 12.04 64bit



PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
LANG=C

export PATH
export LANG


default()
{
	server_ip="0.0.0.0"
	server_port="8388"
	password="barfoo!"
	local_port="1080"
	method="aes-256-cfb"
	timeout="600"
}

valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=$ip
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

interactive()
{
	while true; do
		read -p "server_ip:(Default is 0.0.0.0, press return to use)" ip 
		if valid_ip $ip; then
			server_ip=ip; 
		else  
			echo "bad ip";
		fi
	done
		

	while true; do
		read -p "server_port:(Default is 8388, press return to use)" s_port
		if [ $s_port=[0-9]{1,} ]; then
			server_port=s_port
		else
			echo "bad server_port"
		fi
	done


	while true; do
		read -p "password:(Default is barfoo!, press return to use" password
	done


	while true; do
		read -p "local_port:(Default is 1080, press return to use)" l_port
		if [ $l_port=[0-9]{1,} ]; then
			local_port=l_port
		else
			echo "bad local_port"
		fi
	done


	echo "select method:"
	select method in "aes-256-cfb" "aes-192-cfb" "aes-128-cfb" "bf-cfb" "camellia-256-cfb" "camellia-192-cfb" "camellia-128-cfb" "cast5-cfb" "cast5-cfb" "idea-cfb" "rc2-cfb" "rc4" "seed-cfb" "table" method
		break;
	done


	while true; do
		read -p "timeout:(Default is 600, press return to use)" t_out
		if [ $t_out=[0-9]{1,} ]; then
			t_out=timeout
			break
		else
			echo "bad timeout"
		fi
	done
}



while [ -n "$1"]; do
	case "$1" in
		*) 	help;;
	esac
done

echo "To install SS"
select var in "Default settings" "Manually" "Nothing"; do
	break;
done
echo "You have selected $var"

case "$var" in
	"Default settings")		default;;
	"Manually")			interactive;;
	"Nothing") 			exit 0;;
esac



command -v unzip 2>&1 >/dev/null || sudo apt-get install -y unzip 2>installss.log || echo "Need Root!!"


if $(uname -m | grep 64 2>&1 >/dev/null); then
  echo "64bit system"
  wget http://nodejs.org/dist/v0.10.17/node-v0.10.17-linux-x64.tar.gz
else
  echo "32bit system"
  wget http://nodejs.org/dist/v0.10.17/node-v0.10.17-linux-x32.tar.gz
fi
  
wget https://raw.github.com/kellyschurz/oneclicktoss/master/shadowsocks-nodejs-master.zip 

echo "uncompressing..."
tar -zxvf node-v0.10.17-linux-x??.tar.gz 1>/dev/null 2>>installss.log
unzip shadowsocks-nodejs-master.zip 1>/dev/null 2>>installss.log

echo "cleaning..."
rm -rf shadowsocks-nodejs-master.zip node-v0.10.17-linux-x??.tar.gz 2>>installss.log

mv node-v0.10.17-linux-x?? node  2>>installss.log
mv shadowsocks-nodejs-master shadowsocks  2>>installss.log

config_file=$(pwd)/shadowsocks/config.json
echo "Your config file path is $config_file"


sed "s/127\.0\.0\.1/$server_ip/" -i $config_file


sed "s/8388/$server_port/" -i $config_file
echo "Your server port is $server_port"

sed "s/barfoo\!/$password/" -i $config_file
echo "Your password is $password"


runss="$(pwd)/node/bin/node $(pwd)/shadowsocks/bin/ssserver > /dev/null 2>&1 &"

sudo sed  "/^exit/i $runss" -i /etc/rc.local

sudo /etc/rc.local

echo "DONE"


