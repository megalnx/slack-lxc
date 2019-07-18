#
# William PC, Seattle - US, 2019
#

CTNAME=Slackware
LOGPATH=~/log/lxc-slack-it
ARCHS="x86 x86_64"
RELEASE="13.37 14.0 14.1 14.2"
LXCPATH=/var/lib/lxc/slack-it/slackbuilds

IFNET=eth0-nat

[ ! -d $LOGPATH ] && mkdir -p $LOGPATH

function deploy(){
  echo "-> Creating container $1"
  arch=$ARCH release=$rv lxc-create -P $LXCPATH -t slackware -n $1 > $LOGPATH/lxc-$(echo $1 | tr [:upper:] [:lower:])\_deploy.log
  mkdir -p $LXCPATH/$1/rootfs/root/Downloads
  mkdir -p $LXCPATH/$1/rootfs/root/Public
}

function configure(){
  SLACKPKGCFG=/etc/slackpkg/slackpkg.conf
  macaddr=$(echo $(date)|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')

  grep "lxc.network." $LXCPATH/$1/config
  if [ $? == "1" ]; then
echo "lxc.network.0.type = veth
lxc.network.0.flags = up
lxc.network.0.name = $IFNET
lxc.network.0.link = virbr0
lxc.network.0.hwaddr = $macaddr" >> $LXCPATH/$1/config
  fi
  
  grep "lxc.mount.entry" $LXCPATH/$1/config
  if [ $? == "1" ]; then
    echo "lxc.mount.entry = /var/lib/lxc/slack-it/Downloads  root/Downloads  none rw,bind   0  0" >> $LXCPATH/$1/config
    echo "lxc.mount.entry = /var/lib/lxc/slack-it/Public  root/Public  none rw,bind   0  0" >> $LXCPATH/$1/config
  fi

  sed -i 's/BATCH=off/BATCH=on/' $LXCPATH/$1/rootfs/$SLACKPKGCFG
  sed -i 's/DEFAULT_ANSWER=n/DEFAULT_ANSWER=y/' $LXCPATH/$1/rootfs/$SLACKPKGCFG

  cp -av /usr/local/sbin/slackbuild-management.sh $LXCPATH/$1/rootfs/usr/local/sbin
  echo "SLACKWARE_VERSION=$rv" > $LXCPATH/$1/rootfs/root/slackbuilds.conf
  
  grep "dhcpcd $IFNET" $LXCPATH/$1/rootfs/etc/rc.d/rc.local
  if [ $? == "1" ]; then
    echo "dhcpcd $IFNET" >> $LXCPATH/$1/rootfs/etc/rc.d/rc.local
  fi
  sleep 1
}

function finstall(){
  LOGFILE=lxc-$(echo $1 | tr [:upper:] [:lower:])\_install.log
  echo "Starting container $1"
  lxc-start -P $LXCPATH -n $1; sleep 2
  lxc-attach -P $LXCPATH -n $1 -- dhcpcd eth0-nat
  lxc-attach -P $LXCPATH -n $1 -- slackpkg update > $LOGPATH/$LOGFILE
  lxc-attach -P $LXCPATH -n $1 -- slackpkg install slackware$SLACKNAME >> $LOGPATH/$LOGFILE
}


function ctmanage(){
for rv in $RELEASE; do
  for arch in $ARCHS; do
    case "$arch" in
      x86) ARCH=i486; SLACKNAME="" ;;
      x86_64) ARCH=x86_64; SLACKNAME="64" ;;
       *) echo "Unkown arch"; exit;;
    esac    
    $1 $CTNAME$SLACKNAME-$rv
   done
  done
}

echo "Deploy Slackware containers"
#ctmanage deploy

echo "Configuring containers"
#ctmanage configure
sleep 1; lxc-ls -P $LXCPATH -f; sleep 3

echo "Install full package series"
ctmanage finstall
sleep 1; lxc-ls -P $LXCPATH -f; sleep 3

