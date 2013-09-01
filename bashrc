#!/bin/bash
#
# Configure environment for paludis
#

CHOST="x86_64-pc-linux-gnu"
# -flto=jobserver -floop-parallelize-all
CFLAGS="-march=native -O2 -ggdb -pipe -ftree-vectorize -fmerge-all-constants -minline-stringops-dynamically -mtls-dialect=gnu2"
CXXFLAGS="${CFLAGS}"
LDFLAGS="-Wl,-O1 -Wl,--sort-common -Wl,--as-needed -Wl,--gc-sections -Wl,--hash-style=gnu"
MAKEOPTS="-j4"
# Reduce SPAM from cmake based builds
CMAKE_VERBOSE=OFF

SKIP_FUNCTIONS="test"

# Tuning compiler options for various ebuilds
case "${PN}" in
    binutils)
        einfo "Enable ld.gold linker"
        EXTRA_ECONF="--enable-gold-default"
        ;;&
    glibc|grub|cairo)
        einfo "Remove --gc-sections linker option"
        LDFLAGS=`sed -e 's/ -Wl,--gc-sections//' -e 's/ -Wl,--print-gc-sections//' <<<${LDFLAGS}`
        ;;&
    pixman)
        einfo "Remove -mtls-dialect=gnu2 from CFLAGS and CXXFLAGS"
        CFLAGS=`sed -e 's/ -mtls-dialect=gnu2//' <<<${CFLAGS}`
        CXXFLAGS="${CFLAGS}"
        ;;&
    glibc|grub)
        einfo "Setting --hash-style=both linker option"
        LDFLAGS=`sed -e 's/ --hash-style=gnu/--hash-style=both/' <<<${LDFLAGS}`
        ;;&
    # -O3 safe packets (i.e. being compiled with -O3 will works really faster)
    python|sqlite|paludis)
        ewarn "Switch to -O3 optimization..."
        CFLAGS=`sed 's,-O2,-O3,' <<<${CFLAGS}`
        CXXFLAGS="${CFLAGS}"
        ;;&
esac

# Detect terminal width dynamically for better [ ok ] align
save_COLUMNS=${COLUMNS}
COLUMNS=$(stty size 2>/dev/null | cut -d' ' -f2)
test -z "${COLUMNS}" && COLUMNS=${save_COLUMNS}
unset save_COLUMNS
PALUDIS_ENDCOL=$'\e[A\e['$(( ${COLUMNS:-80} - 7 ))'G'
