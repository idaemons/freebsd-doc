<!--	$FreeBSDde: de-docproj/share/sgml/freebsd.dsl,v 1.4 2001/01/06 18:15:53 alex Exp $
	$FreeBSD: doc/de_DE.ISO_8859-1/share/sgml/freebsd.dsl,v 1.3 2001/01/06 18:16:18 alex Exp $ -->

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
                (literal "Wenn Sie Fragen zu FreeBSD haben, schicken Sie eine EMail an <")
                (make element gi: "a"
                      attributes: (list (list "href" "mailto:de-bsd-questions@de.FreeBSD.org"))
                  (literal "de-bsd-questions@de.FreeBSD.org"))
                (literal ">.")
                (make empty-element gi: "br")
                (literal "Wenn Sie Fragen zu dieser Dokumentation haben, schicken Sie eine Email an <")
                (make element gi: "a"
                      attributes: (list (list "href" "mailto:de-bsd-translators@de.FreeBSD.org"))
                  (literal "de-bsd-translators@de.FreeBSD.org"))
	        (literal ">.")))))
      ]]>
    </style-specification-body>
  </style-specification>

  <external-specification id="docbook" document="freebsd.dsl">
</style-sheet>
