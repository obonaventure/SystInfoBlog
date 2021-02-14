---
layout: post
title: Créer un thread à partir d'une fonction à plusieurs arguments
author: Bastien Wiaux
---
Vous avez enfin fini d'implémenter votre algorithme et tout fonctionne à merveille lorsque vous décidez de passer à l'étape suivante: passer votre algorithme en multithread !

Seulement un problème se pose, votre fonction prend trois arguments et la foncion `pthread_create` refuse de la prendre ! En cherchant un peu, on peut se rendre compte que c'est normal, car cette fonction est définie ainsi dans la [manpage de pthread_create](http://man7.org/linux/man-pages/man3/pthread_create.3.html) :

```c
#include <pthread.h>

int pthread_create(pthread_t *thread, const pthread_attr_t *attr,
                   void *(*start_routine) (void *), void *arg);
```

Si on regarde le troisième argument, qui correspond à la fonction que le thread fera tourner, on peut lire `void *(*start_routine) (void *)`. Cette expression se décortique en trois parties:
- `void *`: cela signifie que votre fonction doit retourner un pointeur _void_
- `(*start_routine)`: c'est ce que vous allez réellement écrire en argument, cela représente simplement un pointeur vers votre fonction.
- `(void *)`: cela indique que votre fonction doit prendre en argument un pointeur _void_ 

> Mais comment gérer un seul pointeur _void_ ? Ma fonction à besoin de trois arguments de types différents !

Pas de panique c'est en réalité assez simple. Nous allons créer une structure contenant tous vos arguments avec le bon type, et ensuite caster le pointeur de cette structure en `void *`. De cette façon, il suffira de recaster la structure dans l'autre sens dans votre fonction, et vous pourrez ainsi faire passer autant d'arguments que vous voudrez !

Par exemple, une fonction 

```c
typedef struct rep{
        double min;
        double max;
} rep_t;

rep_t minmax(double a, double b, double c){
    rep_t rep;
    if (a >= b && a>= c) {
        rep.max = a;
        rep.min = (b < c) ? b : c;
    }
    else if ( b >= c && b >= a){
        rep.max = b;
        rep.min = (a < c) ? a : c;
    }
    else {
        rep.max = c;
        rep.min = (a < b) ? a : b;
    }
    return rep;
}
```

deviendra

```c
#include <stdlib.h>

typedef struct rep{
        double min;
        double max;
} rep_t;

typedef struct args{
    double a;
    double b;
    double c;
} args_t;

void *minmax(void *arguments){
    args_t *args = (args_t *) arguments;
    double a = args->a;
    double b = args->b;
    double c = args->c;

    rep_t *rep = malloc(sizeof(rep_t));
    if (rep == NULL) return NULL;
    
    if (a >= b && a >= c) {
        rep->max = a;
        rep->min = (b < c) ? b : c;
    }
    else if ( b >= c && b >= a){
        rep->max = b;
        rep->min = (a < c) ? a : c;
    }
    else {
        rep->max = c;
        rep->min = (a < b) ? a : b;
    }
    return (void *) rep;
}
```

On remarquera que je ne retourne pas `&rep`, car je ne veux pas retourner un pointeur vers une variable locale (elle disparaitrait à la fin de l'exécution de ma fonction) j'utilise donc ici un malloc afin d'obtenir une zone mémoire qui ne sera pas effacée à la fin de ma fonction.
Le `(void *)` caste le pointeur _rep\_t_ afin de respecter totalement ce que la définition de notre fonction nous impose.

Notre fonction est donc prête à être utilisée par un thread, mais il nous manque toujours un moyen de récupérer son output !

Pour avoir un valeur de retour, il nous faut attendre que le thread ai fini sa tâche et retourne une valeur, c'est donc dans la déclaration de `pthread_join` que nous trouvons le moyen de récupérer cette valeur. Je me réfère encore une fois à la [manpage de pthread_join](http://man7.org/linux/man-pages/man3/pthread_join.3.html):

```c
#include <pthread.h>

int pthread_join(pthread_t thread, void **retval);
```

Cette commande permet d'attendre le thread `thread` et de stocker sa valeur de retour (qui dois être un pointeur _void_) à l'adresse mémoire pointée par `**retval`.

Voilà ! Nous avons maintenant tous les outils pour lancer notre fonction et récupérer son retour, sans oublier de _free_ cette valeur de retour une fois que nous n'en avons plus besoin, il ne s'agirait pas d'introduire des memory leaks ...

Au final, on obtient:

```c
#include <pthread.h>

int main(){
    
    // création des arguments
    args_t arg;
    arg.a = 657876;
    arg.b = 45;
    arg.c = 12348;
    
    //déclaration et création du thread
    pthread_t thread;
    pthread_create(&thread, NULL, minmax, &arg);
    
    // déclaration du pointeur de valeur retour et attente que le thread termine (et donc retourne)
    rep_t * return_value;
    pthread_join(thread, (void *) &return_value);
    
    // utilisation du résultat
    printf("%lf, %lf", return_value->max, return_value->min);
    
    // libération de l'espace mémoire /!\ TRÈS IMPORTANT
    free(return_value);
    
}
```
