# EVASION DE PRISON

## But du jeu
Sortir d'une prison.

##Comment ça marche
avec le commande instructions/0 vous pouvez connaître les commandes disponibles.

##Personnages
- john: c'est votre voisin de cellule que vous ne connaissez pas très bien mais qui peut vous aider dans votre mission
- docteur: le médecin de la prison, ça peut être très utile de lui parler
- gardien: ce sont les gardes qui sont dans certaines pièces, si vous ne voulez pas être capturé il vous faudra une arme ou un compagnon.

## Fonctionnalités avancées

### Collecter
Avec collecter/1 vous pouvez récupérer un objet qui nous trouve dans la pièce et le mettre à l'intérieur du sac.

example:
    jouer.
    o.
    collecter tournevis.
    % maintenant il y a un tournevis à l'intérieur du sac.


### Parler
parler/1 aux personnages peut vous amener à découvrir des choses pour vous aider à résoudre le jeu.

example:
    jouer.
    e.
    parler john
    % john a écrit quelques informations

### Decouvrir
decouvrir/1 il est utilisé pour regarder derrière un objet nommé dans le texte.
Cela vous permet de connaître le nom de l'objet caché.

example:
    jouer.
    o.
    collecter tournevis.
    e.
    n.
    collecter couteau.
    e.
    n.
    % Dans le texte il mentionne les objets : un réfrigérateur, une cuisiniere et un grand_evier.
    decouvrir cuisiniere.
    % Vous pouvez maintenant savoir s'il y a quelque chose derrière l'objet.

### Engager
engager/1 prenez le personnage désiré avec vous.
Désormais vous serez 2 dans cette aventure.

example:
    jouer.
    e.
    egager john
    % john es dans votre equipe.

### Utiliser
utiliser/1 C'est une commande de base en fait, mais elle peut être 
faite n'importe où pour utiliser votre objet, 
s'il y a une fonction secrète elle sera activée, 
tandis que s'il n'y a pas de fonction secrète vous 
perdrez simplement votre objet.

example:
jouer.
n.
collecter couteau.
utiliser couteau.
% Si l'objet est inutile, il est perdu.