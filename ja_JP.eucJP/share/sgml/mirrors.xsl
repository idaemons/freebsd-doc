<?xml version="1.0" encoding="euc-jp"?>
<!-- $FreeBSD$ -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="../../../share/sgml/mirrors.xsl" />

  <xsl:import href="./transtable.xsl" />

  <xsl:output type="xml" encoding="euc-jp"
	      omit-xml-declaration="yes"
	      indent="yes"/>

  <xsl:template name="contact">
    <xsl:param name="email" value="'someone@somewhere'"/>

    <!-- for Japanese version -->
    <para>���꤬������ϡ����Υɥᥤ��Υۥ��ȥޥ���
        <email><xsl:value-of select="$email" /></email> ���ˤ��䤤��碌����������</para>
  </xsl:template>

</xsl:stylesheet>
