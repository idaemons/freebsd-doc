#
# $FreeBSD$
#
# This include file <doc.project.mk> is the FreeBSD Documentation Project 
# co-ordination make file.
#
# This file includes the other makefiles, which contain enough
# knowledge to perform their duties without the system make files.
#

# ------------------------------------------------------------------------
#
# Document-specific variables:
#
#	DOC		This _must_ be set if there is a document to
#			build.  It should be without prefix.
#
#	DOCFORMAT	Format of the document.  Defaults to docbook.
#			docbook is also the only option currently.
#
# 	MAINTAINER	This denotes who is responsible for maintaining
# 			this section of the project.  If unset, set to
# 			doc@FreeBSD.org
#

# ------------------------------------------------------------------------
#
# User-modifiable variables:
#
#	PREFIX		Standard path to document-building applications
#			installed to serve the documentation build
#			process, usually by installing the docproj port
#			or package.  Default is /usr/local
#
#	NOINCLUDEMK	Whether to include the standard BSD make files,
#			or just to emulate them poorly.  Set this if you
#			aren't on FreeBSD, or a compatible sibling.  By
#			default is not set.
#

# ------------------------------------------------------------------------
#
# Make files included:
#
#	doc.install.mk	Installation specific information, including
#			ownership and permissions.
#
#	doc.subdir.mk	Subdirectory related configuration, including
#			handling "obj" builds.
#
# DOCFORMAT-specific make files, like:
#
#	doc.docbook.mk	Building and installing docbook documentation.
#			Currently the only method.
#

# Document-specific defaults
DOCFORMAT?=	docbook
MAINTAINER?=	doc@FreeBSD.org

# User-modifiable
PREFIX?=	/usr/local
PRI_LANG?=	en_US.ISO_8859-1

# Format-specific configuration
.if defined(DOC)
.if ${DOCFORMAT} == "docbook"
.include "doc.docbook.mk"
.endif
.endif

# Subdirectory glue and ownership information.
.include "doc.subdir.mk"
.include "doc.install.mk"
