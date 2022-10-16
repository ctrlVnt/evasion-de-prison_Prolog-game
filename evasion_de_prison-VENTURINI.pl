%%% INFO-501, TP3
%%% Riccardo Venturini
%%%
%%% Lancez la "requête"
%%% jouer.
%%% pour commencer une partie !
%

% il faut déclarer les prédicats "dynamiques" qui vont être modifiés par le programme.
:- dynamic position/2, position_personages/2, position_courante/1.

% on remet à jours les positions des objets et du joueur
:- retractall(position(_, _)), retractall(position_personages(_, _)), retractall(position_courante(_)).

% on déclare des opérateurs, pour autoriser `prendre couteau` au lieu de `prendre(couteau)`
:- op(1000, fx, utiliser).
:- op(1000, fx, aller).
:- op(1000, fx, collecter).
:- op(1000, fx, engager).
:- op(1000, fx, parler).
:- op(1000, fx, decouvrir).

% position du joueur. Ce prédicat sera modifié au fur et à mesure de la partie (avec `retract` et `assert`)
position_courante(cellule_de_prison).

% passages entre les différent endroits du jeu
passage(cellule_de_prison, est, cellule_inconnue).
passage(cellule_inconnue, ouest, cellule_de_prison).

passage(cellule_de_prison, ouest, lessive).
passage(lessive, est, cellule_de_prison).

passage(cellule_de_prison, nord, salle_de_diffusion).
passage(salle_de_diffusion, sud, cellule_de_prison).

passage(salle_de_diffusion, nord, infirmerie).
passage(infirmerie, sud, salle_de_diffusion).

passage(salle_de_diffusion, ouest, laboratoire).
passage(laboratoire, est, salle_de_diffusion).

passage(laboratoire, nord, poste_de_garde1).
passage(poste_de_garde1, sud, laboratoire).

passage(poste_de_garde1, nord, poste_de_garde2).
passage(poste_de_garde2, sud, poste_de_garde1).

passage(poste_de_garde2, est, hall).

passage(salle_de_diffusion, est, salle_de_loisirs).
passage(salle_de_loisirs, ouest, salle_de_diffusion).

passage(salle_de_loisirs, ouest, salle_de_diffusion).

passage(salle_de_loisirs, est, salle_inconnue) :-
        write("La porte arrière s'est soudainement fermée."), nl,
        write("l'alarme retentit et vous êtes entouré de gardes."), nl,
        write("Votre évasion se termine ici :("), nl,
        fin.

passage(salle_de_loisirs, nord, cuisine).
passage(cuisine, sud, salle_de_loisirs).

passage(cuisine, nord, salon).
passage(salon, sud, cuisine).

passage(salon, nord, hall).

passage(hall, sud, cuisine).
passage(hall, ouest, poste_de_garde2).


% position des objets
position(tournevis, lessive).
position(couteau, salle_de_diffusion).
position(pied_de_biche, cuisine).
position(cle, hall).

% position des personnages
position_personages(john, cellule_inconnue).
position_personages(docteur, infirmerie).
position_personages(gardien1, cuisine).
position_personages(gardien2, poste_de_garde1).
position_personages(gardien3, poste_de_garde2).

% collecter un objet
collecter(X) :-
        atom(X),
        position_courante(P),
        position(X, P),
        retract(position(X, P)),
        assert(position(X, dan_le_sac)),
        write("OK, pris."), nl,
        !.

collecter(X) :-
        write("??? Il n'y a pas de "),
        write(X),
        write(" ici."), nl,
        fail.

% utiliser un objet
utiliser(X) :-
        atom(X),
        position(X, dan_le_sac),
        effect(X),
        write("OK, "), write(X), write(" utilisé."), nl,
        retract(position(X, dan_le_sac)),
        assert(position(X, casse)),
        !.

utiliser(X) :-
        \+ X = tournevis,
        \+ position_courante(cuisine),
        write("??? Vous n'avez pas de "),
        write(X), nl,
        fail.

% engager un personnage
engager(X) :-
        \+ X = docteur,
        \+ X = gardien,
        atom(X),
        position_courante(P),
        position_personages(X, P),
        retract(position_personages(X, P)),
        assert(position_personages(X, equipe)),
        write("OK, engagé."), nl,
        !.

engager(X) :-
        X = docteur,
        write("Vous ne pouvez pas engager le médecin pour votre opération."),
        fail.

engager(_) :-
        write("??? Opération impossible ici"),
        fail.

% quand l'autre membre de l'équipe se sacrifie
morir(X, P) :-
        atom(X),
        position_personages(X, P),
        retract(position_personages(X, P)),
        assert(position_personages(X, cimetiere)),
        write(X), write(" est mort."), nl,
        !.

% pour déplacer un objet
decouvrir(X):-
        atom(X),
        indices(X), !.

decouvrir(_):-
        write("Il n'y a rien derrière cet objet !"),nl,
        fail.

% pour parler
parler (X) :-
        phrase(X), !.

parler (_) :-
        write("tu parles tout seul, le stress te monte à la tête"), nl,
        !.

% quelques raccourcis
n :- aller(nord).
s :- aller(sud).
e :- aller(est).
o :- aller(ouest).
r :- regarder.
i :- instructions.

% déplacements
aller(Direction) :-
        position_courante(Ici),
        passage(Ici, Direction, La),
        retract(position_courante(Ici)),
        assert(position_courante(La)),
        regarder, !.

aller(_) :-
        write("Vous ne pouvez pas aller par là."),
        fail.

% regarder autour de soi
regarder :-
        position_courante(Place),
        decrire(Place), nl,
        lister_objets(Place), nl,
        lister_personages(Place), nl.


% afficher la liste des objets à l emplacement donné
% excluse les lieu ou sont les objets secret
lister_objets(Place) :-
        \+ Place = hall,
        \+ Place = cuisine,
        position(X, Place),
        write("Il y a "), write(X), write(" ici."), nl,
        fail.

lister_objets(_).

% afficher la liste des personnages
lister_personages(Place) :-
        position_personages(X, Place),
        \+ X = gardien,
        write("Il y a "), write(X), write(" ici."), nl,
        write("Si tu veux tu peux lui parler"), nl,
        fail.

lister_personages(_).


% fin de partie
fin :-
        nl, write("La partie est finie."), nl,
        halt.


% affiche les instructions du jeu
instructions :-
        nl,
        write("Les commandes peuvent également être écrites sans mettre de crochets."), nl,
        write("IMPORTANT: pour faire référence à un objet, saisissez-le exactement tel que vous le lisez dans le texte, y compris les traits de soulignement."), nl,
        write("Les commandes existantes sont :"), nl,
        write("jouer.                   -- pour commencer une partie."), nl,
        write("n.  s.  e.  o.           -- pour aller dans cette direction (nord / sud / est / ouest)."), nl,
        write("aller(direction)         -- pour aller dans cette direction."), nl,
        write("collecter(objet).        -- pour prendre un objet."), nl,
        write("utiliser(objet).         -- pour utiliser un objet. "), nl,
        write("engager(personage).      -- pour signer un personnage dans votre équipe."), nl,
        write("parler(personage).       -- pour entendre ce qu'un personnage a à dire."), nl,
        write("decouvrir(objet).        -- pour voir derrière un objet."), nl,
        write("regarder. ou r.          -- pour regarder autour de vous. ATTENTION à ne pas regarder autour s'il y a encore un garde autour."), nl,
        write("instructions. ou i.      -- pour revoir ce message !."), nl,
        write("fin.                     -- pour terminer la partie et quitter."), nl,
        nl.



% lancer une nouvelle partie
jouer :-
        instructions,
        write("Michael !"), nl,
        write("C'est la nuit, et tu as remarqué que quelque chose est différent..."), nl, nl,
        regarder.


% descriptions des emplacements
decrire(cellule_de_prison) :-
    write("cellule_de_prison"), nl,
    write("vous êtes dans votre cellule, et vous avez remarqué qu'elle est ouverte."), nl,
    write("Votre évasion commence !"), nl, nl,
    write("À l'est il y a une cellule d'un inconnu, attention à faire confiance."), nl,
    write("À l'ouvest il y a la lessive, certains opérateurs ont peut-être oublié quelques outils utiles."), nl,
    write("Au nord il y a la salle de diffusion, il est sûrement relié à d'autres pièces."), nl.

decrire(lessive) :-
    write("lessive"), nl,
    write("Il y a une machine à laver battue, qui sait si vous pouvez trouver quelque chose d'utile."), nl, nl,
    write("À l'est il y a votre cellule."), nl.

decrire(cellule_inconnue) :-
    write("cellule_inconnue"), nl,
    write("Vous pouvez libérer John, pensez que si vous le recrutiez, il pourrait vous trahir."), nl, nl,
    write("À l'ouvest il y a votre cellule."), nl.

decrire(salle_de_diffusion) :-
    write("salle_de_diffusion"), nl,
    write("Comme d'habitude la saleté, vous pouvez essayer de chercher quelque chose."), nl, nl,
    write("À nord il y a infirmerie, peut-être qu'il y a le docteur à l'intérieur."), nl,
    write("À l'ouvest il y a le laboratoire."), nl,
    write("À l'est il y a le salle de loisirs, tu sembles connaître le mieux le chemin."), nl,
    write("À sud il y a votre cellule."), nl.

decrire(laboratoire) :-
    write("laboratoire"), nl,
    write("Un endroit un peu inquiétant, peut-être que pour continuer il vaudrait mieux avoir une arme."), nl, nl,
    write("Au nord il y a le premier poste de garde."), nl,
    write("À l'est il y a le salle de diffusion."), nl.

decrire(salle_de_loisirs) :-
    write("salle_de_loisirs"), nl,
    write("Mieux vaut partir d'ici rapidement."), nl, nl,
    write("Au nord il y a le cuisine."), nl,
    write("À l'est il y a une pièce mystérieuse."), nl,
    write("À l'ouvest il y a le salle de diffusion."), nl.

decrire(infirmerie) :-
    write("infirmerie"), nl,
    write("Il y a le docteur, fais semblant d'être malade ou reviens !."), nl, nl,
    write("À sud il y a salle de diffusion."), nl.

decrire(cuisine) :-
    position_personages(gardien1, cuisine),
    position(couteau, dan_le_sac),
    write("cuisine"), nl,
    write("À l'intérieur il y a un cuisinier armé, bats-toi !"), nl,
    utiliser(couteau),
    write("Tu as perdu le couteau."), nl,
    morir(gardien1, cuisine), nl,
    write("Quelle bonne odeur, on dirait qu'ils ont laissé des outils utiles ici aussi !"), nl,
    write("Il y a un réfrigérateur, une cuisiniere et un grand_evier."), nl,
    write("Au nord il y a le salon pour l'ènvites."), nl,
    write("À sud il y a le salle de loisirs"), nl.

decrire(cuisine) :-
    position_personages(gardien1, cuisine),
    position_personages(john, equipe),
    write("cuisine"), nl,
    write("À l'intérieur il y a un cuisinier armé, bats-toi !"), nl,
    write("Il y a un garde, votre ami s'est sacrifié, fuyez !"), nl, nl,
    morir(john, equipe),
    write("Quelle bonne odeur, on dirait qu'ils ont laissé des outils utiles ici aussi !"), nl,
    write("Il y a un réfrigérateur, une cuisiniere et un grand_evier."), nl,
    write("Au nord il y a le salon pour l'ènvites."), nl,
    write("À sud il y a le salle de loisirs"), nl.

decrire(cuisine) :-
    position_personages(gardien1, cuisine),
    write("cuisine"), nl,
    write("À l'intérieur il y a un cuisinier armé,"), nl,
    write("Tu ne peux pas te défendre, il t'a bloqué et a appelé la sécurité."), nl,
    write("Votre évasion se termine ici :("), nl,
    fin, !.

decrire(cuisine) :-
    write("cuisine"), nl,
    write("Quelle bonne odeur, on dirait qu'ils ont laissé des outils utiles ici aussi !"), nl,
    write("Il y a un réfrigérateur, une cuisiniere et un grand_evier."), nl,
    write("Au nord il y a le salon pour l'ènvites."), nl,
    write("À sud il y a le salle de loisirs"), nl.

decrire(salon) :-
    write("salon"), nl,
    write("C'est une très grande salle, mais si je me souviens bien c'est assez près de la sortie."), nl, 
    write("Il y a une très belle photo accrochée au mur."), nl, nl,
    write("Au nord il y a le hall."), nl,
    write("Au sud il y a le cuisine"), nl.

decrire(hall) :-
    write("hall"), nl,
    write("Il y a la sortie ! Cherchez la clé pour empêcher l'alarme de sonner"), nl,
    write("Il y a un canapé, un vase_de_fleurs et un tableau."), nl,
    write("À l'ouest il y a le dousieme poste de garde, ce n'est peut-être pas une bonne idée sans arme"), nl,
    write("Au sud il y a le cuisine"), nl.

decrire(poste_de_garde1) :-
    position_personages(gardien2, poste_de_garde1),
    position(couteau, dan_le_sac),
    write("poste_de_garde1"), nl,
    write("Il y a un garde, combattez !"), nl,
    utiliser(couteau),
    write("Tu as perdu le couteau."), nl,
    morir(gardien2, poste_de_garde1), nl,
    write("Au nord il y a le dousieme poste de garde."), nl,
    write("Au sud il y a le laboratoire."), nl.

decrire(poste_de_garde1) :-
    position_personages(gardien2, poste_de_garde1),
    position_personages(john, equipe),
    write("poste_de_garde1"), nl,
    write("Il y a un garde, votre ami s'est sacrifié, fuyez !"), nl,
    morir(john, equipe), nl,
    write("Au nord il y a le dousieme poste de garde."), nl,
    write("Au sud il y a le laboratoire."), nl.

decrire(poste_de_garde1) :-
    position_personages(gardien2, poste_de_garde1),
    write("poste_de_garde1"), nl,
    write("Il y a un garde et tu ne peux pas te battre"), nl,
    write("Votre évasion se termine ici :("), nl,
    fin, !.

decrire(poste_de_garde1) :-
    write("poste_de_garde1"), nl,
    write("La poste de garde est vide."), nl, nl,
    write("Au nord il y a le dousieme poste de garde."), nl,
    write("Au sud il y a le laboratoire."), nl.

decrire(poste_de_garde2) :-
    position_personages(gardien3, poste_de_garde2),
    position(couteau, dan_le_sac),
    write("poste_de_garde2"), nl,
    write("Il y a un garde, combattez !"), nl,
    utiliser(couteau),
    write("Tu as perdu le couteau."), nl,
    morir(gardien3, poste_de_garde1), nl,
    write("À l'est il y a le hall."), nl,
    write("Au sud il y a le premiere poste de garde."), nl.

decrire(poste_de_garde2) :-
    position_personages(gardien3, poste_de_garde2),
    position_personages(john, equipe),
    write("poste_de_garde2"), nl,
    write("Il y a un garde, votre ami s'est sacrifié, fuyez !"), nl,
    morir(john, equipe), nl,
    write("À l'est il y a le hall."), nl,
    write("Au sud il y a le premiere poste de garde."), nl.

decrire(poste_de_garde2) :-
    position_personages(gardien3, poste_de_garde2),
    write("poste_de_garde2"), nl,
    write("Il y a un garde et tu ne peux pas te battre"), nl,
    write("Votre évasion se termine ici :("), nl,
    fin, !.

decrire(poste_de_garde2) :-
    write("poste_de_garde2"), nl,
    write("La poste de garde est vide."), nl, nl,
    write("À l'est il y a le hall."), nl,
    write("Au sud il y a le premiere poste de garde."), nl.

% descriptions des objets
decrire(couteau) :-
    write("Un couteau rouillé, ça pourrait être utile pour se défendre."), nl.

decrire(tournevis) :-
    write("Le tournevis pourrait être utile pour ouvrir certains conduits."), nl.

decrire(pied_de_biche) :-
    write("Le pied de biche est certainement utile pour ouvrir quelque chose,"), nl.

% description des personnages
decrire(john) :-
        write("John ressemble à quelqu'un qui se sacrifie pour ses amis, "), nl,
        write("espérons qu'il ne me trahira pas."), nl.

decrire(docteur) :-
        write("le docteur de la prison est trop naïf,"), nl,
        write("il pourrait me dire des choses utiles."), nl.

decrire(gardien) :-
        write("Les gardiens défendent certaines pièces,"), nl,
        write("assurez-vous d'avoir un compagnon ou une arme pour les combattre."), nl.

% phrases
phrase(john) :-
        nl, write("Tu peux m'inscrire dans ton équipe, je ne te trahirai pas, je promets pour ma famille."), nl.

phrase(docteur) :-
        nl, write("Si tu es malade, tu peux attendre ici près du conduit d'air chaud,"), nl,
        write("j'arrive tout de suite, j'irai chercher les médicaments."), nl.

% des indices sur des objets cachés
indices(refrigerateur) :-
        position(pied_de_biche, cuisine),
        write("Il y a un pied_de_biche ici."), nl, nl,
        write("Il y a une fenêtre à ouvrir, mais il faut aussi un tournevis."), nl.

indices(vase_de_fleurs) :-
        position(cle, hall),
        write("Il y a un cle ici."), nl.

% effets d objet
effect(cle) :-
        position_courante(hall),
        write("Vous etes réussi à t'échapper"),nl,
        write("BRAVO !"), nl,
        fin, !.

% pour le passage secret
effect(tournevis) :-
        position_courante(infirmerie),
        write("Vous avez trouvé un conduit secret,"), nl,
        write("grâce au tournevis vous pouvez utiliser"), nl,
        write("le raccourci pour vous rendre au salon."), nl, nl,
        retract(position_courante(infirmerie)),
        assert(position_courante(salon)),
        regarder.

effect(tournevis) :-
        position_courante(cuisine),
        write("Vous avez dévissé les vis de la fenêtre mais elle est toujours serrée."), nl,
        retract(position(tournevis, dan_le_sac)),
        assert(position(tournevis, fenetre)),
        !.

% quand tu a pied_de_biche et tournevis
effect(pied_de_biche) :-
        position_courante(cuisine),
        position(tournevis, fenetre),
        write("Tu as dévissé les vis puis avec le pied de biche tu as ouvert la fenêtre."), nl,
        write("Tu as réussi à t'échapper, BRAVO !"), nl,
        fin, !.

effect(_).