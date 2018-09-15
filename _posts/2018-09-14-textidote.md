---
layout: post
title: Texitdote un vérificateur orthographique pour Latex
author: Olivier Bonaventure
---

De nombreux étudiants utilisent Latex pour rédiger leurs rapports et travaux de fin d'études. Dans de nombreuses disciplines scientifiques et en informatique, Latex reste l'outil de choix pour la rédaction de documents. Cependant, durant les dernières années, les correcteurs orthographiques et grammaticaux de logiciels tels que Word ou LibreOffice se sont fortement améliorés, alors que bon nombre de documents Latex sont écrits dans des éditeurs simples.


[Sylvain Hallé](https://github.com/sylvainhalle/) a résolu ce problème avec son logiciel baptisé [Textidote](https://sylvainhalle.github.io/textidote/). Textidote est écrit en Java. Il intègre plusieurs logiciels qui permettent de valider la structure d'un document Latex, mais aussi l'orthographe et la grammaire. Ces dernières vérifications sont réalisées par [LanguageTool](https://languagetool.org/) qui supporte l'anglais, le français et aussi l'allemand. Pour chaque langue, des centaines de règles permettent de détecter les erreurs les plus fréquentes. Textidote est également disponible via [https://github.com/sylvainhalle/textidote](https://github.com/sylvainhalle/textidote)

La meilleure façon d'utiliser [Textidote](https://sylvainhalle.github.io/textidote/) est de l'intégrer systématiquement dans le Makefile qui permet de compiler le document. De cette façon, la vérification orthographique et grammaticale est toujours effectuée. Il suffit pour cela de prendre l'habitude d'ajouter dans dictionnaire local les noms propres et autres exceptions que [Textidote](https://sylvainhalle.github.io/textidote/) doit ignorer.

```makefile
.PHONY: all clean dist print

P = paper

default : $P.pdf

$P.pdf  : $(wildcard *.tex *.bib figures/*)
	pdflatex --shell-escape $P
	bibtex $P
	pdflatex --shell-escape $P
	pdflatex --shell-escape $P

check: $(wildcard *.tex *.bib figures/*)
	textidote --dict dict.txt --check en_uk --html $P.tex  > $P.html


```

Le `Makefile` ci-dessus est prévu pour un document en anglais. Il suffit de remplacer `en_uk` par `fr` pour valider un document en français.
