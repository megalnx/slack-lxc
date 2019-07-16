
LOGPATH=~/log/lxc-slack-it
RELEASE="13.1 13.37 14.1 14.2"
LXCPATH=/var/lib/lxc/slack-it/slackbuilds

[ ! -d $LOGPATH ] && mkdir -p $LOGPATH

for rv in $RELEASE; do
  echo "Creating container Slackware-$rv"
  arch=i486 release=$rv lxc-create -P $LXCPATH -t slackware -n Slackware-$rv > $LOGPATH/lxc-slackware-$rv\_deploy.log
  arch=x86_64 release=$rv lxc-create -P $LXCPATH -t slackware -n Slackware64-$rv > $LOGPATH/lxc-slackware64-rv\_deploy.log
done

sleep 2; lxc-ls -P $LXCPATH -f; sleep 2

echo "Configuring containers..."
for rv in $RELEASE; do
  macaddr=$(echo $(date)|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')

echo "lxc.network.0.type = veth
lxc.network.0.flags = up
lxc.network.0.name = eth0-nat
lxc.network.0.link = virbr0
lxc.network.0.hwaddr = $macaddr" >> $LXCPATH/Slackware-$rv/config
  sed -i 's/BATCH=off/BATCH=on/' $LXCPATH/Slackware-$rv/rootfs/etc/slackpkg/slackpkg.conf
  sed -i 's/DEFAULT_ANSWER=n/DEFAULT_ANSWER=y/' $LXCPATH/Slackware-$rv/rootfs/etc/slackpkg/slackpkg.conf 

  sed -i 's/BATCH=off/BATCH=on/' $LXCPATH/Slackware64-$rv/rootfs/etc/slackpkg/slackpkg.conf
  sed -i 's/DEFAULT_ANSWER=n/DEFAULT_ANSWER=y/' $LXCPATH/Slackware64-$rv/rootfs/etc/slackpkg/slackpkg.conf  
  sleep 1
done


for rv in $RELEASE; do
  echo "Installing full package series"
  lxc-start -P $LXCPATH -n Slackware-$rv
  lxc-attach -P $LXCPATH -n Slackware-$rv -- slackpkg install slackware
  lxc-start -P $LXCPATH -n Slackware64-$rv
  lxc-attach -P $LXCPATH -n Slackware64-$rv -- slackpkg install slackware64
done


