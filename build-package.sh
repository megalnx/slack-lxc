CTNAME=Slackware
ARCHS="x86 x86_64"
RELEASE="13.37 14.0 14.1 14.2"
LXCPATH=/var/lib/lxc/slack-it/slackbuilds



function slackit_build(){
  lxc-start -P $LXCPATH -n $1
  lxc-attach -P $LXCPATH -n $1 -- slackpkg update
  lxc-attach -P $LXCPATH -n $1 -- slackbuild-management.sh pack $2
}

function ctmanage(){
for rv in $RELEASE; do
  for arch in $ARCHS; do
    case "$arch" in
      x86) ARCH=i486; SLACKNAME="" ;;
      x86_64) ARCH=x86_64; SLACKNAME="64" ;;
       *) echo "Unkown arch"; exit;;
    esac    
    slackit_build $CTNAME$SLACKNAME-$rv $2
   done
  done
}

ctmanage $2
