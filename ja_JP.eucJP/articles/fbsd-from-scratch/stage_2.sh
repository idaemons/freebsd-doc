#!/bin/sh
#
# stage_2.sh - FreeBSD From Scratch, �� 2 �ʳ�: ports �Υ��󥹥ȡ���
#              �Ȥ���: ./stage_2.sh
#
# $FreeBSD$
# Original revision: 1.1

DBDIR=/var/db/pkg
PORTS=/usr/ports
LOGDIR=/home/root/setup/ports.log; mkdir -p ${LOGDIR}

# ʣ���� port �ǻ��Ѥ����Ķ��ѿ�������
PAPERSIZE=a4;    export PAPERSIZE
USA_RESIDENT=NO; export USA_RESIDENT

MYNAME=$(basename $0)
usage () {
	exec >&2
	echo "usage: ${MYNAME} [-hn]"
	echo ""
	echo "  Options:"
	echo "  -h    Print this help text."
	echo "  -n    Dryrun: just show what would be done."
	echo ""
	exit 1
}

args=`getopt hn $*`
if test $? != 0; then
	usage
fi
set -- $args
DRYRUN=
for i; do
	case "$i" in
	-n) DRYRUN=yes;;
	--) break;;
	*) usage;;
	esac
done

cat << EOF |
lang perl5
security sudo
x11-servers XFree86-4-Server
x11 wrapper
x11 XFree86-4-libraries
x11 XFree86-4-clients
x11-fonts XFree86-4-font75dpi
x11-fonts XFree86-4-font100dpi
x11-fonts XFree86-4-fontScalable
x11-fonts urwfonts
x11-fonts webfonts
x11-toolkits open-motif
x11 rxvt
x11-wm ctwm
security openssh-askpass
astro xplanet
astro setiathome make BATCH=yes install
astro xephem
editors vim
print ghostscript-gnu make A4=yes BATCH=yes install
print a2ps-a4
print psutils-a4
print gv
print acroread5
print transfig
archivers zip
archivers unzip
java linux-sun-jdk13 yes | make install
java jdk13
www apache2
www weblint
www amaya
www mozilla make WITHOUT_MAILNEWS=yes WITHOUT_CHATZILLA=yes install
www netscape48-navigator
www checkbot
www privoxy
graphics xfig
graphics xv
graphics fxtv
lang expect
news tin
net freebsd-uucp
net cvsup-without-gui
net pathchar make NO_CHECKSUM=yes install
ftp wget
ftp ncftp3
textproc ispell
german ispell-neu
german ispell-alt
textproc docproj make JADETEX=yes HAVE_MOTIF=yes install
sysutils samefile
sysutils pstree
sysutils mkisofs
sysutils cdrtools
sysutils grub
devel ddd
devel ctags
devel ElectricFence
mail procmail make BATCH=yes install
mail metamail
mail mutt
mail spamoracle
emulators mtools
sysutils portupgrade
news inn-stable CONFIGURE_ARGS="--enable-uucp-rnews --enable-setgid-inews" make install
misc figlet-fonts
textproc gmat
EOF
while read CATEGORY NAME CMD; do
	case "${CATEGORY}" in
	\#*) continue;;
	'') continue;;
	esac
	DIR="${PORTS}/${CATEGORY}/${NAME}"
	if ! test -d "${DIR}"; then
		echo "$DIR does not exist -- ignored"
		continue
	fi
	cd ${DIR}
	PKGNAME=`make -V PKGNAME`
	if test -d "${DBDIR}/${PKGNAME}"; then
		echo "${CATEGORY}/${NAME} already installed as ${PKGNAME}"
		continue
	fi
	LOG="${LOGDIR}/${CATEGORY}+${NAME}"
	echo "===> Installing ${CATEGORY}/${NAME}; logging to ${LOG}"
	test -n "${CMD}" || CMD="make install"
	if test -n "${DRYRUN}"; then
		echo "${CMD}"
		continue
	fi
	date "++++++++++ %v %T +++++++++" > ${LOG}
	echo "CMD: ${CMD}" >> ${LOG}
	(
		make clean
		eval "${CMD}"
		# make clean # ${PORTS} �ʲ��Υǥ��������̤������ʤ���Х����Ȥ�Ϥ���
	) 2>&1 | tee -a ${LOG}
done

# StarOffice �ϡ�X11 ��Ȥä�����Ū���󥹥ȡ��뤬ɬ�פʤΤǡ�
# �Ť������ƥ��� "make package" ��¹Ԥ��ƺ�������
# package ���饤�󥹥ȡ��뤹�롣
#pkg_add ${PORTS}/editors/staroffice52/staroffice-*.tbz

# EOF $RCSfile: stage_2.sh,v $    vim: tabstop=4:
