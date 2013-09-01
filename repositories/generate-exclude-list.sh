#!/bin/bash
#
# Regenerate exclude list from the skeleton file
#

skel=`dirname $0`/gentoo-portage-exclude.list.skel
out=`sed 's,\.skel,,' <<<${skel}`

echo -n "Generating $out from $skel"

# 0) put DNE header
cat <<EOF >$out
#
# DO NOT EDIT! THIS FILE WAS GENERATED FROM ${skel}
#
EOF

# 1) cat skeleton to a new file
cat $skel >> $out

# 2) append exclude list for metadata/md5-cache/* for every line
# except for profiles/ dir and metadata.xml files
cat ${skel} \
  | grep -v ' eclass/' \
  | grep -v ' licenses/' \
  | grep -v ' profiles/' \
  | grep -v 'metadata.xml' \
  | grep -v '^.*/\*$' \
  | sed 's,\([+\-]\) ,\1 metadata/md5-cache/,' \
  >>$out
