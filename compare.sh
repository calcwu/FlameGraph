FGDIR=$(dirname "$0")

if [ -z "$*" ]
then
  echo "Usage: compare.sh <file1> <file1>"
  exit 1
fi

file1=$1
file1=$2

if [ ! -f $1 ]; then
  echo "$1 not found!"
  exit 1
fi

if [ ! -f $2 ]; then
  echo "$2 not found!"
  exit 1
fi

echo "Comparing $1 and $2"

for file in $1 $2
do
  cat $file | sed -e 's/\$\$Lambda\$[0-9]\+\/[0-9]\+/\$lambda\$/g' | sed -e 's/\$Proxy[0-9]\+/$Proxy/g' | sed 's/GeneratedMethodAccessor[0-9]\+/GeneratedMethodAccessor/g' | $FGDIR/stackcollapse-jstack.pl --shorten-pkgs --no-include-tname > $file.collapsed
  grep -e 'OnlineImporterImpl.processNotification' -e 'buildMapper' $file.collapsed > $file-work-items.collapsed
#  grep -e 'DataVerificationJob.verifyOnlineAccounts' $file.collapsed > $file-dvj.collapsed

  cat $file-work-items.collapsed | $FGDIR/flamegraph.pl --minwidth=0 > $file-work-items.svg
#  cat $file-dvj.collapsed | $FGDIR/flamegraph.pl --colors=java --minwidth=0 > $file-dvj.svg

done

echo "Diffing $1-work-items.collapsed and $2-work-items.collapsed"
echo "Diffing $1-dvj.collapsed and $2-dvj.collapsed"

$FGDIR/difffolded.pl -n $1-work-items.collapsed $2-work-items.collapsed > diff-work-items.collapsed
#$FGDIR/difffolded.pl -n $1-dvj.collapsed $2-dvj.collapsed > diff-dvj.collapsed

cat diff-work-items.collapsed | $FGDIR/flamegraph.pl --minwidth=0 > diff-work-items.svg
# cat diff-dvj.collapsed | $FGDIR/flamegraph.pl --negate --colors=java --minwidth=0 > diff-dvj.svg

echo "Done!"
