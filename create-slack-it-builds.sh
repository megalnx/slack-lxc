
LOGPATH=~/log/lxc-slack-it
RELEASE="13.1 13.37 14.1 14.2"
LXCPATH=/var/lib/lxc/slack-it/slackbuilds

[ ! -d $LOGPATH ] && mkdir -p $LOGPATH

for rv in $RELEASE; do
  echo "Creating container Slackware-$rv"
  arch=i486 release=$rv lxc-create -P $LXCPATH -t slackware -n Slackware-$rv > $log/lxc-slackware-$rv\_deploy.log
  arch=x86_64 release=$rv lxc-create -P $LXCPATH -t slackware -n Slackware64-$rv > $log/lxc-slackware64-rv\_deploy.log
done



