---
layout: post
title: Makefiles et Variables Magiques?
author: Christophe Kafrouni
---

Au cas où vous n'avez toujours pas eu l'occasion de faire vos premiers pas avec cet outil très puissant, laissez-moi vous introduire au Makefile.<br>
Un Makefile est un fichier contenant toutes les commandes que l'on aurait typiquement tapé dans le terminal pour compiler et lancer certaines parties de notre code. Les stocker dans ce fichier nous permet d'accéder à ces commandes en tapant simplement la commande **`make`** suivie de potentiels methodes.<br>
Ce sera plus simple à comprendre une fois que l'on se lance dans les examples..


# Les Basics

Imaginons un repertoire très basique :

>**Tuto-Makefile**
>>main.c<br>
>>addition.c<br>
>>multiplication.c<br>
>>Makefile

Où **main.c** est le fichier :
```c
#include "addition.h"
#include "multiplication.h"
int main() {
    int x = add(5, 10); // provient de "addition.h"
    int y = mult(5, 10); // provient de "multiplication.h"
    return 0;
}
```
Où **addition.c** et **multiplication.c** :
```c
#include "addition.h"	 | #include "multiplication.h"
						 |
int add(int a, int b) {  | int mult(int a, int b){
    return a+b;			 |     return a * b;
}						 | }
```
Avec les fichiers ***.h** suivants :
```c
#ifndef ADDITION_H		 | #ifndef MULTIPLICATION_H
#define ADDITION_H		 | #define MULTIPLICATION_H
						 |
int add(int a, int b);   | int mult(int a, int b);
#endif					 | #endif
```

Pour un exemple pareil on pourrait bien taper chaque commande à chaque fois que l'on veut compiler notre programme **main**. <br>
Mais on peut y arriver en mettant les commandes dans le Makefile de cette manière :
```makefile
main: addition.o multiplication.o
	gcc -o main addition.o multiplication.o

addition.o: addition.c addition.h
	gcc -c addition.c

multiplication.o: multiplication.c multiplication.h
	gcc -c multiplication.c
```
Le fait d'écrire les ***règles*** de compilation de cette manière nous permet d'uniquement passer la commande `make` qui effectuera les trois opérations. <br>
À savoir, la syntaxe est très importante, en effect le première élément avant **" : "** est le **target** et ceux après sont les dependances. Cela servira donc à l'outils make pour comprendre de quel manière il doit procéder aux compilations. *Main* ne sera donc compilé qu'une fois les fichiers objects **.o* générés.

***Attention: la tabulation à la deuxième ligne est très importante pour la commande make!***

# Variables dans les Makefiles?

Pour l'instant, nous avons abordé la manière la plus basique d'écrire un makefile. pour chaque fichier on a du écrire deux lignes.. Pas très pratique tout ça. De plus que lorsque l'on compare les différentes lignes, on remarque qu'il y a beaucoup de répétions. Il suffit de vouloir changer de compilateur ( par exemple "[clang](https://clang.llvm.org/docs/CommandGuide/clang.html)" ) pour voir que l'on devra changer toutes les lignes où l'on trouve "gcc".<br>
On peut y remédier avec l'utilisation de variables comme dans nos programmes. On rajoute en haut de notre fichier toutes nos variables, et on peut les accéder comme dans le terminal avec $( *variable* ) :
```makefile
CC = gcc
CFlags = -g -Wall -Werror

main: addition.o multiplication.o
	$(CC) $(CFlags) -o main addition.o multiplication.o

addition.o: addition.c addition.h
	$(CC) $(CFlags) -c addition.c

multiplication.o: multiplication.c multiplication.h
	$(CC) $(CFlags) -c multiplication.c
```

