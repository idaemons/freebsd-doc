#!/bin/sh
#
# stage_1.sh - FreeBSD From Scratch, �� 1 �ʳ�: �����ƥ�Υ��󥹥ȡ���
#              �Ȥ���: ./stage_1.sh
#
# $FreeBSD$
# Original revision: 1.1

set -x -e
PATH=/bin:/usr/bin:/sbin:/usr/sbin

# ����Ȥ���Ķ�:
#
# a) "make buildworld" �� "make buildkernel" ������˽�λ���Ƥ��뤳�ȡ�
# b) ̤���ѥѡ��ƥ�����󤬤��뤳�� (�롼�ȥե����륷���ƥ��Ѥ˾��ʤ��Ȥ� 1 �ġ�
#    ���ߤ˱����� /usr �� /var �ѤΤ�Τ��Ѱդ���)

# �����������ƥ�����������򼨤��롼�ȥޥ���ȥݥ���Ȥ���ꡣ
# �ޥ���ȥݥ���ȤȤ��ƻȤ�������ʤΤǡ��ޥ���ȥݥ���ȤΤ���
# �ե����륷���ƥ�˥ե�������֤��줺���񤭹��ߤϤ��٤ƥޥ���Ȥ���
# �ե����륷���ƥ�˹Ԥʤ��롣
DESTDIR=/newroot
SRC=/usr/src         # src �ĥ꡼�Τ�����

# ---------------------------------------------------------------------------- #
# ���ƥå� 1: $DESTDIR �ʲ��˶��Υǥ��쥯�ȥ�ĥ꡼�����
# ---------------------------------------------------------------------------- #

step_one () {
  # �������롼�ȥե����륷���ƥ��������롣ɬ�ܡ�
  # �ǥХ���̾ (DEV_*) ���ѹ����뤳�ȡ��ѹ����ʤ��ȥ����ƥब�������������롣
  DEV_ROOT=/dev/da3s1a
  mkdir -p ${DESTDIR}
  newfs ${DEV_ROOT}
  tunefs -n enable ${DEV_ROOT}
  mount -o noatime ${DEV_ROOT} ${DESTDIR}

  # ����¾�Υե����륷���ƥ�Ƚ���ޥ���ȥݥ���ȡ����ץ����
  DEV_VAR=/dev/vinum/var_a
  newfs ${DEV_VAR}
  tunefs -n enable ${DEV_VAR}
  mkdir -m 755 ${DESTDIR}/var
  mount -o noatime ${DEV_VAR} ${DESTDIR}/var

  DEV_USR=/dev/vinum/usr_a
  newfs ${DEV_USR}
  tunefs -n enable ${DEV_USR}
  mkdir -m 755 ${DESTDIR}/usr
  mount -o noatime ${DEV_USR} ${DESTDIR}/usr

  mkdir -m 755 -p ${DESTDIR}/usr/ports
  mount /dev/vinum/ports ${DESTDIR}/usr/ports

  # ������¾�Τ��٤ƤΥǥ��쥯�ȥ�������ɬ�ܡ�
  cd ${SRC}/etc; make distrib-dirs DESTDIR=${DESTDIR}
  # �Ŀ�Ū�ˤ� tmp -> var/tmp �ȥ���ܥ�å���󥯤�ĥ��Τ����ߡ����ץ����
  cd ${DESTDIR}; rmdir tmp; ln -s var/tmp
}

# ---------------------------------------------------------------------------- #
# ���ƥå� 2: /etc �ǥ��쥯�ȥ�ĥ꡼�� / �˥ե�������ɲ�
# ---------------------------------------------------------------------------- #

