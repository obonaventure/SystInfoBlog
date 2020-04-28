---
layout: post
title: Créer un thread à partir d'une fonction à plusieurs arguments
author: Bastien Wiaux
---
Vous avez enfin fini d'implémenter votre algorithme et tout fonctionne à merveille lorsque vous décidez de passer à l'étape suivante: passer votre algorithme en multithread !

Seulement un problème se pose, votre fonction prend trois arguments et la foncion `pthread_create` refuse de la prendre ! En cherchant un peu, on peut se rendre compte que c'est normal, car la fonction `pthread_create` est définie ainsi dans sa _manpage_ :

```
#include <pthread.h>

int pthread_create(pthread_t *thread, const pthread_attr_t *attr,
                   void *(*start_routine) (void *), void *arg);
```
Si on regarde le troisième argument, qui correspond à la fonction que le thread fera tourner, on peut lire `void *(*start_routine) (void *)`. Cette expression se décortique en trois parties:
- `void *`: cela signifie que votre fonction doit retourner un pointeur _void_
- `(*start_routine)`: c'est ce que vous allez réellement écrire en argument, cela représente simplement un pointeur vers votre fonction.
- `(void *)`: cela indique que votre fonction doit prendre en argument un pointeur _void_ 

> Mais comment gérer un seul pointeur _void_ ? Ma fonction à besoin de trois arguments de types différents !

Pas de panique c'est en réalité assez simple. Nous allons créer une structure contenant tous vos arguments avec le bon type, et ensuite caster le pointer de cette structure en `void *`. De cette façon, il suffira de recaster la structure dans l'autre sens dans votre fonction, et vous pourrez ainsi faire passer autant d'arguments que vous voudrez !

Par exemple, une fonction 
```
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
```
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


L'exemple que je viens de vous donner devrait couvrir l'ensemble des cas dont vous pourriez avoir besoin, de plusieurs arguments à un retour en structure "complexe". J'espère que cela vous aidera.
