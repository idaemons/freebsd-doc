#
# $FreeBSD$
#
# This include file <doc.docbook.mk> handles building and installing of
# DocBook documentation in the FreeBSD Documentation Project.
#
# Documentation using DOCFORMAT=docbook is expected to be marked up
# according to the DocBook DTD
#

# ------------------------------------------------------------------------
#
# Document-specific variables
#
#	DOC		This should be set to the name of the DocBook
#			marked-up file, without the .xml suffix.
#			
#			It also determins the name of the output files -
#			${DOC}.html.
#
#	SRCS		The names of all the files that are needed to
#			build this document - This is useful if any of
#			them need to be generated.  Changing any file in
#			SRCS causes the documents to be rebuilt.
#
#       HAS_INDEX       This document has index terms and so an index
#                       can be created if specified with GEN_INDEX.
#

# ------------------------------------------------------------------------
#
# Variables used by both users and documents:
#
#	XMLFLAGS	Additional options to pass to various XML
#			processors (e.g., jade, nsgmls).  Typically
#			used to define "IGNORE" entities to "INCLUDE"
#			 with "-i<entity-name>"
#
#	JADEFLAGS	Additional options to pass to Jade.  Typically
#			used to set additional variables, such as
#			"%generate-article-toc%".
#
#	EXTRA_CATALOGS	Additional catalog files that should be used by
#			any XML processing applications.
#
#       GEN_INDEX       If this document has an index (HAS_INDEX) and this
#                       variable is defined, then index.xml will be added 
#                       to the list of dependencies for source files, and 
#                       collateindex.pl will be run to generate index.xml.
#
#	CSS_SHEET	Full path to a CSS stylesheet suitable for DocBook.
#			Default is ${DOC_PREFIX}/share/misc/docbook.css
#
#
#	SPELLCHECK	Use the special spellcheck.dsl stylesheet to render
#			HTML that is suitable for processing through a 
#			spellchecker.  For example, PGP keys and filenames
#			will be omitted from this output.
#
# Package building options:
# 
#       BZIP2_PACKAGE  Use bzip2(1) utility to compress package tarball
#                      instead of gzip(1).  It results packages to have
#                      suffix .tbz instead of .tgz.  Using bzip2(1)
#                      provides better compression, but requires longer
#                      time and utilizes more CPU resources than gzip(1).

#
# Documents should use the += format to access these.
#

MASTERDOC?=	${.CURDIR}/${DOC}.xml

# Either jade or fop
RENDERENGINE?=	jade

XMLDECL?=	/usr/local/share/sgml/docbook/dsssl/modular/dtds/decls/xml.dcl

DSLHTML?=	${DOC_PREFIX}/share/xml/spellcheck.dsl
DSLPRINT?=	${DOC_PREFIX}/share/xml/default.dsl
DSLPGP?=	${DOC_PREFIX}/share/xml/pgp.dsl

XSLPROF?=	/usr/local/share/xsl/docbook/profiling/profile.xsl
XSLXHTML?=	${DOC_PREFIX}/${LANGCODE}/share/xsl/freebsd-xhtml.xsl
XSLXHTMLCHUNK?=	${DOC_PREFIX}/${LANGCODE}/share/xsl/freebsd-xhtml-chunk.xsl
XSLEPUB?=	${DOC_PREFIX}/${LANGCODE}/share/xsl/freebsd-epub.xsl
XSLFO?=		${DOC_PREFIX}/${LANGCODE}/share/xsl/freebsd-fo.xsl

XSLSCH?=	/usr/local/share/xsl/iso-schematron/xslt1/iso_schematron_skeleton_for_xslt1.xsl

IMAGES_LIB?=

SCHEMATRONS?=	${DOC_PREFIX}/share/xml/freebsd.sch

.if exists(${PREFIX}/bin/jade) && !defined(OPENJADE)
JADECATALOG?=	${PREFIX}/share/sgml/jade/catalog
.else
JADECATALOG?=	${PREFIX}/share/sgml/openjade/catalog
.endif
FREEBSDCATALOG=	${DOC_PREFIX}/share/xml/catalog
LANGUAGECATALOG=${DOC_PREFIX}/${LANGCODE}/share/xml/catalog
DSSSLCATALOG=	${PREFIX}/share/sgml/docbook/dsssl/modular/catalog
.for c in ${LANGUAGECATALOG} ${FREEBSDCATALOG} ${DSSSLCATALOG} ${JADECATALOG}
.if exists(${c})
CATALOGS+=	-c ${c}
.endif
.endfor

JADEOPTS?=	-ijade.compat -w no-valid ${JADEFLAGS} \
		-D ${IMAGES_EN_DIR}/${DOC}s/${.CURDIR:T} -D ${CANONICALOBJDIR} \
		${CATALOGS}
XSLTPROCOPTS?=	--nonet

KNOWN_FORMATS=	html html.tar html-split html-split.tar \
		epub txt rtf ps pdf tex dvi tar pdb

