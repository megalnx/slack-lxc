LXCPATH=/var/lib/lxc/slack-it/slackbuilds 

lxc-ls -P $LXCPATH -f

if [ "$1" == "poweron" ]; then
  for i in $(lxc-ls -P $LXCPATH --stopped); do
    echo "Poweron $i"
    lxc-start -P $LXCPATH $i
  done
elif [ "$1" == "poweroff" ]; then
  for i in $(lxc-ls -P $LXCPATH --running); do
    echo "Poweroff $i"
    lxc-stop -P $LXCPATH $i
  done
fi

