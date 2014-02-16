#!/bin/bash
#
# Configure environment for paludis
#

CHOST="x86_64-pc-linux-gnu"
SKIP_FUNCTIONS="test"
MAKEOPTS="-j4"
# Reduce SPAM from cmake based builds
CMAKE_VERBOSE=OFF
# Tell to autotools (if used) not to create useless,
# for one time build, `.d' files, reduce compilation messages
# and use cache for config results
EXTRA_ECONF="--disable-dependency-tracking --enable-silent-rules --cache-file=/var/tmp/config.cache"

# Prepare compiler options (use "predefined" vairables to group them),
# so particular environments may refer them to turn OFF for example...

LTO="-flto=4"
LTO_LD="-fuse-linker-plugin -flto-report"

GRAPHITE="-floop-block -floop-interchange -ftree-loop-distribution -floop-strip-mine -fgraphite-identity -fivopts"
MISC_FLAGS="-fipa-pta"
SOME_O3_FLAGS="-ftree-vectorize -fmerge-all-constants -fira-loop-pressure"
ARCH_FLAGS="-march=native -minline-stringops-dynamically -mtls-dialect=gnu2"

# Suppress useless^W warnings about unused local typedefs appeared for some packages
CXXONLY_FLAGS="-fnothrow-opt -Wno-unused-local-typedefs"

CFLAGS="-O2 -ggdb -pipe ${ARCH_FLAGS} ${GRAPHITE} ${SOME_O3_FLAGS} ${MISC_FLAGS}"
CXXFLAGS="${CFLAGS} ${CXXONLY_FLAGS}"
LDFLAGS="-Wl,-O1 -Wl,--sort-common -Wl,--as-needed -Wl,--enable-new-dtags -Wl,--gc-sections -Wl,--hash-style=gnu"

# Setup per package environment
[ -e /usr/libexec/paludis-hooks/setup_pkg_env.bash ] && source /usr/libexec/paludis-hooks/setup_pkg_env.bash

# Detect terminal width dynamically for better [ ok ] align
save_COLUMNS=${COLUMNS}
COLUMNS=$(stty size 2>/dev/null | cut -d' ' -f2)
test -z "${COLUMNS}" && COLUMNS=${save_COLUMNS}
unset save_COLUMNS
PALUDIS_ENDCOL=$'\e[A\e['$(( ${COLUMNS:-80} - 7 ))'G'