CSS_SHEET?=	${DOC_PREFIX}/share/misc/docbook.css

PRINTOPTS?=	-ioutput.print -d ${DSLPRINT} ${PRINTFLAGS}

.if defined(WWWFREEBSDORG)
HTMLFLAGS+=	-V %html-header-script%
.endif
.if !defined(WITH_INLINE_LEGALNOTICE) || empty(WITH_INLINE_LEGALNOTICE)
HTMLFLAGS+=	-V %generate-legalnotice-link%
.endif
.if defined(WITH_ARTICLE_TOC) && !empty(WITH_ARTICLE_TOC)
HTMLFLAGS+=	-V %generate-article-toc%
PRINTFLAGS+=	-V %generate-article-toc%
.endif
.if defined(WITH_BIBLIOXREF_TITLE) && !empty(WITH_BIBLIOXREF_TITLE)
HTMLFLAGS+=	-V biblio-xref-title
PRINTFLAGS+=	-V biblio-xref-title
.endif
.if defined(WITH_DOCFORMAT_NAVI_LINK) && !empty(WITH_DOCFORMAT_NAVI_LINK)
HTMLFLAGS+=	-V %generate-docformat-navi-link%
.elif (${FORMATS:Mhtml} == "html") && (${FORMATS:Mhtml-split} == "html-split")
HTMLFLAGS+=	-V %generate-docformat-navi-link%
.endif
.if defined(WITH_ALL_TRADEMARK_SYMBOLS) && !empty(WITH_ALL_TRADEMARK_SYMBOLS)
HTMLFLAGS+=	-V %show-all-trademark-symbols%
PRINTFLAGS+=	-V %show-all-trademark-symbols%
.endif

#
# Instruction for bsd.subdir.mk to not to process SUBDIR directive.
# It is not necessary since doc.docbook.mk do it too.
#
NO_SUBDIR=      YES

#
# Index generation
#

.if defined(GEN_INDEX)
XSLTPROCOPTS+= --param generate.index "1"
.endif

# ------------------------------------------------------------------------
#
# Look at ${FORMATS} and work out which documents need to be generated.
# It is assumed that the HTML transformation will always create a file
# called index.html, and that for every other transformation the name
# of the generated file is ${DOC}.format.
#
# ${_docs} will be set to a list of all documents that must be made
# up to date.
#
# ${CLEANFILES} is a list of files that should be removed by the "clean"
# target. ${COMPRESS_EXT:S/^/${DOC}.${_cf}.&/ takes the COMPRESS_EXT
# var, and prepends the filename to each listed extension, building a
# second list of files with the compressed extensions added.
#

# Note: ".for _curformat in ${KNOWN_FORMATS}" is used several times in
# this file. I know they could have been rolled together in to one, much
# larger, loop. However, that would have made things more complicated
# for a newcomer to this file to unravel and understand, and a syntax
# error in the loop would have affected the entire
# build/compress/install process, instead of just one of them, making it
# more difficult to debug.
#

# Note: It is the aim of this file that *all* the targets be available,
# not just those appropriate to the current ${FORMATS} and
# ${INSTALL_COMPRESSED} values.
#
# For example, if FORMATS=html and INSTALL_COMPRESSED=gz you could still
# type
#
#     make book.rtf.bz2
#
# and it will do the right thing. Or
#
#     make install-rtf.bz2
#
# for that matter. But don't expect "make clean" to work if the FORMATS
# and INSTALL_COMPRESSED variables are wrong.
#

.if ${.OBJDIR} != ${.CURDIR}
LOCAL_CSS_SHEET= ${.OBJDIR}/${CSS_SHEET:T}
.else
LOCAL_CSS_SHEET= ${CSS_SHEET:T}
.endif

CLEANFILES+= ${DOC}.parsed.xml ${DOC}.parsed.print.xml

.for _curformat in ${FORMATS}
_cf=${_curformat}

.if ${_cf} == "html-split"
_docs+= index.html HTML.manifest ln*.html
CLEANFILES+= $$([ -f HTML.manifest ] && ${XARGS} < HTML.manifest) \
		HTML.manifest ln*.html
CLEANFILES+= PLIST.${_curformat}

.else
_docs+= ${DOC}.${_curformat}
CLEANFILES+= ${DOC}.${_curformat}
CLEANFILES+= PLIST.${_curformat}

.if ${_cf} == "html-split.tar"
CLEANFILES+= $$([ -f HTML.manifest ] && ${XARGS} < HTML.manifest) \
		HTML.manifest ln*.html

.elif ${_cf} == "epub"
CLEANFILES+= ${DOC}.epub mimetype
CLEANDIRS+= META-INF OEBPS

.elif ${_cf} == "html.tar"
CLEANFILES+= ${DOC}.html

.elif ${_cf} == "txt"
CLEANFILES+= ${DOC}.html-text

.elif ${_cf} == "dvi"
CLEANFILES+= ${DOC}.aux ${DOC}.log ${DOC}.out ${DOC}.tex ${DOC}.tex-tmp

