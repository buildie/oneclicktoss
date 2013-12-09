#!/bin/bash
# Script function : One click to install shadowscoks.
# Original author : yoo@yoo.hk
# Tested on Ubuntu 12.04 32bit



PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
LANG=C

export PATH
export LANG

SERVERPORT=$1
PASSWORD=$2

if [ $# -ne 2 ];then
echo "using default settings"
SERVERPORT=2000
PASSWORD="Philosophy"
fi


command -v unzip 2>&1 >/dev/null || sudo apt-get install -y unzip 2>installss.log || echo "Need Root!!"


if $(uname -m | grep 64 2>&1 >/dev/null); then
  echo "64bit system"
  wget http://nodejs.org/dist/v0.10.22/node-v0.10.22-linux-x64.tar.gz
else
  echo "32bit system"
  wget http://nodejs.org/dist/v0.10.22/node-v0.10.22-linux-x86.tar.gz
fi
  
wget https://github.com/clowwindy/shadowsocks-nodejs/archive/master.zip

node_zip=$(ls | grep node-v*-linux-x??.tar.gz)


echo "uncompressing..."
tar -zxvf $node_zip 1>/dev/null 2>>installss.log
unzip master.zip 1>/dev/null 2>>installss.log

echo "cleaning..."
rm -rf master.zip  $node_zip 2>>installss.log

mv  node-v0.10.22-linux-x86 node  2>>installss.log || mv  node-v0.10.22-linux-x64 node  2>>installss.log
mv shadowsocks-nodejs-master shadowsocks  2>>installss.log

CONFIGFILE=$(pwd)/shadowsocks/config.json
echo "Your config file path is $CONFIGFILE"

SERVERIP="0.0.0.0"
sed "s/127\.0\.0\.1/$SERVERIP/" -i $CONFIGFILE


sed "s/8388/$SERVERPORT/" -i $CONFIGFILE
echo "Your server port is $SERVERPORT"

sed "s/barfoo\!/$PASSWORD/" -i $CONFIGFILE
echo "Your password is $PASSWORD"


RUNSS="$(pwd)/node/bin/node $(pwd)/shadowsocks/bin/ssserver > /dev/null 2>&1 &"

sudo sed  "/^exit/i $RUNSS" -i /etc/rc.local

sudo /etc/rc.local

echo "DONE"
