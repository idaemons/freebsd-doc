<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="../../includes.xsl"/>
  <xsl:import href="includes.xsl"/>
  <xsl:variable name="date" select="'$FreeBSD$'"/>
  <xsl:output doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
    encoding="iso-8859-1" method="html"/>
  <xsl:template match="/">
    <html>
      <xsl:copy-of select="$header1"/>
      <body alink="#0000FF" bgcolor="#FFFFFF" link="#0000FF" text="#000000"
        vlink="#840084">
        <table cellpadding="0" cellspacing="0" width="100%">
          <tr>
            <td border="0">
              <xsl:copy-of select="$header2"/>
            </td>
            <td>
              <img align="right" alt="McKinley die" src="mckinley-die.png"/>
            </td>
          </tr>
        </table>

        <hr/>
        <form action="http://www.FreeBSD.org/cgi/search.cgi" method="get">
          <center>
            Search the ia64 mailing list archives:
            <input name="words" size="50" type="text"/>
            <input name="max" type="hidden" value="25"/>
            <input name="source" type="hidden" value="freebsd-ia64"/>
            <input type="submit" value="Go"/>
          </center>
        </form>
        <hr/>

        <h3>
          <a name="toc">Table Of Contents</a>
        </h3>
        <ul>
          <li>
            <a href="#intro">Introduction</a>
          </li>
          <li>
            <a href="#status">Current status</a>
          </li>
          <li>
            <a href="todo.html">What Needs To Be Done</a>
          </li>
          <li>
            <a href="machines.html">Hardware List</a>
          </li>
          <li>
            <a href="refs.html">References</a>
          </li>
        </ul>
        <h3>
          <a name="intro">Introduction</a>
        </h3>
        <p>
          The FreeBSD/ia64 project pages contain information about the
          FreeBSD port to Intel's IA-64 architecture; officially known as
          the Intel Itanium&#174; Processor Family (IPF). As with the port
          itself, these pages are still mostly a work in progress.
        </p>
        <h3>
          <a name="status">Current status</a>
        </h3>
        <p>
          The ia64 port is still considered a tier 2 platform. This boils
          down to not being fully supported by our security officer, release
          engineers and toolchain maintainers. In practice however the
          distinction between a tier 1 platform (which is fully supported)
          and a tier 2 platform is not as strict as it seems. In almost all
          aspects the ia64 port is a tier 1 platform.
          <br/>
          From a developer point of view there's an advantage to have the ia64
          port be a tier 2 platform for a while longer. We still have a couple
          of ABI breaking changes in the pipeline and having to maintain
          backward compatibility this early in a ports life is less than
          ideal.
        </p>
        <xsl:copy-of select="$footer"/>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
