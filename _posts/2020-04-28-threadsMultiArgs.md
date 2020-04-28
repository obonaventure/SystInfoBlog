---
layout: post
title: Créer un thread à partir d'une fonction à plusieurs arguments
author: Bastien Wiaux
---
Vous avez enfin fini d'implémenter votre algorithme et tout fonctionne à merveille lorsque vous décidez de passer à l'étape suivante: passer votre algorithme en multithread !

Seulement un problème se pose, votre fonction prend trois arguments et la foncion `pthread_create` refuse de la prendre ! En cherchant un peu, on peut se rendre compte que c'est normal, car la fonction `pthread_create` est défini ainsi dans sa _manpage_ :

```
#include <pthread.h>

int pthread_create(pthread_t *thread, const pthread_attr_t *attr,
                   void *(*start_routine) (void *), void *arg);
```
Si on regarde le troisième argument, qui correspond à la fonction que le thread fera tourner, on peut lire `void *(*start_routine) (void *)`. Cette expression se décortique en trois parties:
- `void *`: cela signifie que votre fonction doit retourner un pointeur _void_
- `(*start_routine)`: c'est ce que vous allez réellement écrire en argument, celà représente simplement un pointeur vers votre fonction.
- `(void *)`: cela indique que votre fonction doit prendre en argument un pointeur _void_ 

> Mais comment gérer un seul pointeur _void_ ? Ma fonction à besoin de trois arguments de types différent !

Pas de panique c'est en réalité assez simple. Nous allons créer une structure contenant tous vos arguments avec le bon type, et ensuite caster le pointer de cette structure en `void *`. De cette façon, il suffira de recaster la structure dans l'autre sens dans votre fonction, et vous pourrez ainsi faire passer autant d'arguments que vous voudrez !

Par exemple, une fonction 
```
int max(int a, int b){
    if (a >= b) return a;
    else return b;
}
```
deviendra
```
typedef struct max_args{
    int a;
    int b;
} max_args_t;

void *max(void *arguments){
    max_args_t *args = (max_args_t *) arguments
    int a = args->a;
    int b = args->b;

    if (a >= b) return (void *) &(args->a);
    else return (void *) &(args->b);
}
```
On remarquera que je ne retourne pas `&a` ou `&b`, mais bien `&(args->a), &(args->b)`, car je ne veux pas retourner un pointeur vers une variable locale (elle disparaitrait à la fin de l'exécution de ma fonction) j'utilise donc ici le fait que `args->a` `args->b` on été déclarés hors de la fonction.
Le `(void *)` caste le pointeur _int_ afin de respecter totalement ce que la définition de notre fonction nous impose.


L'exemple que je viens de vous donner est simpliste, mais en utilisant le même stratagème que pour les arguments, vous pourriez retourner des structures de données aussi complexes que vous le désireriez, simplement en castant leur pointeur en `void *`
