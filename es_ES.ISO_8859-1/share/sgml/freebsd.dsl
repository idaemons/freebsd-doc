<!-- $FreeBSD: doc/es_ES.ISO_8859-1/share/sgml/freebsd.dsl,v 1.2 2000/09/28 23:29:45 nbm Exp $ -->

<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY freebsd.dsl PUBLIC "-//FreeBSD//DOCUMENT DocBook Language Neutral Stylesheet//EN" CDATA DSSSL>
]>

<style-sheet>
  <style-specification use="docbook">
    <style-specification-body>
 
      <![ %output.html; [ 
	(define ($email-footer$)
          (make sequence
            (make element gi: "p"
                  attributes: (list (list "align" "center"))
              (make element gi: "small"
                (literal "This, and other documents, can be downloaded from ")
                (make element gi: "a"
                      attributes: (list (list "href" "ftp://ftp.FreeBSD.org/pub/FreeBSD/doc"))
                  (literal "ftp.FreeBSD.org/pub/FreeBSD/doc/"))
                (literal ".")))
            (make element gi: "p"
                  attributes: (list (list "align" "center"))
              (make element gi: "small"  
                (literal "For questions about FreeBSD, read the ")
                (make element gi: "a"
                      attributes: (list (list "href" "http://www.freebsd.org/docs.html"))
                  (literal "documentation"))
                (literal " before contacting <")
                (make element gi: "a"
                      attributes: (list (list "href" "mailto:questions@FreeBSD.org"))
                  (literal "questions@FreeBSD.org"))
                (literal ">.")
                (make empty-element gi: "br")
                (literal "For questions about this documentation, e-mail <")
                (make element gi: "a"
                      attributes: (list (list "href" "mailto:doc@FreeBSD.org"))
                  (literal "doc@FreeBSD.org"))
                (literal ">.")))))
      ]]>
    </style-specification-body>
  </style-specification>

  <external-specification id="docbook" document="freebsd.dsl">
</style-sheet>
