<!-- $FreeBSD$ -->

<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY freebsd.dsl PUBLIC "-//FreeBSD//DOCUMENT DocBook Language Neutral Stylesheet//EN" CDATA DSSSL>
<!ENTITY % lang.zhcn.dsssl "IGNORE">
]>

<style-sheet>
  <style-specification use="docbook">
    <style-specification-body>
      <![ %lang.zhcn.dsssl; [
	(define %gentext-language% "zhcn")
      ]]>

	<!-- Convert " ... " to �� ... �� in the HTML output. -->
	(element quote
	  (make sequence
	    (literal "��")
	    (process-children)
	    (literal "��")))
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
		(list (normalize "bibliography") "%t")
		(list (normalize "book")        "%t")
		(list (normalize "chapter")     (if %chapter-autolabel%
						    "�� %n ��"
						    "%t ����"))
		(list (normalize "equation")    "��ʽ %n")
		(list (normalize "example")     "�� %n")
		(list (normalize "figure")      "ͼ %n")
		(list (normalize "glossary")    "%t")
		(list (normalize "index")       "%t")
		(list (normalize "listitem")    "%n")
		(list (normalize "part")        "�� %n ����")
		(list (normalize "preface")     "%t")
		(list (normalize "procedure")   "���� %n, %t")
		(list (normalize "reference")   "�ο����� %n, %t")
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
		(list (normalize "sidebar")     "��ʾ %t")
		(list (normalize "step")        "�� %n ��")
		(list (normalize "table")       "�� %n")))
      (define %html-header-tags% '(("META" ("HTTP-EQUIV" "Content-Type") ("CONTENT" "text/html; charset=GB2312")))) 
    </style-specification-body>
  </style-specification>

  <external-specification id="docbook" document="freebsd.dsl">
</style-sheet>