.elif ${_cf} == "rtf"
CLEANFILES+= ${DOC}.rtf-nopng

.elif ${_cf} == "tex"
CLEANFILES+= ${DOC}.aux ${DOC}.log

.elif ${_cf} == "ps"
CLEANFILES+= ${DOC}.aux ${DOC}.dvi ${DOC}.log ${DOC}.out ${DOC}.tex-ps \
	${DOC}.tex ${DOC}.tex-tmp ${DOC}.fo
.for _curimage in ${LOCAL_IMAGES_EPS:M*share*}
CLEANFILES+= ${_curimage:T} ${_curimage:H:T}/${_curimage:T}
.endfor

.elif ${_cf} == "pdf"
CLEANFILES+= ${DOC}.aux ${DOC}.dvi ${DOC}.log ${DOC}.out ${DOC}.tex-pdf ${DOC}.tex-pdf-tmp \
		${DOC}.tex ${DOC}.fo
.for _curimage in ${LOCAL_IMAGES_EPS:M*share*}
CLEANFILES+= ${_curimage:T} ${_curimage:H:T}/${_curimage:T}
.endfor

.elif ${_cf} == "pdb"
_docs+= ${.CURDIR:T}.pdb
CLEANFILES+= ${.CURDIR:T}.pdb

.endif
.endif

.if (${LOCAL_CSS_SHEET} != ${CSS_SHEET}) && \
    (${_cf} == "html-split" || ${_cf} == "html-split.tar" || \
     ${_cf} == "html" || ${_cf} == "html.tar" || ${_cf} == "txt")
CLEANFILES+= ${LOCAL_CSS_SHEET}
.endif

.if !defined(WITH_INLINE_LEGALNOTICE) || empty(WITH_INLINE_LEGALNOTICE) && \
    (${_cf} == "html-split" || ${_cf} == "html-split.tar" || \
     ${_cf} == "html" || ${_cf} == "html.tar" || ${_cf} == "txt")
.endif

.endfor		# _curformat in ${FORMATS} #


#
# Build a list of install-${format}.${compress_format} targets to be
# by "make install". Also, add ${DOC}.${format}.${compress_format} to
# ${_docs} and ${CLEANFILES} so they get built/cleaned by "all" and
# "clean".
#

.if defined(INSTALL_COMPRESSED) && !empty(INSTALL_COMPRESSED)
.for _curformat in ${FORMATS}
_cf=${_curformat}
.for _curcomp in ${INSTALL_COMPRESSED}

.if ${_cf} != "html-split" && ${_cf} != "html" && ${_cf} != "epub"
_curinst+= install-${_curformat}.${_curcomp}
_docs+= ${DOC}.${_curformat}.${_curcomp}
CLEANFILES+= ${DOC}.${_curformat}.${_curcomp}

.if  ${_cf} == "pdb"
_docs+= ${.CURDIR:T}.${_curformat}.${_curcomp}
CLEANFILES+= ${.CURDIR:T}.${_curformat}.${_curcomp}

.endif
.endif
.endfor
.endfor
.endif

.MAIN: all

all: ${SRCS} ${_docs}

# put languages which have a problem on rendering printable formats
# by using TeX to NO_TEX_LANG.
NO_TEX_LANG?=	ja_JP.eucJP ru_RU.KOI8-R

# put languages which have a problem on rendering the plain text format
# by using links1 to NO_PLAINTEXT_LANG.
NO_PLAINTEXT_LANG?=	ja_JP.eucJP

# put languages which have a problem on rendering the rtf format
# by using jade to NO_RTF_LANG.
NO_RTF_LANG?=

.for _L in ${LANGCODE}
.if ${NO_TEX_LANG:M${_L}} != ""
NO_TEX=		yes
.endif
.if ${NO_PLAINTEXT_LANG:M${_L}} != ""
NO_PLAINTEXT=	yes
.endif
.if ${NO_RTF_LANG:M${_L}} != ""
NO_RTF=		yes
.endif
.endfor

.if defined(SCHEMATRONS)
.for sch in ${SCHEMATRONS}
schxslts+=	${sch}.xsl

${sch}.xsl: ${sch}
	${XSLTPROC} --param allow-foreign "true" ${XSLSCH} ${.ALLSRC} > ${.TARGET}
.endfor
.endif

# Parsed XML  -------------------------------------------------------

${DOC}.parsed.xml: ${SRCS}
	${GREP} '^<?xml version=.*?>' ${DOC}.xml > ${.TARGET}.tmp
.if ${DOC} == "book"
	${ECHO_CMD} '<!DOCTYPE book PUBLIC "-//FreeBSD//DTD DocBook XML V4.5-Based Extension//EN" "../../../share/xml/freebsd45.dtd">' >> ${.TARGET}.tmp
.else
	${ECHO_CMD} '<!DOCTYPE article PUBLIC "-//FreeBSD//DTD DocBook XML V4.5-Based Extension//EN" "../../../share/xml/freebsd45.dtd">' >> ${.TARGET}.tmp
.endif
	@${ECHO} "==> Basic validation"
	${XMLLINT} --nonet --noent --valid --xinclude --dropdtd ${MASTERDOC} | \
	${GREP} -v '^<?xml version=.*?>' >> ${.TARGET}.tmp
.if defined(PROFILING)
	@${ECHO} "==> Profiling"
	${XSLTPROC} ${PROFILING} ${XSLPROF} ${.TARGET}.tmp > ${.TARGET}
	${RM} ${.TARGET}.tmp
.else
	${MV} ${.TARGET}.tmp ${.TARGET}
	${SED} 's|@@URL_RELPREFIX@@|http://www.FreeBSD.org|g' < ${.TARGET} > ${DOC}.parsed.print.xml
	${SED} -i '' 's|@@URL_RELPREFIX@@|../../../..|g' ${.TARGET}
.endif

# XHTML -------------------------------------------------------------

index.html: ${DOC}.parsed.xml ${LOCAL_IMAGES_LIB} ${LOCAL_IMAGES_PNG} \
	${HTML_SPLIT_INDEX} ${LOCAL_CSS_SHEET}
	${XSLTPROC} ${XSLTPROCOPTS} ${XSLXHTMLCHUNK} ${DOC}.parsed.xml

${DOC}.html: ${DOC}.parsed.xml ${LOCAL_IMAGES_LIB} ${LOCAL_IMAGES_PNG} \
	${LOCAL_CSS_SHEET}     
	${XSLTPROC} ${XSLTPROCOPTS} ${XSLXHTML} ${DOC}.parsed.xml > ${.TARGET}

${DOC}.html-split.tar: HTML.manifest ${LOCAL_IMAGES_LIB} \
		       ${LOCAL_IMAGES_PNG} ${LOCAL_CSS_SHEET}
	${TAR} cf ${.TARGET} $$(${XARGS} < HTML.manifest) \
		${LOCAL_IMAGES_LIB} ${IMAGES_PNG:N*share*} ${CSS_SHEET:T}
.for _curimage in ${IMAGES_PNG:M*share*}
	${TAR} rf ${.TARGET} -C ${IMAGES_EN_DIR}/${DOC}s/${.CURDIR:T} ${_curimage:S|${IMAGES_EN_DIR}/${DOC}s/${.CURDIR:T}/||}
.endfor

${DOC}.html.tar: ${DOC}.html ${LOCAL_IMAGES_LIB} \
		 ${LOCAL_IMAGES_PNG} ${LOCAL_CSS_SHEET}
	${TAR} cf ${.TARGET} ${DOC}.html \
		${LOCAL_IMAGES_LIB} ${IMAGES_PNG:N*share*} ${CSS_SHEET:T}
.for _curimage in ${IMAGES_PNG:M*share*}
	${TAR} rf ${.TARGET} -C ${IMAGES_EN_DIR}/${DOC}s/${.CURDIR:T} ${_curimage:S|${IMAGES_EN_DIR}/${DOC}s/${.CURDIR:T}/||}
.endfor

# EPUB -------------------------------------------------------------

${DOC}.epub: ${DOC}.parsed.xml ${LOCAL_IMAGES_LIB} ${LOCAL_IMAGES_PNG} \
	${CSS_SHEET}
	${XSLTPROC} ${XSLTPROCOPTS} ${XSLEPUB} ${DOC}.parsed.xml
	${ECHO} "application/epub+zip" > mimetype
	${CP} ${CSS_SHEET} OEBPS/
.if defined(LOCAL_IMAGES_LIB) || defined(LOCAL_IMAGES_PNG)
	${CP} ${LOCAL_IMAGES_LIB} ${LOCAL_IMAGES_PNG} OEBPS/
.endif
	${ZIP} ${ZIPOPTS} ${DOC}.epub mimetype
	${ZIP} ${ZIPOPTS} -Dr ${DOC}.epub OEBPS META-INF

# TXT --------------------------------------------------------------------

.if !target(${DOC}.txt)
.if !defined(NO_PLAINTEXT)
${DOC}.txt: ${DOC}.html
	${HTML2TXT} ${HTML2TXTOPTS} ${.ALLSRC} > ${.TARGET}
.else
${DOC}.txt:
	${TOUCH} ${.TARGET}
.endif	
.endif

# PDB --------------------------------------------------------------------

${DOC}.pdb: ${DOC}.html ${LOCAL_IMAGES_LIB} ${LOCAL_IMAGES_PNG}
	${HTML2PDB} ${HTML2PDBOPTS} ${DOC}.html ${.TARGET}

${.CURDIR:T}.pdb: ${DOC}.pdb
	${LN} -f ${.ALLSRC} ${.TARGET}

.if defined(INSTALL_COMPRESSED) && !empty(INSTALL_COMPRESSED)
.for _curcomp in ${INSTALL_COMPRESSED}
${.CURDIR:T}.pdb.${_curcomp}: ${DOC}.pdb.${_curcomp}
	${LN} -f ${.ALLSRC} ${.TARGET}
.endfor
.endif

# RTF --------------------------------------------------------------------

.if !target(${DOC}.rtf)
.if !defined(NO_RTF)
${DOC}.rtf: ${DOC}.parsed.xml ${LOCAL_IMAGES_EPS} ${PRINT_INDEX} \
		${LOCAL_IMAGES_TXT} ${LOCAL_IMAGES_PNG}
	${JADE} -V rtf-backend ${PRINTOPTS} -ioutput.rtf.images \
		${JADEOPTS} -t rtf -o ${.TARGET}-nopng ${XMLDECL} \
		${DOC}.parsed.xml
	${FIXRTF} ${FIXRTFOPTS} < ${.TARGET}-nopng > ${.TARGET}
.else
${DOC}.rtf:
	${TOUCH} ${.TARGET}
.endif
.endif

# PS/PDF -----------------------------------------------------------------

.if ${RENDERENGINE} == "jade"
.if !defined(NO_TEX)
${DOC}.tex: ${SRCS} ${LOCAL_IMAGES_EPS} ${PRINT_INDEX} \
		${LOCAL_IMAGES_TXT} ${LOCAL_IMAGES_EN} \
		${DOC}.parsed.xml
	${JADE} -V tex-backend ${PRINTOPTS} \
		${JADEOPTS} -t tex -o ${.TARGET} ${XMLDECL} ${DOC}.parsed.print.xml
	${SED} -i '' -e 's|{1}\\def\\ScaleY%|{0.5}\\def\\ScaleY%|g' \
		-e 's|{1}\\def\\EntitySystemId%|{0.5}\\def\\EntitySystemId%|g' \
		${.TARGET}

.if !target(${DOC}.dvi)
${DOC}.dvi: ${DOC}.tex ${LOCAL_IMAGES_EPS}
.for _curimage in ${LOCAL_IMAGES_EPS:M*share*}
	${CP} -p ${_curimage} ${.CURDIR:H:H}/${_curimage:H:S|${IMAGES_EN_DIR}/||:S|${.CURDIR}||}
.endfor
	${JADETEX_PREPROCESS} < ${DOC}.tex > ${DOC}.tex-tmp
	@${ECHO} "==> TeX pass 1/3"
	-${JADETEX_CMD} '${TEX_CMDSEQ} \nonstopmode\input{${DOC}.tex-tmp}'
	@${ECHO} "==> TeX pass 2/3"
	-${JADETEX_CMD} '${TEX_CMDSEQ} \nonstopmode\input{${DOC}.tex-tmp}'
	@${ECHO} "==> TeX pass 3/3"
	-${JADETEX_CMD} '${TEX_CMDSEQ} \nonstopmode\input{${DOC}.tex-tmp}'
.endif

.if !target(${DOC}.pdf)
${DOC}.pdf: ${DOC}.ps ${IMAGES_PDF}
	${PS2PDF} ${DOC}.ps ${.TARGET}
.endif

${DOC}.ps: ${DOC}.dvi
	${DVIPS} ${DVIPSOPTS} -o ${.TARGET} ${.ALLSRC}
.else
#  NO_TEX
${DOC}.tex ${DOC}.dvi ${DOC}.ps:
	${TOUCH} ${.TARGET}
.if !target(${DOC}.pdf)
${DOC}.pdf:
	${TOUCH} ${.TARGET}
.endif
.endif

.elif ${RENDERENGINE} == "fop"
${DOC}.fo: ${DOC}.xml ${LOCAL_IMAGES_LIB} ${LOCAL_IMAGES_PNG} ${DOC}.parsed.xml
	${XSLTPROC} ${XSLTPROCOPTS} ${XSLFO} ${DOC}.parsed.print.xml > ${.TARGET}

${DOC}.pdf: ${DOC}.fo ${LOCAL_IMAGES_LIB} ${LOCAL_IMAGES_PNG}
	${FOP} ${FOPOPTS} ${DOC}.fo ${.TARGET}

${DOC}.ps: ${DOC}.fo ${LOCAL_IMAGES_LIB} ${LOCAL_IMAGES_PNG}
	${FOP} ${FOPOPTS} ${DOC}.fo ${.TARGET}

${DOC}.rtf: ${DOC}.fo ${LOCAL_IMAGES_LIB} ${LOCAL_IMAGES_PNG}
	${FOP} ${FOPOPTS} ${DOC}.fo ${.TARGET}

.endif

${DOC}.tar: ${SRCS} ${LOCAL_IMAGES} ${LOCAL_CSS_SHEET}
	${TAR} cf ${.TARGET} -C ${.CURDIR} ${SRCS} \
		-C ${.OBJDIR} ${IMAGES} ${CSS_SHEET:T}

#
# Build targets for any formats we've missed that we don't handle.
#
.for _curformat in ${ALL_FORMATS}
.if !target(${DOC}.${_curformat})
${DOC}.${_curformat}:
	@${ECHO_CMD} \"${_curformat}\" is not a valid output format for this document.
.endif
.endfor


# ------------------------------------------------------------------------
#
# Validation targets
#

#
# Lets you quickly check that the document conforms to the DTD without
# having to convert it to any other formats
#

#
# XXX: There is duplicated code below. In general, we want to see what
# is actually run but when validation is executed, it is better to
# silence the command invocation so that only error messages appear.
#

lint validate: ${SRCS} ${schxslts}
	@${GREP} '^<?xml version=.*?>' ${DOC}.xml > ${DOC}.parsed.xml
.if ${DOC} == "book"
	@${ECHO_CMD} '<!DOCTYPE book PUBLIC "-//FreeBSD//DTD DocBook XML V4.5-Based Extension//EN" "../../../share/xml/freebsd45.dtd">' >> ${DOC}.parsed.xml
.else
	@${ECHO_CMD} '<!DOCTYPE article PUBLIC "-//FreeBSD//DTD DocBook XML V4.5-Based Extension//EN" "../../../share/xml/freebsd45.dtd">' >> ${DOC}.parsed.xml
.endif
	@${ECHO} "==> Basic validation"
	@${XMLLINT} --nonet --noent --valid --xinclude --dropdtd ${MASTERDOC} | \
	${GREP} -v '^<?xml version=.*?>' >>${DOC}.parsed.xml
.if defined(schxslts)
	@${ECHO} "==> Validating with Schematron constraints"
.for sch in ${schxslts}
	@( out=`${XSLTPROC} ${sch} ${DOC}.parsed.xml`; \
	  if [ -n "$${out}" ]; then \
		echo "$${out}" | ${GREP} -v '^<?xml'; \
		false; \
	  fi )
.endfor
.endif
	@${RM} -rf ${CLEANFILES} ${CLEANDIRS} ${DOC}.parsed.xml

# ------------------------------------------------------------------------
#
# Compress targets
#

#
# The list of compression extensions this Makefile knows about. If you
# add new compression schemes, add to this list (which is a list of
# extensions, hence bz2, *not* bzip2) and extend the _PROG_COMPRESS_*
# targets.
#

KNOWN_COMPRESS=	gz bz2 zip

#
# You can't build suffix rules to do compression, since you can't
# wildcard the source suffix. So these are defined .USE, to be tacked on
# as dependencies of the compress-* targets.
#

_PROG_COMPRESS_gz: .USE
	${GZIP} ${GZIPOPTS} < ${.ALLSRC} > ${.TARGET}

_PROG_COMPRESS_bz2: .USE
	${BZIP2} ${BZIP2OPTS} < ${.ALLSRC} > ${.TARGET}

_PROG_COMPRESS_zip: .USE
	${ZIP} ${ZIPOPTS} ${.TARGET} ${.ALLSRC}

#
# Build a list of targets for each compression scheme and output format.
# Don't compress the html-split or html output format (because they need
# to be rolled in to tar files first).
#
.for _curformat in ${KNOWN_FORMATS}
_cf=${_curformat}
.for _curcompress in ${KNOWN_COMPRESS}
.if ${_cf} == "html-split" || ${_cf} == "html"
${DOC}.${_cf}.tar.${_curcompress}: ${DOC}.${_cf}.tar \
				   _PROG_COMPRESS_${_curcompress}
.else
${DOC}.${_cf}.${_curcompress}: ${DOC}.${_cf} _PROG_COMPRESS_${_curcompress}
.endif
.endfor
.endfor

#
# Build targets for any formats we've missed that we don't handle.
#
.for _curformat in ${ALL_FORMATS}
.for _curcompress in ${KNOWN_COMPRESS}
.if !target(${DOC}.${_curformat}.${_curcompress})
${DOC}.${_curformat}.${_curcompress}:
	@${ECHO_CMD} \"${_curformat}.${_curcompress}\" is not a valid output format for this document.
.endif
.endfor
.endfor


# ------------------------------------------------------------------------
#
# Install targets
#
# Build install-* targets, one per allowed value in FORMATS. Need to
# build two specific targets;
#
#    install-html-split - Handles multiple .html files being generated
#                         from one source. Uses the HTML.manifest file
#                         created by the stylesheets, which should list
#                         each .html file that's been created.
#
#    install-*          - Every other format. The wildcard expands to
#                         the other allowed formats, all of which should
#                         generate just one file.
#
# "beforeinstall" and "afterinstall" are hooks in to this process.
# Redefine them to do things before and after the files are installed,
# respectively.

populate_html_docs:
.if exists(HTML.manifest)
_html_docs!=${CAT} HTML.manifest
.endif

spellcheck-html-split: populate_html_docs
.for _html_file in ${_html_docs}
	@echo "Spellcheck ${_html_file}"
	@${HTML2TXT} ${HTML2TXTOPTS} ${.CURDIR}/${_html_file} | ${ISPELL} ${ISPELLOPTS}
.endfor
spellcheck-html:
.for _entry in ${_docs}
	@echo "Spellcheck ${_entry}"
	@${HTML2TXT} ${HTML2TXTOPTS} ${.CURDIR}/${_entry} | ${ISPELL} ${ISPELLOPTS}
.endfor
spellcheck-txt:
.for _entry in ${_docs:M*.txt}
	@echo "Spellcheck ${_entry}"
	@ < ${.CURDIR}/${_entry} ${ISPELL} ${ISPELLOPTS}
.endfor
.for _curformat in ${FORMATS}
.if !target(spellcheck-${_curformat})
spellcheck-${_curformat}:
	@echo "Spellcheck is not currently supported for the ${_curformat} format."
.endif
.endfor

spellcheck: ${FORMATS:C/^/spellcheck-/}

#
# Build a list of install-format targets to be installed. These will be
# dependencies for the "realinstall" target.
#

.if !defined(INSTALL_ONLY_COMPRESSED) || empty(INSTALL_ONLY_COMPRESSED)
_curinst+= ${FORMATS:S/^/install-/g}
.endif

.if defined(NO_TEX)
_curinst_filter+=N*dvi* N*tex* N*ps* N*pdf*
.endif
.if defined(NO_RTF)
_curinst_filter+=N*rtf*
.endif
.if defined(NO_PLAINTEXT)
_curinst_filter+=N*txt*
.endif

_cff!=${ECHO_CMD} "${_curinst_filter}" | ${SED} 's, ,:,g'

.if !defined(_cff) || empty(_cff)
realinstall: ${_curinst}
.else
.for i in ${_cff}
realinstall: ${_curinst:$i}
.endfor
.endif

.for _curformat in ${KNOWN_FORMATS}
_cf=${_curformat}
.if !target(install-${_cf})
.if ${_cf} == "html-split"
install-${_curformat}: index.html
.else
install-${_curformat}: ${DOC}.${_curformat}
.endif
	@[ -d ${DESTDIR} ] || ${MKDIR} -p ${DESTDIR}
.if ${_cf} == "html-split"
.for f in ${_html_docs}
.if exists(${f})
	${INSTALL_DOCS} ${f} ${DESTDIR}
.endif
.endfor
.else
	${INSTALL_DOCS} ${.ALLSRC} ${DESTDIR}
.endif
.if (${_cf} == "html-split" || ${_cf} == "html") && !empty(LOCAL_CSS_SHEET)
	${INSTALL_DOCS} ${LOCAL_CSS_SHEET} ${DESTDIR}
.if ${_cf} == "html-split"
	@if [ -f ln*.html ]; then \
		${INSTALL_DOCS} ln*.html ${DESTDIR}; \
	fi
	@if [ -f LEGALNOTICE.html ]; then \
		${INSTALL_DOCS} LEGALNOTICE.html ${DESTDIR}; \
	fi
	@if [ -f trademarks.html ]; then \
		${INSTALL_DOCS} trademarks.html ${DESTDIR}; \
	fi
	@if [ -f ${.OBJDIR}/${DOC}.ln ]; then \
		cd ${DESTDIR}; sh ${.OBJDIR}/${DOC}.ln; \
	fi
.endif
.for _curimage in ${IMAGES_LIB}
	@[ -d ${DESTDIR}/${LOCAL_IMAGES_LIB_DIR}/${_curimage:H} ] || \
		${MKDIR} -p ${DESTDIR}/${LOCAL_IMAGES_LIB_DIR}/${_curimage:H}
	${INSTALL_DOCS} ${LOCAL_IMAGES_LIB_DIR}/${_curimage} \
			${DESTDIR}/${LOCAL_IMAGES_LIB_DIR}/${_curimage:H}
.endfor
# Install the images.  First, loop over all the image names that contain a
# directory separator, make the subdirectories, and install.  Then loop over
# the ones that don't contain a directory separator, and install them in the
# top level.
# Install at first images from /usr/share/images then localized ones
# cause of a different origin path.
.for _curimage in ${IMAGES_PNG:M*/*:M*share*}
	${MKDIR} -p ${DESTDIR:H:H}/${_curimage:H:S|${IMAGES_EN_DIR}/||:S|${.CURDIR}||}
	${INSTALL_DOCS} ${_curimage} ${DESTDIR:H:H}/${_curimage:H:S|${IMAGES_EN_DIR}/||:S|${.CURDIR}||}
.endfor
.for _curimage in ${IMAGES_PNG:M*/*:N*share*}
	${MKDIR} -p ${DESTDIR}/${_curimage:H}
	${INSTALL_DOCS} ${_curimage} ${DESTDIR}/${_curimage:H}
.endfor
.for _curimage in ${IMAGES_PNG:N*/*}
	${INSTALL_DOCS} ${_curimage} ${DESTDIR}/${_curimage}
.endfor
.elif ${_cf} == "tex" || ${_cf} == "dvi"
.for _curimage in ${IMAGES_EPS:M*/*}
	${MKDIR} -p ${DESTDIR}/${_curimage:H:S|${IMAGES_EN_DIR}/||:S|${.CURDIR:T}/||}
	${INSTALL_DOCS} ${_curimage} ${DESTDIR}/${_curimage:H:S|${IMAGES_EN_DIR}/||:S|${.CURDIR:T}/||}
