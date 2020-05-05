---
layout: post
title: Optimisation du nombre de threads au moyen de Python
author: Eliot Peeters
---

Afin de trouver le nombre de threads optimal, il nous faudrait exécuter plusieurs fois le programme avec un nombre de threads différent à chaque exécution. Cependant avec un même nombre de thread, le temps d'exécution peut varier. Il est donc interessant d'exécuter le programme **X** fois pour **n** threads et ceci de **1** à **N** threads. 

Pour pouvoir mettre tout ces résultats dans un joli graphique et pouvoir inclure ce dernier dans le rapport, une solution assez évidente est d'utiliser python et ses librairies [*matplotlib*](https://matplotlib.org/) et [*numpy*](https://numpy.org/).

> 
 ## Les Librairies Python


> [*os*](https://docs.python.org/3/library/os.html)\
> [*numpy*](https://numpy.org/)\
> [*matplotlib*](https://matplotlib.org/)\
> [*py-cpuinfo*](https://github.com/workhorsy/py-cpuinfo) (pas obligatoire)\
> [*time*](https://docs.python.org/fr/3/library/time.html)\
> [*ctypes*](https://docs.python.org/3/library/ctypes.html)

## Les imports dans le programme
```python
import os
from numpy import *
import matplotlib.pyplot as plt
import cpuinfo
from time import time
from ctypes import *
```
Pour exécuter notre code C depuis python, il y a deux manières possibles, soit exécuter des commandes shell depuis python, soit exécuter les fonctions du programme C directement depuis python.

### Exécution version shell

Pour cette version, le principe est d'exécuter le programme C dans le terminal au moyen de python. Donc pour peu que l'exectuable soit de la forme **./fact [-N nombre_de_threads] fichier_input fichier_output** et qu'il écrive uniquement le temps en microsecondes dans le terminal cette verion fonctionnera. On écrit premièrement une fonction qui prend comme argument le nombre de threads et qui retourne le temps pris en micro-secondes au moyen de la librairie [*os*](https://docs.python.org/3/library/os.html) qui est comprise de base dans python :

```python
def exec (Number_of_thread) : 
    execution = os.popen('./fact -N {} Input.txt Output.txt'.format(str(Number_of_thread))) #écrit dans le terminal
    time_taken_raw = execution.read() #lit ce que l'execution écris dans le terminal
    try :
        time_taken = float(time_taken_raw.strip())*1000#transforme en float et retire le "\n"
    except:
        time_taken = -1
    return time_taken
```
### Exectuion version C

¨Pour cette version, le principe est d'exécuter une des fonctions du code C directement dans le code Python. Pour ce faire, il nous faut d'abord créer une librairie partagée au moyen de [*gcc(1)*](https://linux.die.net/man/1/gcc) en entrant la commande suivante dans le terminal : 

```bash
gcc -fPIC -o fact.so fact.c -lpthread
```
Une fois cette librairie créée, nous pouvos directement l'importer dans python au moyen de ces lignes définissant les variables globales dans notre programme :

```python
so_file = "/Chemin_vers_le_fichier/fact.so"
fact = CDLL(so_file)
```
Maintenant, il est possible d'appeler n'importe quel fonction de programme C dans python au moyen de la ligne de code :
```python
fact.fun()
```
Un exemple de la fonction exec serait alors : 

```python
def exec_2 (Number_of_thread) : 
    t1 = time()
    fact.main(Number_of_thread)
    t2 = time()
    time_taken = t2 - t1
    return time_taken
```

Il est à noter qu'ici le temps est directement mesurer en Python car passer par [*gettimeofday(3P)*](http://man7.org/linux/man-pages/man3/gettimeofday.3p.html) ne nous lit pas des valeurs correctes lorsque celle-ci est executée depuis Python. Enfin il faut faire bien attention que la fonction main ai bien fini son exécution avant de passer à l'exécution suivante afin d'éviter des soucis entre les threads. Pour ceci il peut être interresant de créer une fonction auxiliaire comme décrite dans le post sur le blog concernant les mesures de temps.

### Reste du Programme

On écrit maintenant une fonction qui prend pour arguments le nombre de threads maximum et le nombre d'exéctuions du programme pour **n** threads :

```python
def main (number_of_exec,max_number_of_thread):
    big_array = []
    n_error = 0
    for n in range (max_number_of_thread):
        array_of_time_for_n_thread = []
        for i in range (number_of_exec):
            time_taken = exec(max_number_of_thread)
            if time_taken != -1 :
                array_of_time_for_n_thread.append(time_taken)
            else : 
                n_error += 1
        big_array.append(array_of_time_for_n_thread)
    grapher(big_array,n_error)
```

Et finalement il ne nous reste plus qu'à écrire la fonction [*grapher()*]() qui prend pour argument l'array des temps d'executioné et retourne un graphique. Il s'agit uniquement de fonctions matplotlib et numpy de base, je n'entrerais donc pas dans les détails sur cette fonction

```python
def grapher(array,n_error):
    n = 1
    ax = plt.subplot()
    arr = asarray(array)
    mean_arr = []
    for n_thread in arr : 
        stand = around(std(n_thread),2)
        maxi = around(amax(n_thread),2)
        mini = around(amin(n_thread),2)
        moy = around(mean(n_thread),2)
        ax.plot(n,maxi,'go',)
        ax.plot(n,mini,'go')
        ax.plot([n,n],[mini,maxi],'g')
        ax.plot(n,moy,'bo')
        ax.text(n + 0.09,moy,"$\sigma={}$\nmoy={}\nmax={}\nmin={}".format(stand,moy,maxi,mini),bbox=dict(facecolor='wheat', alpha=0.7))
        mean_arr.append(moy)
        n+=1
    mean_numpy_arr = asarray(mean_arr)
    ax.plot(range(1,n),mean_numpy_arr,'b--')
    ax.axhline(amin(mean_numpy_arr))
    ax.set_xlabel('Number of thread [N]')
    ax.set_ylabel('Time [ms]')
    ax.text(0.05, 0.1, '{} ERREURS'.format(n_error), fontsize=10, transform=plt.gcf().transFigure)
    ax.set_title("Execuéion de fact avec l'exemple d'input sur un processeur " + cpuinfo.get_cpu_info()['brand'].split("w/")[0] ,pad=30)
    #l'appel à cpuinfo.get_cpu_info()['brand'].split("w/")[0] permet d'avoir le nom du processeur
    plt.show()
```

Et voilà après en entrant par exemple cette commande dans le programme python : 
```python
main(5, 8)
```
Voici le graphique obtenu. En vert on peut voir le temps d executioé maximum et minimum observés lors des **X** exéctuions pour **n** threads et en bleu la moyenne du temps mis pour **n** threads, et en rouge on peut voir le minimum de la moyenne du graph. Enfin dans chaque cadre nous pouvons voir les valeurs de la déviation standard, la moyenne, le maximum ainsi que le minimum. Dans le coin en bas à gauche, il y a le nombre d'erreurs encontrée lors de l'executionédu programme fact si jamais il vennait à y en avoir.

![Graph](https://raw.githubusercontent.com/Eliot-P/public_png/master/Graph2.png)
