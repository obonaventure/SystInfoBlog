---
layout: post
title: Un style cohérent pour votre projet en C
author: Olivier Bonaventure
---

Lorsque plusieurs étudiants collaborent à l'écriture d'un programme
en C, ils utilisent souvent des conventions différentes pour
placer les place accolades, documenter les fonctions, un nombre
variable d'espaces pour les tabulations, ... La lecture du code
source peut parfois même devenir difficile si les étudiants n'utilisent
aucune convention.

Les grands projets open-source ont défini des conventions strictes
pour l'écriture du code source, allant même à avoir des logiciels
spécialisés pour valider le respect de leurs propres conventions. Les
conventions de codage sont comme les goûts et les couleurs, elles
ne se discutent pas. Par contre, il est important d'utiliser
la même convention dans tout le code source d'un même projet.

Heureusement, il existe des logiciels qui permettent de reformater du
code source de façon à ce que celui-ci respecte une convention donnée.
[clang-format](https://clang.llvm.org/docs/ClangFormat.html) est un
de ces logiciels qui est bien adapté au code source en C.

Il s'installe facilement sur Linux et s'utilise facilement en ligne
de commande. A titre d'exemple, prenons le code source suivant:

```c
#include <stdio.h>

int main(int arg, char **argv)
{
  printf("Start \n");
      int i=3;
  while(1) { i+=i;  }
  printf("End \n");
               }

```

Utilisé sans aucun argument,
[clang-format](https://clang.llvm.org/docs/ClangFormat.html) 
retourne sur la sortie standard une version "propre" du code source se trouvant
dans le fichier passé en argument.

```
# clang-format /tmp/test.c
#include <stdio.h>

int main(int arg, char **argv) {
  printf("Start \n");
  int i = 3;
  while (1) {
    i += i;
  }
  printf("End \n");
}

```

[clang-format](https://clang.llvm.org/docs/ClangFormat.html) supporte
différents style de code source:

 - `llvm` pour le style utilisé par le compilateur clang
 - `chromium` pour le style utilisé pour le code source du navigateur chrome
 - `mozilla` pour le style de la fondation mozilla

Ces styles sont prédéfinis dans
[clang-format](https://clang.llvm.org/docs/ClangFormat.html). Il est
aussi possible de les adapter pour obtenir le style que vous préférez.

```
clang-format -style=mozilla -dump-config > .clang-format
```

Le fichier `.clang-format` contient toutes les règles du style `mozilla`.
C'est un fichier texte qui peut être modifié si nécessaire. Vous trouverez
des définitions de style dans de nombreux projets open-source, comme
par exemple celui utilisé par le
[noyau Linux](https://github.com/torvalds/linux/blob/master/.clang-format).

En plaçant ce fichier de style à la racine de votre projet, vous pouvez
demander à clang-format de reformater tous vos fichiers `.c` et `.h` avec
la commande suivante :

```
# find . -regex '.*\.\(c\|h\)' -exec clang-format -style=file -i {} \;
```


