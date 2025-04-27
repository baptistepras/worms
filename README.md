# Worms

Auteurs : Raphael LEONARDI, Baptiste PRAS
Ce repository contient un jeu codé en Ocaml utilisant la bibliothèque Gfx js_of_ocaml principalement.
C'est un jeu multijoueur, grandement inspiré du jeu Worms.
## Comment y jouer

### Présentation du jeu

Il s'agit d'un jeu au tour par tour opposant plusieurs équipes, chacune composée de vers différents. Le nombre d'équipes et le nombre de joueurs par équipe sont configurables dans le fichier `src/core/cst.ml`. Au lancement du jeu, les équipes sont créées et les vers sont positionnés aléatoirement sur des blocs d'herbe.

Chaque vers possède :
- Un numéro d'identification
- Des points de vie
- Un arsenal d'armes : arc, pistolet, grenades et bazooka

### Tour de jeu

Les vers jouent à tour de rôle selon leur numéro d'identification, suivant une séquence où l'équipe 1 joue avec le ver 1, l'équipe 2 avec le ver 2, et ainsi de suite.

Un tour de jeu se déroule en trois phases :

#### 1. Phase de déplacement

Le joueur peut librement déplacer son vers sur la carte :
- Se déplacer à gauche ou à droite
- Sauter
- Subir les effets de la gravité

⚠️ **Attention** : tout contact avec l'eau est fatal pour le vers.

#### 2. Phase de visée

Une fois les déplacements terminés, le joueur appuie sur `N` pour passer à la phase de visée. Il peut alors choisir parmi ses quatre armes et ajuster sa visée.

**Commandes de visée** :
- `Z` : Sélectionner l'arme suivante
- `A` : Sélectionner l'arme précédente
- `Flèche Gauche` : Orienter la visée vers la gauche
- `Flèche Droite` : Orienter la visée vers la droite
- `Flèche Haut` : Augmenter la puissance de tir
- `Flèche Bas` : Diminuer la puissance de tir

#### 3. Phase de tir

Après avoir ajusté sa visée, le joueur appuie à nouveau sur `N` pour tirer. Le projectile suivra une trajectoire courbe déterminée par l'angle et la puissance choisis.

**Effets du tir** :
- Si le projectile touche une entité : celle-ci subit des dégâts
- Si le projectile sort de l'écran : le tour se termine

**Option spéciale** : Pendant la trajectoire du projectile, appuyer sur `Espace` créera une plateforme à l'emplacement actuel du projectile (utile pour s'échapper d'un trou, par exemple).

Appuyer sur `N` pendant cette phase fait passer au joueur suivant.

### Fin de partie

La partie se termine dans l'un des cas suivants :
- Une seule équipe reste en vie (victoire de cette équipe)
- Tous les vers sont éliminés (match nul, annoncé dans la console)




## Structure des répertoires 

Voici comment nous avons organisé les dossier `src` et `ressources `

* src
	* components
		* block.ml     : le fichier block fourni avec des attributs en plus
		* classes.ml   : toutes les classes importantes du jeu, map, vers...
		* component_defs : 
	* core
		* cst.ml       :  les constantes du jeu
		* global.ml    :   les variables globales du jeu
		* input.ml     : ce qui gère les touches du jeu
		* rect.ml      
		* vector.ml
		* texture.ml
	* systems
		* collision.ml
		* draw.ml
		* move.ml
		* system_defs.ml
	* game.ml :  le fichier qui gère la boucle du jeu
* resources
	* images : toutes les images du jeu, plateformes, vers, munitions
	* maps :  les cartes du jeu

Les cartes du jeu sont des `.csv`, que l'on a créées en utilisant le logiciel `Tiled`. Le dossier `maps` en contient plusieurs, mais on n'en utilise qu'une seule dans le jeu.





