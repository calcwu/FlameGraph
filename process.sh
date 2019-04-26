#!/usr/bin/env bash
FGDIR=$(dirname "$0")

if [ ! -f $1 ]; then
  echo "$1 not found!"
  exit 1
fi

file=$1
echo "Processing $file"

FLAME_GRAPH_OPTIONS="--colors=java --minwidth=0"

cat $file | sed -e 's/\$\$Lambda\$[0-9]\+\/[0-9]\+/\$lambda\$/g' | sed -e 's/\$Proxy[0-9]\+/$Proxy/g' | sed 's/GeneratedMethodAccessor[0-9]\+/GeneratedMethodAccessor/g'| $FGDIR/stackcollapse-jstack.pl --shorten-pkgs --no-include-tname > $file.collapsed
cat $file.collapsed | $FGDIR/flamegraph.pl $FLAME_GRAPH_OPTIONS > $file.svg

grep -e 'AssetsController.saveNodes' $file.collapsed | $FGDIR/flamegraph.pl $FLAME_GRAPH_OPTIONS > $file-save-nodes.svg
grep -e 'OnlineImporterImpl.importByNotification' $file.collapsed | $FGDIR/flamegraph.pl $FLAME_GRAPH_OPTIONS > $file-import.svg

perl -pe 's/.*?c.a.s.g.NewFinancialGraphManager.performGraphWriteOperation/GRAPH_WRITE/' $file.collapsed | grep GRAPH_WRITE | $FGDIR/flamegraph.pl $FLAME_GRAPH_OPTIONS > $file-graph-writes.svg
perl -pe 's/.*?c.a.s.g.NewFinancialGraphManager.performGraphWriteOperation/GRAPH_WRITE/' $file.collapsed | grep GRAPH_WRITE | grep writeOperationInternal | $FGDIR/flamegraph.pl $FLAME_GRAPH_OPTIONS > $file-inside-graph-writes.svg

# for HOST in "$@"
# do
#   cat $HOST.raw | sed -e 's/\$\$Lambda\$[0-9]\+\/[0-9]\+/\$lambda\$/g' | sed -e 's/\$Proxy[0-9]\+/$Proxy/g' | sed 's/GeneratedMethodAccessor[0-9]\+/GeneratedMethodAccessor/g' | $FGDIR/stackcollapse-jstack.pl --no-include-tname > $HOST.collapsed

  # cat $HOST.collapsed | $FGDIR/flamegraph.pl --colors=java --minwidth=0 > $HOST.svg
  # cat $HOST.collapsed | $FGDIR/flamegraph.pl --colors=java --minwidth=0 --inverted --reverse > $HOST-inverted.svg
  #
  # grep -e 'OnlineImporterImpl.processNotification' -e 'buildMapper' $HOST.collapsed | $FGDIR/flamegraph.pl --colors=java --minwidth=0 > $HOST-work-items.svg
  # grep -e 'OnlineImporterImpl.processNotification' -e 'buildMapper' $HOST.collapsed | $FGDIR/flamegraph.pl --colors=java --minwidth=0 --inverted --reverse > $HOST-work-items-inverted.svg
  #
  # grep -e 'snapshots' $HOST.collapsed | $FGDIR/flamegraph.pl --colors=java --minwidth=0 > $HOST-snapshots.svg
  # grep -e 'snapshots' $HOST.collapsed | $FGDIR/flamegraph.pl --colors=java --minwidth=0 --inverted --reverse > $HOST-snapshots-inverted.svg
  #
  # perl -pe 's/.*?com.addepar.services.graph.NewFinancialGraphManager.performGraphWriteOperation/GRAPH_WRITE/' $HOST.collapsed | grep GRAPH_WRITE | $FGDIR/flamegraph.pl --colors=java --minwidth=0 > $HOST-graph-writes.svg
  # perl -pe 's/.*?com.addepar.services.graph.NewFinancialGraphManager.performGraphWriteOperation/GRAPH_WRITE/' $HOST.collapsed | grep GRAPH_WRITE | $FGDIR/flamegraph.pl --colors=java --minwidth=0 --inverted --reverse > $HOST-graph-writes-inverted.svg
  #
  # perl -pe 's/.*?com.addepar.services.graph.NewFinancialGraphManager.performGraphWriteOperation/GRAPH_WRITE/' $HOST.collapsed | grep GRAPH_WRITE | grep writeOperationInternal | $FGDIR/flamegraph.pl --colors=java --minwidth=0 > $HOST-inside-graph-writes.svg
  # perl -pe 's/.*?com.addepar.services.graph.NewFinancialGraphManager.performGraphWriteOperation/GRAPH_WRITE/' $HOST.collapsed | grep GRAPH_WRITE | grep writeOperationInternal | $FGDIR/flamegraph.pl --colors=java --minwidth=0 --inverted --reverse > $HOST-inside-graph-writes-inverted.svg

# done
