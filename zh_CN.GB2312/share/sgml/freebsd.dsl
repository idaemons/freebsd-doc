<!-- $FreeBSD$ -->

<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY freebsd.dsl PUBLIC "-//FreeBSD//DOCUMENT DocBook Language Neutral Stylesheet//EN" CDATA DSSSL>
<!ENTITY % lang.zhcn.dsssl "IGNORE">
<!ENTITY % zhcn.words
  PUBLIC "-//Norman Walsh//ENTITIES DocBook Stylesheet Localization//ZHCN"
	 "dbl1zhcn.ent">
%zhcn.words;
]>

<style-sheet>
  <style-specification use="docbook">
    <style-specification-body>
      <![ %lang.zhcn.dsssl; [
	(define %gentext-language% "zhcn")
      ]]>

	<!-- Convert " ... " to �� ... �� in the HTML output. -->
	<!-- Work around the issue that the current DSL doesn't translate -->
	(define (gentext-en-nav-prev prev)
	  (make sequence (literal "��һҳ")))
	(define (gentext-en-nav-next next)
	  (make sequence (literal "��һҳ")))
	(define (gentext-en-nav-up up)
	  (make sequence (literal "����")))
	(define (gentext-en-nav-home home)
	  (make sequence (literal "��ҳ")))
	(define (en-xref-strings)
	  (list (list (normalize "appendix")    (if %chapter-autolabel%
							"��¼ %n"
							"��¼ %t"))
		(list (normalize "article")     (string-append %gentext-en-start-quote%
							"%t"
							%gentext-en-end-quote%))
		(list (normalize "bibliography")	"%t")
		(list (normalize "book")		"%t")
		(list (normalize "chapter")     (if %chapter-autolabel%
							"�� %n ��"
							"%t ����"))
		(list (normalize "equation")		"��ʽ %n")
		(list (normalize "example")		"�� %n")
		(list (normalize "figure")		"ͼ %n")
		(list (normalize "glossary")		"%t")
		(list (normalize "index")		"%t")
		(list (normalize "listitem")		"%n")
		(list (normalize "part")		"�� %n ����")
		(list (normalize "preface")		"%t")
		(list (normalize "procedure")		"���� %n, %t")
		(list (normalize "reference")		"�ο����� %n, %t")
		(list (normalize "section")     (if %section-autolabel%
							"�� %n ��"
							"%t С��"))
		(list (normalize "sect1")       (if %section-autolabel%
							"�� %n ��"
							"%t С��"))
		(list (normalize "sect2")       (if %section-autolabel%
							"�� %n ��"
							"%t С��"))
		(list (normalize "sect3")       (if %section-autolabel%
							"�� %n ��"
							"%t С��"))
		(list (normalize "sect4")       (if %section-autolabel%
							"�� %n ��"
							"%t С��"))
		(list (normalize "sect5")       (if %section-autolabel%
							"�� %n ��"
							"%t С��"))
		(list (normalize "simplesect")  (if %section-autolabel%
							"�� %n ��"
							"%t С��"))
		(list (normalize "sidebar")		"��ʾ %t")
		(list (normalize "step")		"�� %n ��")
		(list (normalize "table")		"�� %n")))
	(define (en-element-name)
	  (list (list (normalize "abstract")		"&Abstract;")
		(list (normalize "answer")		"&Answer;")
		(list (normalize "appendix")		"&Appendix;")
		(list (normalize "article")		"&Article;")
		(list (normalize "bibliography")	"&Bibliography;")
		(list (normalize "book")		"&Book;")
		(list (normalize "calloutlist")	"")
		(list (normalize "caution")		"&Caution;")
		(list (normalize "chapter")		"&numbercn;")
		(list (normalize "copyright")		"&Copyright;")
		(list (normalize "dedication")		"&Dedication;")
		(list (normalize "edition")		"&Edition;")
		(list (normalize "equation")		"&Equation;")
		(list (normalize "example")		"&Example;")
		(list (normalize "figure")		"&Figure;")
		(list (normalize "glossary")		"&Glossary;")
		(list (normalize "glosssee")		"&GlossSee;")
		(list (normalize "glossseealso")	"&GlossSeeAlso;")
		(list (normalize "important")		"&Important;")
		(list (normalize "index")		"&Index;")
		(list (normalize "colophon")		"&Colophon;")
		(list (normalize "setindex")		"&SetIndex;")
		(list (normalize "isbn")		"&isbn;")
		(list (normalize "legalnotice")		"&LegalNotice;")
		(list (normalize "msgaud")		"&MsgAud;")
		(list (normalize "msglevel")		"&MsgLevel;")
		(list (normalize "msgorig")		"&MsgOrig;")
		(list (normalize "note")		"&Note;")
		(list (normalize "part")		"&Part;")
		(list (normalize "preface")		"&Preface;")
		(list (normalize "procedure")		"&Procedure;")
		(list (normalize "pubdate")		"&Published;")
		(list (normalize "question")		"&Question;")
		(list (normalize "refentry")		"&RefEntry;")
		(list (normalize "reference")		"&Reference;")
		(list (normalize "refname")		"&RefName;")
		(list (normalize "revhistory")		"&RevHistory;")
		(list (normalize "refsect1")		"&RefSection;")
		(list (normalize "refsect2")		"&RefSection;")
		(list (normalize "refsect3")		"&RefSection;")
		(list (normalize "refsynopsisdiv")	"&RefSynopsisDiv;")
		(list (normalize "revision")		"&Revision;")
		(list (normalize "sect1")		"&numbercn;")
		(list (normalize "sect2")		"&numbercn;")
		(list (normalize "sect3")		"&numbercn;")
		(list (normalize "sect4")		"&numbercn;")
		(list (normalize "sect5")		"&numbercn;")
		(list (normalize "section")		"&numbercn;")
		(list (normalize "simplesect")		"&numbercn;")
		(list (normalize "seeie")		"&See;")
		(list (normalize "seealsoie")		"&Seealso;")
		(list (normalize "set")			"&Set;")
		(list (normalize "sidebar")		"&Sidebar;")
		(list (normalize "step")		"&step;")
		(list (normalize "table")		"&Table;")
		(list (normalize "tip")			"&Tip;")
		(list (normalize "toc")			"&TableofContents;")
		(list (normalize "warning")		"&Warning;")))
	(define (en-label-title-sep)
	  (list (list (normalize "abstract")		": ")
		(list (normalize "answer")		" ")
		(list (normalize "appendix")		". ")
		(list (normalize "caution")		"")
		(list (normalize "chapter")		" &Chapter;. ")
		(list (normalize "equation")		". ")
		(list (normalize "example")		". ")
		(list (normalize "figure")		". ")
		(list (normalize "footnote")		". ")
		(list (normalize "glosssee")		": ")
		(list (normalize "glossseealso")	": ")
		(list (normalize "important")		": ")
		(list (normalize "note")		": ")
		(list (normalize "orderedlist")		". ")
		(list (normalize "part")		". ")
		(list (normalize "procedure")		". ")
		(list (normalize "prefix")		". ")
		(list (normalize "question")		" ")
		(list (normalize "refentry")		"")
		(list (normalize "reference")		". ")
		(list (normalize "refsect1")		". ")
		(list (normalize "refsect2")		". ")
		(list (normalize "refsect3")		". ")
		(list (normalize "sect1")		" &Section;. ")
		(list (normalize "sect2")		" &Section;. ")
		(list (normalize "sect3")		" &Section;. ")
		(list (normalize "sect4")		" &Section;. ")
		(list (normalize "sect5")		" &Section;. ")
		(list (normalize "section")		" &Section;. ")
		(list (normalize "simplesect")		" &Section;. ")
		(list (normalize "seeie")		" ")
		(list (normalize "seealsoie")		" ")
		(list (normalize "step")		". ")
		(list (normalize "table")		". ")
		(list (normalize "tip")			": ")
		(list (normalize "warning")		": ")))
    </style-specification-body>
  </style-specification>

  <external-specification id="docbook" document="freebsd.dsl">
</style-sheet>
