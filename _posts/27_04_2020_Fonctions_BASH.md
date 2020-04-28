# Fonctions en BASH

Vous avez sûrement déjà perdu patience à retaper « bêtement » des instructions dans votre terminal. Bien qu’existent des [raccourcis][5] (EX : fléche du haut) pour récupérer des instructions précédentes, ici est proposé une solution plus générale et modulable : **Les fonctions en language BASH**. Elles constituent un moyen efficace pour effectuer des commandes groupées qui doivent être répétées. 

[5]: https://ucl-ingi.github.io/LEPL1503-Blog/arrows/

## Le format

Le format d'une fonction en BASH est le suivant : 
```bash
func(){
     <commands>
}
```

## Les arguments

Il est bien sûr possible de passer des arguments à une fonction. Les arguments de la fonction doivent être fournis directement après le nom de la fonction. Par exemple,
```bash
func arg1 arg2
```
A l'intérieur des fonctions, les arguments sont accessibles par **"$1"**, **"$2"**, ...

**ATTENTION:** *les arguments ne doivent pas être indiqués dans les paranthèses lors de la définition de la fonction.*

## Boucle FOR

Au sein de ces fonctions, il est possible d'inclure bon nombre de structures d'instructions bien connues. Les **boucles FOR**, par exemple, suivent la syntaxe suivante : 
```bash
for var in <list>
do
<commands>
done
```
Ici, les éléments de la liste sont assignés, les uns après les autres, à la variable `var`. A chaque itération, les commandes entre `do` et `done` sont executées.

**REMARQUE:** *Ici les [listes][6] ont été introduites. En bash, une liste est initialisée en enfermant entre paranthèses ses éléments, séparés d'un espace.*
```
array = (input1.txt input2.txt input3.txt)
```
*Les éléments sont individuellement accessibles avec la syntaxe habituelle des listes. Pour référer à la liste en entier ou à un élément particulier de celle-ci:*
```
${array[0]} -> input1.txt 
${array[1]} -> input2.txt 
${array[2]} -> input3.txt
${array[*]} -> input1.txt input2.txt input3.txt
```

[6]: https://www.linuxjournal.com/content/bash-arrays

## L'exemple

Voici un exemple concret lié à la réalisation de notre projet. La fonction **`timing`** prenant comme argument le nombre de threads de calcul indique le temps d'execution *(ainsi que d'autres mesures utiles)* de l'executable **`fact`** pour différents fichiers d'entrée.
```bash
timing(){
	make fact
	
	./fact -N "$1" input1.txt output.txt
	
	array=(input1.txt input2.txt input3.txt)
	for i in ${array[*]}
	do
	echo Time : "$i" with "$1" threads
	command time -f "Real elapsed time [s] \t %e \nMax portion of RAM occupied [Kbytes] \t %M\n" ./fact -N "$1" "$i" output.txt
	done
	
	make clean
}
```
Quelques commentaires :
* Avant de prendre des mesures sur l'executable `fact`, il est recommandé de l'executer une première fois. *(Fact se trouve alors dans la cache du [filesystem][1])*. Ceci permet d'éviter que systématiquement la première exécution soit plus lente que les autres.
* La commande `command` permet d'écraser le mot clé `time` fourni par le shell bash au profit de la [véritable commande][3] `time` davantage modulable. *Petit test:* `type time` *VS* `type command type` *dans votre terminal.*

[1]: https://docs.oracle.com/cd/E19424-01/820-4811/anobm/index.html
[2]: https://askubuntu.com/questions/434289/why-doesnt-the-time-command-work-with-any-option
[3]: http://man7.org/linux/man-pages/man1/time.1.html

## En pratique
Il y a en pratique deux "voies" pour définir des fonctions en BASH.

###  Dans le terminal
Il est possible de définir directement une fonction dans votre terminal. Neanmoins, ceci implique que votre fonction ne sera pas sauvegardée à long terme.

### Dans un fichier .sh
Il est donc préférable de l'insérer dans un fichier .sh, autrement appelé **script**. Repenant l'exemple ci-dessus, voici le contenu du fichier **`timing.sh`** *(situé dans le même répertoire que votre Makefile)* où la fonction `timing` est executée 3 fois avec un nombre de threads de calcul croissant.
```bash
#!/bin/bash

timing(){
	make fact
	
	./fact -N "$1" input1.txt output.txt
	
	array=(input1.txt input2.txt input3.txt)
	for i in ${array[*]}
	do
	echo Time : "$i" with "$1" threads
	command time -f "Real elapsed time [s] \t %e \nMax portion of RAM occupied [Kbytes] \t %M\n" ./fact -N "$1" "$i" output.txt
	done
	
	make clean
}

timing 1
timing 2
timing 4
```
**PRATIQUE:** *Voici [un debugger][4] pour corriger de manière interactive vos scripts.*

[4]: https://www.shellcheck.net/

Pour exectuer le fichier **`timing.sh`** : 
```bash
./timing.sh
```
**ASTUCE:** *Il est probable que vous aillez à modifier les permissons (ici, d'execution) du fichier créé. Il suffit d'entrer la commande* `chmod +x timing.sh` *pour rendre l'execution du fichier .sh accessible.  La commande* `ls -l` *permet de vérifier la bonne execution de l'opération.*


Bien entendu, ceci n'est qu'une introduction aux fonctions en BASH et celle-ci n'attend qu'à être approfondie. Je vous invite vivement à vous documenter pour dénicher peut-être d'autres astuces facilitant encore davantage l'execution de commandes.


Sources:
* https://www.shellscript.sh/functions.html
* https://ryanstutorials.net/bash-scripting-tutorial/bash-functions.php
* https://docs.oracle.com/cd/E19424-01/820-4811/anobm/index.html
* https://askubuntu.com/questions/434289/why-doesnt-the-time-command-work-with-any-option
* http://man7.org/linux/man-pages/man1/time.1.html
* https://ucl-ingi.github.io/LEPL1503-Blog/arrows/
* https://www.linuxjournal.com/content/bash-arrays