step_two () {
  # ���ߤ˱����ơ����Υꥹ�Ȥ��ɲá�������뤳�ȡ��ۤȤ�ɤξ���ɬ�ܡ�
  for f in \
    /.profile \
    /etc/group \
    /etc/hosts \
    /etc/inetd.conf \
    /etc/ipfw.conf \
    /etc/make.conf \
    /etc/master.passwd \
    /etc/nsswitch.conf \
    /etc/ntp.conf \
    /etc/printcap \
    /etc/profile \
    /etc/rc.conf \
    /etc/resolv.conf \
    /etc/start_if.xl0 \
    /etc/ttys \
    /etc/ppp/* \
    /etc/mail/aliases \
    /etc/mail/aliases.db \
    /etc/mail/hal9000.mc \
    /etc/mail/service.switch \
    /etc/ssh/*key* \
    /etc/ssh/*_config \
    /etc/X11/XF86Config-4 \
    /boot/splash.bmp \
    /boot/loader.conf \
    /boot/device.hints ; do
    cp -p ${f} ${DESTDIR}${f}
  done
  # mergemaster �κ�ȥե����뤬����к����
  TEMPROOT=/var/tmp/temproot.stage1
  if test -d ${TEMPROOT}; then
    chflags -R 0 ${TEMPROOT}
    rm -rf ${TEMPROOT}
  fi
  mergemaster -i -m ${SRC}/etc -t ${TEMPROOT} -D ${DESTDIR}
  cap_mkdb ${DESTDIR}/etc/login.conf
  pwd_mkdb -d ${DESTDIR}/etc -p ${DESTDIR}/etc/master.passwd

  # mergemaster �� /var/log ���֤������ե������������ʤ��Τǡ�
  # �����Ǻ�������������Υ롼�פǥ��ԡ�����Ƥ�����ϡ������Ȥ���
  cd ${TEMPROOT}
  find . -type f | sed 's,^\./,,' |
  while read f; do
    if test -r ${DESTDIR}/${f}; then
      echo "${DESTDIR}/${f} already exists; not copied"
    else
      echo "Creating empty ${DESTDIR}/${f}"
      cp -p ${f} ${DESTDIR}/${f}
    fi
  done
  chflags -R 0 ${TEMPROOT}
  rm -rf ${TEMPROOT}
}

# ---------------------------------------------------------------------------- #
# ���ƥå� 3: installworld ��¹Ԥ���
# ---------------------------------------------------------------------------- #

step_three () {
  cd ${SRC}
  make installworld DESTDIR=${DESTDIR}
}

# ---------------------------------------------------------------------------- #
# ���ƥå� 4: �����ͥ�ȥ⥸�塼��򥤥󥹥ȡ��뤹��
# ---------------------------------------------------------------------------- #

step_four () {
  cd ${SRC}
  # installkernel �������åȤˤϡ�loader.conf �� device.hints ��ɬ�ס� 
  # ���ƥå� 2 �ǥ��ԡ����Ƥ��ʤ���С����� 2 �Ԥ�Ȥäƥ��ԡ����뤳�ȡ�
  #   cp sys/boot/forth/loader.conf ${DESTDIR}/boot/defaults
  #   cp sys/i386/conf/GENERIC.hints ${DESTDIR}/boot/device.hints
  make installkernel DESTDIR=${DESTDIR} KERNCONF=HAL9000
}

# ---------------------------------------------------------------------------- #
# ���ƥå� 5: ɬ�ܤΥե�����Υ��󥹥ȡ�����ѹ�
# ---------------------------------------------------------------------------- #

step_five () {
  # /etc/fstab �κ�����ɬ�ܡ���ʬ�ΥǥХ����˹礦�褦���ѹ����뤳�ȡ�
  cat <<EOF >${DESTDIR}/etc/fstab
# Device         Mountpoint          FStype    Options              Dump Pass#
/dev/da3s1b      none                swap      sw                   0    0
/dev/da4s2b      none                swap      sw                   0    0
/dev/da3s1a      /                   ufs       rw                   1    1
/dev/da1s2a      /src                ufs       rw                   0    2
/dev/da2s2f      /share              ufs       rw                   0    2
/dev/vinum/var_a /var                ufs       rw                   0    2
/dev/vinum/usr_a /usr                ufs       rw                   0    2
/dev/vinum/home  /home               ufs       rw                   0    2
/dev/vinum/ncvs  /home/ncvs          ufs       rw,noatime           0    2
/dev/vinum/ports /usr/ports          ufs       rw,noatime           0    2
#
/dev/cd0         /dvd                cd9660    ro,noauto            0    0
/dev/cd1         /cdrom              cd9660    ro,noauto            0    0
proc             /proc               procfs    rw                   0    0
EOF

  # ����¾�Υǥ��쥯�ȥꡣ���ץ����
  mkdir -m 755 -p ${DESTDIR}/src;       chown root:wheel ${DESTDIR}/src
  mkdir -m 755 -p ${DESTDIR}/share;     chown root:wheel ${DESTDIR}/share
  mkdir -m 755 -p ${DESTDIR}/dvd;       chown root:wheel ${DESTDIR}/dvd
  mkdir -m 755 -p ${DESTDIR}/home;      chown root:wheel ${DESTDIR}/home
  mkdir -m 755 -p ${DESTDIR}/usr/ports; chown root:wheel ${DESTDIR}/usr/ports
  # �����ॾ��������ꡣ�ۤȤ�ɤξ���ɬ�ܡ�
  cp ${DESTDIR}/usr/share/zoneinfo/Europe/Berlin ${DESTDIR}/etc/localtime
  if test -r /etc/wall_cmos_clock; then
     cp -p /etc/wall_cmos_clock ${DESTDIR}/etc/wall_cmos_clock
  fi
}

# ---------------------------------------------------------------------------- #
# ���ƥå� 6: �����������ƥ�˥����󤹤���˽��פ�����
# ���: ���ޤ�¿���ΥХ��ʥ�򤳤λ����ǥ��󥹥ȡ��뤷�ʤ����ȡ���Ư���Ƥ���
# �Ť������ƥ�ȡ����󥹥ȡ��뤷���������Х��ʥꡦ�إå����Ȥ߹�碌��ȡ�
# �֡��ȥ��ȥ�å�����˴٤��ǽ�������롣ports �Ͽ����������ƥब��ư�������
# �ƹ��ۤ��������褤��
# ---------------------------------------------------------------------------- #

step_six () {
  chroot ${DESTDIR} sh -c "cd /usr/ports/shells/zsh; make clean install clean"
  chroot ${DESTDIR} sh -c "cd /etc/mail; make install"  # configure sendmail

  # compat ����ܥ�å���󥯤��ʤ��ȡ�linux_base �Υե����뷲��
  # �롼�ȥե����륷���ƥ���֤���Ƥ��ޤ���
  cd ${DESTDIR}; mkdir -m 755 usr/compat
  chown root:wheel usr/compat; ln -s usr/compat
  mkdir -m 755 usr/compat/linux
  mkdir -m 755 boot/grub

  # /etc/printcap �ǻ��ꤷ�����ס���ǥ��쥯�ȥ�������
  cd ${DESTDIR}/var/spool/output/lpd; mkdir -p as od ev te lp da
  touch ${DESTDIR}/var/log/lpd-errs

  # �Ť������ƥफ������Ѥ������ե���������
  for f in \
    /var/cron/tabs/root \
    /var/mail/* \
    /boot/grub/*; do
    cp -p ${f} ${DESTDIR}${f}
  done

  # ��ͭ�ѡ��ƥ������ /home ���ʤ���С�/home �򥳥ԡ����������褤�����Τ�ʤ���
  # mkdir -p ${DESTDIR}/home
  # cd /home; tar cf - . | (cd ${DESTDIR}/home; tar xpvf -)

  # FreeBSD 5.x ��� perl �� /usr/local/bin ���֤����褦�ˤʤä�����
  # ¿���Υ�����ץȤ� #!/usr/bin/perl �ǥϡ��ɥ����ɤ���Ƥ��롣
  # ������ư����뤿�ᡢ����ܥ�å���󥯤�������Ƥ�����
  cd ${DESTDIR}/usr/bin; ln -s ../local/bin/perl
  cd ${DESTDIR}/usr; rmdir src; ln -s ../src/current src
}

do_steps () {
  step_one
  step_two
  step_three
  step_four
  step_five
  step_six
}

do_steps 2>&1 | tee stage_1.log

# EOF $RCSfile: stage_1.sh,v $    vim: tabstop=2:expandtab:
