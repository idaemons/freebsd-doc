#
# $FreeBSD$
#
# This include file <doc.slides.mk> handles building and installing of
# DocBook Slides in the FreeBSD Documentation Project.
#
# Documentation using DOCFORMAT=slides is expected to be marked up
# according to the DocBook slides DTD.
#
# PDF and HTML output formats are currently supported.
#

# ------------------------------------------------------------------------
#
# Document-specific variables
#
#	DOC		This should be set to the name of the SLIDES
#			marked-up file, without the .xml suffix.
#			
#			It also determins the name of the output files
#			for print output :  ${DOC}.pdf 
#
#	DOCBOOKSUFFIX	The suffix of your document, defaulting to .xml
#

DOCBOOKSUFFIX?=	xml
MASTERDOC?=	${.CURDIR}/${DOC}.${DOCBOOKSUFFIX}

KNOWN_FORMATS=	html pdf

CSS_SHEET?=

SLIDES_XSLDIR=	/usr/local/share/xsl/slides/xsl/
SLIDES_XSLHTML= ${SLIDES_XSLDIR}xhtml/default.xsl
SLIDES_XSLPRINT?= ${SLIDES_XSLDIR}fo/plain.xsl

# Loop through formats we should build.
.for _curformat in ${FORMATS}
_cf=${_curformat}

# Create a 'bogus' doc for any format we support or not.  This is so
# that we can fake up a target for it later on, and this target can print
# the warning message about the unsupported format. 
_docs+= ${DOC}.${_curformat}
CLEANFILES+= ${DOC}.${_curformat}

.if ${_cf} == "pdf"
CLEANFILES+= ${DOC}.fo ${DOC}.pdf 
.if ! defined (USE_FOP) && ! defined (USE_XEP)
CLEANFILES+= ${DOC}.aux ${DOC}.log ${DOC}.out texput.log
.endif
.endif

.endfor

XSLTPROCFLAGS?=	--nonet
XSLTPROCOPTS=	${XSLTPROCFLAGS}

.MAIN: all

all: ${_docs}

${DOC}.html: ${SRCS}
	${XSLTPROC} ${XSLTPROCOPTS} ${SLIDES_XSLHTML} ${.ALLSRC}

${DOC}.fo: ${SRCS}
	${XSLTPROC} ${XSLTPROCOPTS} ${SLIDES_XSLPRINT} ${.ALLSRC} > ${.TARGET:S/.pdf$/.fo/}

${DOC}.pdf: ${DOC}.fo
.if defined(USE_FOP)
	${FOP_CMD} ${.TARGET:S/.pdf$/.fo/} ${.TARGET}
.elif defined(USE_XEP)
	${XEP_CMD} ${.TARGET:S/.pdf$/.fo/} ${.TARGET}
.else
	${PDFTEX_CMD} --interaction nonstopmode "&pdfxmltex" ${.TARGET:S/.pdf$/.fo/}
.endif
