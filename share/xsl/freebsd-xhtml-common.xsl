<?xml version='1.0'?>

<!-- $FreeBSD$ -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='1.0'
                xmlns="http://www.w3.org/TR/xhtml1/transitional"
		xmlns:str="http://exslt.org/strings"
		extension-element-prefixes="str"
                exclude-result-prefixes="#default">

  <!-- Include the common customizations -->
  <xsl:import href="freebsd-common.xsl"/>

  <!-- Include customized XHTML titlepage -->
  <xsl:import href="freebsd-xhtml-titlepage.xsl"/>

  <!-- Redefine variables, and replace templates as necessary here -->

  <xsl:param name="use.id.as.filename" select="1"/>
  <xsl:param name="html.stylesheet" select="'docbook.css'"/>
  <xsl:param name="link.mailto.url" select="'doc@FreeBSD.org'"/>
  <xsl:param name="callout.graphics.path" select="'./imagelib/callouts/'"/>
  <xsl:param name="citerefentry.link" select="1"/>
  <xsl:param name="admon.style"/>
  <xsl:param name="make.year.ranges" select="1"/>
  <xsl:param name="make.single.year.ranges" select="1"/>
  <xsl:param name="docbook.css.source" select="''"/>
  <xsl:param name="generate.manifest" select="1"/>
  <xsl:param name="html.longdesc" select="0"/>

  <xsl:param name="make.valid.html" select="1"/>
  <xsl:param name="html.cleanup" select="1"/>
  <xsl:param name="make.clean.html" select="1"/>

  <xsl:param name="local.l10n.xml" select="document('')"/>
  <i18n xmlns="http://docbook.sourceforge.net/xmlns/l10n/1.0">
    <l:l10n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0" language="en">
      <l:gentext key="Lastmodified" text="Last modified"/>
      <l:gentext key="on" text="on"/>
    </l:l10n>
  </i18n>

  <xsl:template name="user.footer.navigation">
    <p align="center"><small>This, and other documents, can be downloaded
    from <a href="ftp://ftp.FreeBSD.org/pub/FreeBSD/doc/">ftp://ftp.FreeBSD.org/pub/FreeBSD/doc/</a></small></p>

    <p align="center"><small>For questions about FreeBSD, read the
    <a href="http://www.FreeBSD.org/docs.html">documentation</a> before
    contacting &lt;<a href="mailto:questions@FreeBSD.org">questions@FreeBSD.org</a>&gt;.<br/>
    For questions about this documentation, e-mail &lt;<a href="mailto:doc@FreeBSD.org">doc@FreeBSD.org</a>&gt;.</small></p>
  </xsl:template>

  <xsl:template name="docformatnav">
    <xsl:variable name="single.fname">
      <xsl:choose>
        <xsl:when test="/book">book.html</xsl:when>
        <xsl:when test="/article">article.html</xsl:when>
      </xsl:choose>
    </xsl:variable>

    <div class="docformatnavi">
      [ <a href="index.html">Split HTML</a> /
      <a href="{$single.fname}">Single HTML</a> ]
    </div>
  </xsl:template>

  <xsl:template match="citerefentry" mode="no.anchor.mode">
    <xsl:apply-templates select="*" mode="no.anchor.mode"/>
  </xsl:template>

  <xsl:template match="refentrytitle" mode="no.anchor.mode">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- Add title class to emitted hX -->
  <xsl:template match="bridgehead">
    <xsl:variable name="container" select="(ancestor::appendix|ancestor::article|ancestor::bibliography|
      ancestor::chapter|ancestor::glossary|ancestor::glossdiv|ancestor::index|ancestor::partintro|
      ancestor::preface|ancestor::refsect1|ancestor::refsect2|ancestor::refsect3|ancestor::sect1|
      ancestor::sect2|ancestor::sect3|ancestor::sect4|ancestor::sect5|ancestor::section|ancestor::setindex|
      ancestor::simplesect)[last()]"/>

    <xsl:variable name="clevel">
      <xsl:choose>
        <xsl:when test="local-name($container) = 'appendix'
	  or local-name($container) = 'chapter'
	  or local-name($container) = 'article'
	  or local-name($container) = 'bibliography'
	  or local-name($container) = 'glossary'
	  or local-name($container) = 'index'
	  or local-name($container) = 'partintro'
	  or local-name($container) = 'preface'
	  or local-name($container) = 'setindex'">1</xsl:when>
        <xsl:when test="local-name($container) = 'glossdiv'">
          <xsl:value-of select="count(ancestor::glossdiv)+1"/>
        </xsl:when>
        <xsl:when test="local-name($container) = 'sect1'
	  or local-name($container) = 'sect2'
	  or local-name($container) = 'sect3'
	  or local-name($container) = 'sect4'
	  or local-name($container) = 'sect5'
	  or local-name($container) = 'refsect1'
	  or local-name($container) = 'refsect2'
	  or local-name($container) = 'refsect3'
	  or local-name($container) = 'section'
	  or local-name($container) = 'simplesect'">
          <xsl:variable name="slevel">
            <xsl:call-template name="section.level">
              <xsl:with-param name="node" select="$container"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="$slevel + 1"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- HTML H level is one higher than section level -->
    <xsl:variable name="hlevel">
      <xsl:choose>
        <xsl:when test="@renderas = 'sect1'">2</xsl:when>
        <xsl:when test="@renderas = 'sect2'">3</xsl:when>
        <xsl:when test="@renderas = 'sect3'">4</xsl:when>
        <xsl:when test="@renderas = 'sect4'">5</xsl:when>
        <xsl:when test="@renderas = 'sect5'">6</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$clevel + 1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="h{$hlevel}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="class">title</xsl:attribute>
      <xsl:call-template name="anchor">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="svnref.genlink">
    <xsl:param name="rev" select="."/>
    <xsl:param name="repo" select="'base'"/>

    <a>
      <xsl:attribute name="href">
	<xsl:call-template name="svnweb.link">
	  <xsl:with-param name="repo" select="$repo"/>
	  <xsl:with-param name="rev" select="$rev"/>
	</xsl:call-template>
      </xsl:attribute>

      <span class="svnref">
	<xsl:value-of select="$rev"/>
      </span>
    </a>
  </xsl:template>

  <xsl:template match="svnref">
    <xsl:call-template name="svnref.genlink"/>
  </xsl:template>

  <xsl:template name="generate.citerefentry.link">
    <xsl:text>http://www.FreeBSD.org/cgi/man.cgi?query=</xsl:text>
    <xsl:value-of select="refentrytitle"/>
    <xsl:text>&#38;amp;sektion=</xsl:text>
    <xsl:value-of select="manvolnum"/>
  </xsl:template>

  <xsl:template name="nongraphical.admonition">
    <div>
      <xsl:call-template name="common.html.attributes">
        <xsl:with-param name="inherit" select="1"/>
      </xsl:call-template>
      <xsl:if test="$admon.style">
        <xsl:attribute name="style">
          <xsl:value-of select="$admon.style"/>
        </xsl:attribute>
      </xsl:if>

      <xsl:if test="$admon.textlabel != 0 or title or info/title">
        <h3 class="admontitle">
          <xsl:call-template name="anchor"/>
          <xsl:apply-templates select="." mode="object.title.markup"/>
	  <xsl:text>: </xsl:text>
        </h3>
      </xsl:if>

      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template name="freebsd.authorgroup">
    <span class="authorgroup">

      <!-- XXX: our docs use a quirky semantics for this -->
      <xsl:if test="(contrib|author/contrib)[1]">
	<xsl:apply-templates select="(contrib|author/contrib)[1]"/>
      </xsl:if>

      <xsl:for-each select="author">
	<xsl:apply-templates select="."/>

	<xsl:choose>
	  <xsl:when test="position() &lt; (last() - 1)">
	    <xsl:text>, </xsl:text>
	  </xsl:when>

	  <xsl:when test="position() = (last() - 1)">
	    <xsl:call-template name="gentext.space"/>
	    <xsl:call-template name="gentext">
	      <xsl:with-param name="key" select="'and'"/>
	    </xsl:call-template>
	    <xsl:call-template name="gentext.space"/>
	  </xsl:when>
	</xsl:choose>
      </xsl:for-each>
      <xsl:text>. </xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="contrib">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="freebsd.author">
    <xsl:if test="contrib">
      <xsl:apply-templates select="contrib"/>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="*[not(self::contrib)]"/>
  </xsl:template>

  <xsl:template name="chapter.authorgroup">
    <xsl:call-template name="freebsd.authorgroup"/>
  </xsl:template>

  <xsl:template name="section.authorgroup">
    <xsl:call-template name="freebsd.authorgroup"/>
  </xsl:template>

  <xsl:template name="chapter.author">
    <xsl:call-template name="freebsd.author"/>
  </xsl:template>

  <xsl:template name="section.author">
    <xsl:call-template name="freebsd.author"/>
  </xsl:template>

  <xsl:template name="titlepage.releaseinfo">
    <xsl:variable name="rev" select="str:split(., ' ')[3]"/>

    <xsl:call-template name="gentext">
      <xsl:with-param name="key" select="'Revision'"/>
    </xsl:call-template>
    <xsl:text>:</xsl:text>
    <xsl:call-template name="gentext.space"/>
    <xsl:call-template name="svnref.genlink">
      <xsl:with-param name="repo" select="'doc'"/>
      <xsl:with-param name="rev" select="$rev"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="titlepage.pubdate">
    <xsl:variable name="pubdate">
      <xsl:choose>
	<xsl:when test="contains(., '$FreeBSD')">
	  <xsl:value-of select="str:split(., ' ')[4]"/>
	</xsl:when>

	<xsl:otherwise>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="committer">
      <xsl:if test="contains(., '$FreeBSD')">
	 <xsl:value-of select="str:split(., ' ')[6]"/>
      </xsl:if>
    </xsl:variable>

    <xsl:call-template name="gentext">
      <xsl:with-param name="key" select="'Lastmodified'"/>
    </xsl:call-template>
    <xsl:call-template name="gentext.space"/>
    <xsl:call-template name="gentext">
      <xsl:with-param name="key" select="'on'"/>
    </xsl:call-template>
    <xsl:call-template name="gentext.space"/>
    <xsl:value-of select="$pubdate"/>
    <xsl:if test="$committer">
      <xsl:call-template name="gentext.space"/>
      <xsl:call-template name="gentext">
	<xsl:with-param name="key" select="'by'"/>
      </xsl:call-template>
      <xsl:call-template name="gentext.space"/>
      <xsl:value-of select="$committer"/>
    </xsl:if>
    <xsl:text>.</xsl:text>
  </xsl:template>

  <!-- Hook in format navigation at the end of the titlepage -->
  <xsl:template name="book.titlepage.separator">
    <xsl:call-template name="docformatnav"/>

    <hr/>
  </xsl:template>
</xsl:stylesheet>