Pour plus d'informations en ce qui concerne les flags que l'on peut passé au compilateur [GCC](http://man7.org/linux/man-pages/man1/gcc.1.html) je vous redirige vers un autre post: [Quelques flags utiles pour la compilation](https://ucl-ingi.github.io/LEPL1503-Blog/gcc-flags/)


# Et les Variables Magiques ??
Le Makefile vient encore à notre secours car on a bien optimisé notre fichier, mais il y a encore beaucoup trop de lignes à mon goût, étant donné toutes les répétions.<br>
J'introduis donc les variables magiques :
* $@ permet d'accéder au nom du *target*
* $^ permet d'accéder aux noms des *dépendances* ( les fichiers après ":" )
* $< permet d'accéder au nom du premier fichier à la droite du ":"

Un example s'impose:
```makefile
# ...

main: addition.o multiplication.o
	$(CC) $(CFlags) -o $@ $^

addition.o: addition.c addition.h
	$(CC) $(CFlags) -c $<

multiplication.o: multiplication.c multiplication.h
	$(CC) $(CFlags) -c $<
```
On peut d'autant plus voir les similitudes entres les lignes. Il y a sûrement une meilleure méthode pour écrire tout ça?<br>
**Oui !!**<br>
Avec le signe **%** . On ne doit plus réécrire les noms, et en une ligne on peut réécrire toutes les commandes servant à générer des fichier objects __.o.
```makefile
# ...

main: addition.o multiplication.o
	$(CC) $(CFlags) -o $@ $^

%.o: %.c %.h
	$(CC) $(CFlags) -c $<
```
# Des commandes supplémentaire?

On va commencer par ma commande préférée. <br>
**`make clean`**. Pour nettoyer ! ( pour effacer en une commande tous les fichier générés, le fichier **main** et les fichiers objects **__.o** et à peut prés tout ce que l'on veut.<br>
On peut donc rajouter à la fin du fichier :
```makefile
clean:
	rm main *.o
	rm -f *.xml  # Utile pour les fichier générer par valgrind et cppcheck
	# rm ...
```

Vous l'avez donc deviné, on peut donc créer toutes sortes de commandes executables en tapant `make <tartget-name>`

## UnitTests

En suivant ce que l'on a appris au point suivant, on peut créer une commande chargée d'effectuer tous nos tests avec par example **`make test`**<br>
On a donc besoin d'un fichier pour nos "units tests".
Notre répertoire ressemble maintenant à :

>**Tuto-Makefile**
>>main.c<br>
>>addition.c<br>
>>multiplication.c<br>
>>Makefile<br>
>>UnitTest.c

On peut donc rajouter
```makefile
CUnit = -lcunit

# ...

test: UnitTest.o addition.o multiplication.o
	$(CC) -o test $^ $(CUnit)
	./test
	make clean
```
On se rappelle que tous les fichiers __.o sont pris en charge par la commande vu plus haut. Donc pas besoins de rajouter une règle pour générer le fichier UnitTest.o supplémentaire.<br>
On n'oublis pas de rajouter une variable pour les flags requis par la librairie "CUnit".<br>
Pour récapituler, la commande **`make test`** compile le fichier test, puis l'exécute, et finis par nettoyer le répertoire de tous les fichiers générés.

## [CppCheck](http://cppcheck.sourceforge.net/) & [Valgrind](http://man7.org/linux/man-pages/man1/valgrind.1.html)

Comme pour **`make clean`** et **`make test`** , on peut créer une commande **`make allChecks`**  qui se chargera d'effectuer tous les checks nécessaires, Valgrind et CppCheck:
```makefile
allChecks:
	make main
	make CppCheckMake
	make ValgrindMake
```

Vous l'avez deviné, on a aussi besoin de commandes pour effectuer CppCheck et Valgrind.
* CppCheckMake
```makefile
CppCheckMake: *.c *.h
	cppcheck --enable=all --inconclusive $^ 2> cppcheck.json
```
* ValgrindMake
```makefile
ValgrindMake: main.c
	valgrind --xml=yes --xml-file="valgrind.xml" --leak-check=yes --track-origins=yes ./main
```

# Conclusion

À présent, le makefile ressemble à cela :

```makefile
CC = gcc
CFlags = -g -Wall -Werror
CUnit = -lcunit

# Main
main: addition.o multiplication.o
	$(CC) $(CFlags) -o $@ $^

%.o: %.c %.h
	$(CC) $(CFlags) -c $<

# Tests
test: UnitTest.o addition.o multiplication.o
	$(CC) -o test $^ $(CUnit)
	./test
	make clean

# Checks
CppCheckMake: *.c *.h
	cppcheck --enable=all --inconclusive $^ 2> cppcheck.json

ValgrindMake: main.c
	valgrind --xml=yes --xml-file="valgrind.xml" --leak-check=yes --track-origins=yes ./main

allChecks:
	make main
	make CppCheckMake
	make ValgrindMake

# Cleaning
clean:
	rm main *.o
	rm -f *.xml  # Utile pour les fichier générer par valgrind et cppcheck
	# rm ...

```

Vous pouvez télécharger tous les fichiers crée dans cet article [ici](https://github.com/KafrouniChris/kafrounichris.github.io/tree/master/_posts/Makefile-Material).


Merci pour votre lecture !
