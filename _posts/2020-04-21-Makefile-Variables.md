---
layout: post
title: Makefiles et Variables Magiques?
author: Christophe Kafrouni
---

Au cas où vous n'avez toujours pas eu l'occasion de faire vos premiers pas avec cet outil très puissant, laissez-moi vous introduire au Makefile.

Un Makefile est un fichier contenant toutes les commandes que l'on aurait typiquement tapé dans le terminal pour compiler et lancer certaines parties de notre code. Les stocker dans ce fichier nous permet d'accéder à ces commandes en tapant simplement la commande **`make`** suivie de potentiels methodes.

Ce sera plus simple à comprendre une fois que l'on se lance dans les exemples.


# Les Bases

Imaginons un repertoire très basique :

**Tuto-Makefile**<br>
|- main.c<br>
|- addition.c<br>
|- multiplication.c<br>
|- Makefile<br>

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
#include "addition.h"    | #include "multiplication.h"
                         |
int add(int a, int b) {  | int mult(int a, int b){
    return a+b;          | return a * b;
}                        | }
```
Avec les fichiers ***.h** suivants :
```c
#ifndef ADDITION_H       | #ifndef MULTIPLICATION_H
#define ADDITION_H       | #define MULTIPLICATION_H
                         |
int add(int a, int b);   | int mult(int a, int b);
#endif                   | #endif
```

Pour un exemple pareil on pourrait bien taper chaque commande à chaque fois que l'on veut compiler notre programme **main**. 

Mais on peut y arriver en mettant les commandes dans le Makefile de cette manière :
```makefile
main: addition.o multiplication.o
    gcc -o main addition.o multiplication.o

addition.o: addition.c addition.h
    gcc -c addition.c

multiplication.o: multiplication.c multiplication.h
    gcc -c multiplication.c
```
Le fait d'écrire les ***règles*** de compilation de cette manière nous permet d'uniquement passer la commande `make` qui effectuera les trois opérations.

À savoir, la syntaxe est très importante, en effet le premier élément avant **" : "** est le **target** (cible) et ceux après sont les dépendances. Cela servira donc à l'outil make pour comprendre de quelle manière il doit procéder pour compiler le programme. *Main* ne sera donc compilé qu'une fois les fichiers objets **.o* générés.
A la ligne suivante, le Makefile utilise l'indentation via une tabulation pour indiquer toutes les commandes à exécuter pour une cible donnée.

***Attention: la tabulation à la deuxième ligne est très importante pour la commande make!***

# Variables dans les Makefiles?

Pour l'instant, nous avons abordé la manière la plus basique d'écrire un Makefile. Pour chaque fichier on a dû écrire deux lignes. Pas très pratique tout ça. De plus, lorsque l'on compare les différentes lignes, on remarque qu'il y a beaucoup de répétitions, par exemple la commande `gcc`. Il suffit de vouloir changer de compilateur ( par exemple "[clang](https://clang.llvm.org/docs/CommandGuide/clang.html)" ) pour voir que l'on devra changer toutes les lignes où l'on trouve "gcc".

On peut y remédier avec l'utilisation de variables comme dans nos programmes. On rajoute en haut de notre fichier toutes nos variables, et on peut y accéder comme dans le terminal avec la syntaxe $( *variable* ) :
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

Pour plus d'informations en ce qui concerne les flags que l'on peut passer au compilateur [GCC](http://man7.org/linux/man-pages/man1/gcc.1.html) je vous redirige vers un autre post: [Quelques flags utiles pour la compilation]({{ site.baseurl }}/gcc-flags/)


# Et les Variables Magiques ?
Le Makefile vient encore à notre secours car on a bien optimisé notre fichier, mais il y a encore beaucoup trop de lignes à mon goût, étant donné toutes les répétions, en l'occurence la dépendance et la cible apparaissent aussi dans les commandes.

J'introduis donc les variables magiques :
* `$@` permet d'accéder au nom de la *target* (cible)
* `$^` permet d'accéder aux noms des *dépendances* ( les fichiers après ":" )
* `$<` permet d'accéder au nom du premier fichier à la droite du ":"

Un exemple s'impose:
```makefile
# ...

main: addition.o multiplication.o
    $(CC) $(CFlags) -o $@ $^

addition.o: addition.c addition.h
    $(CC) $(CFlags) -c $<

multiplication.o: multiplication.c multiplication.h
    $(CC) $(CFlags) -c $<
```
On peut d'autant plus voir les similitudes entres les lignes. Il y a sûrement une meilleure méthode pour écrire tout ça, non?

**Oui !!**

Avec le signe **%** . On ne doit plus réécrire les noms, et en une ligne on peut réécrire toutes les commandes servant à générer des fichier objets *.o.
```makefile
# ...

main: addition.o multiplication.o
    $(CC) $(CFlags) -o $@ $^

%.o: %.c %.h
    $(CC) $(CFlags) -c $<
```
# Des commandes supplémentaires?

On va commencer par ma commande préférée. 

**`make clean`**. Pour nettoyer! (pour effacer en une commande tous les fichier générés, l'exécutable **main**, les fichiers objets ***.o** et à peu près tout ce que l'on veut)

On peut donc rajouter à la fin du fichier :
```makefile
clean:
    rm -f main *.o # Le flag -f sert à ne pas faire échouer la commande `rm` dans le cas où il n'y a pas de fichier `main`
    rm -f *.xml  # Utile pour les fichiers générés par valgrind et cppcheck
    # rm ...
```

Vous l'avez donc deviné, on peut donc créer toute sorte de séquences de commandes exécutables en tapant `make <tartget-name>`

## Tests Unitaires

En suivant ce que l'on a appris au point précédent, on peut créer une commande chargée d'effectuer tous nos tests avec par exemple **`make test`**

On a donc besoin d'un fichier pour nos "units tests".
Notre répertoire ressemble maintenant à :

**Tuto-Makefile**<br>
|- main.c<br>
|- addition.c<br>
|- multiplication.c<br>
|- Makefile<br>
|- UnitTest.c<br>

On peut donc rajouter dans le Makefile
```makefile
CUnit = -lcunit

# ...

test: UnitTest.o addition.o multiplication.o
    $(CC) -o test $^ $(CUnit)
    ./test
    make clean
```
On se rappelle que tous les fichiers *.o sont pris en charge par la commande vue plus haut. Donc pas besoin de rajouter une règle pour générer le fichier UnitTest.o supplémentaire.

On n'oublie pas de rajouter une variable (CUnit = -lcunit) pour les flags requis par la librairie "CUnit".

Pour récapituler, la commande **`make test`** compile le fichier test, puis l'exécute, et finit par nettoyer le répertoire de tous les fichiers générés.

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
    rm -f *.xml  # Utile pour les fichiers générés par valgrind et cppcheck
    # rm ...

```

Vous pouvez télécharger tous les fichiers créés dans cet article  [ici]({{site.github.repository_url}}/tree/master/images/makefile_post).

Merci pour votre lecture !