.endfor
.for _curimage in ${IMAGES_EPS:N*/*}
	${INSTALL_DOCS} ${_curimage} ${DESTDIR}
.endfor
.elif ${_cf} == "pdb"
	${LN} -f ${DESTDIR}/${.ALLSRC} ${DESTDIR}/${.CURDIR:T}.${_curformat}
.endif

.if ${_cf} == "html-split"
.for _compressext in ${KNOWN_COMPRESS}
install-${_curformat}.tar.${_compressext}: ${DOC}.${_curformat}.tar.${_compressext}
	@[ -d ${DESTDIR} ] || ${MKDIR} -p ${DESTDIR}
	${INSTALL_DOCS} ${.ALLSRC} ${DESTDIR}
.endfor
.else
.for _compressext in ${KNOWN_COMPRESS}
.if !target(install-${_curformat}.${_compressext})
install-${_curformat}.${_compressext}: ${DOC}.${_curformat}.${_compressext}
	@[ -d ${DESTDIR} ] || ${MKDIR} -p ${DESTDIR}
	${INSTALL_DOCS} ${.ALLSRC} ${DESTDIR}
.if ${_cf} == "pdb"
	${LN} -f ${DESTDIR}/${.ALLSRC} \
		 ${DESTDIR}/${.CURDIR:T}.${_curformat}.${_compressext}
.endif
.endif
.endfor
.endif
.endif
.endfor

#
# Build install- targets for any formats we've missed that we don't handle.
#

.for _curformat in ${ALL_FORMATS}
.if !target(install-${_curformat})
install-${_curformat}:
	@${ECHO_CMD} \"${_curformat}\" is not a valid output format for this document.

.for _compressext in ${KNOWN_COMPRESS}
install-${_curformat}.${_compressext}:
	@${ECHO_CMD} \"${_curformat}.${_compressext}\" is not a valid output format for this document.
.endfor
.endif
.endfor


# ------------------------------------------------------------------------
#
# Package building
#

#
# realpackage is what is called in each subdirectory when a package
# target is called, or, rather, package calls realpackage in each
# subdirectory as it goes.
#
# packagelist returns the list of targets that would be called during
# package building.
#

realpackage: ${FORMATS:S/^/package-/}
packagelist:
	@${ECHO_CMD} ${FORMATS:S/^/package-/}

#
# Build a list of package targets for each output target.  Each package
# target depends on the corresponding install target running.
#

.if defined(BZIP2_PACKAGE)
PKG_SUFFIX=	tbz
.else
PKG_SUFFIX=	tgz
.endif

PKGDOCPFX!= realpath ${DOC_PREFIX}

.for _curformat in ${KNOWN_FORMATS}
__curformat=${_curformat}

${PACKAGES}/${.CURDIR:T}.${LANGCODE}.${_curformat}.${PKG_SUFFIX}:
	${MKDIR} -p ${.OBJDIR}/pkg; \
	(cd ${.CURDIR} && \
		${MAKE} FORMATS=${_curformat} \
			DOCDIR=${.OBJDIR}/pkg \
			${PKGMAKEFLAGS} \
			install); \
	PKGSRCDIR=${.OBJDIR}/pkg/${.CURDIR:S/${PKGDOCPFX}\///}; \
	/bin/ls -1 $$PKGSRCDIR > ${.OBJDIR}/PLIST.${_curformat}; \
	${PKG_CREATE} -v -f ${.OBJDIR}/PLIST.${_curformat} \
		-p ${DESTDIR} -s $$PKGSRCDIR \
		-c -"FDP ${.CURDIR:T} ${_curformat} package" \
		-d -"FDP ${.CURDIR:T} ${_curformat} package" ${.TARGET} || \
			(${RM} -fr ${.TARGET} PLIST.${_curformat} && false); \
	${RM} -rf ${.OBJDIR}/pkg

.if !defined(_cff) || empty(_cff)
package-${_curformat}: ${PACKAGES}/${.CURDIR:T}.${LANGCODE}.${_curformat}.${PKG_SUFFIX}
.else
.for i in ${_cff}
.if !empty(__curformat:$i)
package-${_curformat}: ${PACKAGES}/${.CURDIR:T}.${LANGCODE}.${_curformat}.${PKG_SUFFIX}
.else
package-${_curformat}:
.endif
.endfor
.endif

.endfor

.if ${LOCAL_CSS_SHEET} != ${CSS_SHEET}
${LOCAL_CSS_SHEET}: ${CSS_SHEET}
	${RM} -f ${.TARGET}
	${CAT} ${.ALLSRC} > ${.TARGET}
.if defined(CSS_SHEET_ADDITIONS)
	${CAT} ${.CURDIR}/${CSS_SHEET_ADDITIONS} >> ${.TARGET}
.endif
.endif
