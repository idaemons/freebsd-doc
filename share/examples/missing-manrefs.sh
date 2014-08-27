#!/bin/sh
#-
# Copyright (c) 2014 The FreeBSD Foundation
# All rights reserved.
#
# This software was developed by Glen Barber under sponsorship
# from the FreeBSD Foundation.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $FreeBSD$
#

# Creates an output directory and an obj/ directory,
# builds the manual pages from the specified src/ tree,
# installs to the output directory, and checks the results
# against man-refs.ent.
#

PATH="/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin"
export PATH

docs=${1}
srcs=${2}
sects=$(seq 1 9)

usage() {
	echo "Usage:"
	echo "${0} <docs_tree> <src_tree>"
	exit 1
}

if [ -z "${docs}" -o -z "${srcs}" ]; then
	usage
fi

outdir=$(mktemp -d /tmp/manrefresh.outdir.XXXXXX)
objdir=$(mktemp -d /tmp/manrefresh.objdir.XXXXXX)

build_manpages() {
	MAKEOBJDIRPREFIX=${objdir}
	export MAKEOBJDIRPREFIX
	make -s -C ${srcs} DESTDIR=${outdir} \
		SRCCONF=/dev/null __MAKE_CONF=/dev/null \
		MANOWN=$USER MANGRP=$USER MANMODE=0666 \
		NO_MLINKS=1 obj hier all-man maninstall
}

build_cleanup() {
	make -s -C ${srcs} DESTDIR=${outdir} \
		SRCCONF=/dev/null __MAKE_CONF=/dev/null \
		NO_MLINKS=1 cleandir
}

add_manref() {
	_man=${_m}
	_man=$(echo ${_man} | sed -e 's/\./_/g')
	_man=${_man%%_[0-9]}
	_sec=${_man##*_}
	yes | sh ${docs}/share/examples/add-manref.sh \
		${docs}/share/xml/man-refs.ent ${_man} ${_sec}
}

main() {
	build_manpages
	for sect in ${sects}; do
		cd ${outdir}/usr/share/man/man${sect}
		for _m in $(find . -mindepth 1 -maxdepth 1 -type f | sort); do
			_m=${_m%%\.gz}
			_m=$(echo ${_m} | sed -e 's,\./,,')
			_m=$(echo ${_m} | sed -e 's/_/./g')
			grep -q "man.${_m}" \
				${docs}/share/xml/man-refs.ent \
				|| add_manref ${_m}
		done
	done
	build_cleanup
	rm -vr ${outdir} ${objdir}
}

main "$@"
