# Projet de Sécurisation des Comptes Utilisateurs : AD_CHANGE-DEFAULT-PWD.ps1

Dans le cadre de l'amélioration de la sécurité au sein de l'entreprise, j'ai mis en place un projet visant à détecter les comptes actifs depuis plus d'un mois utilisant le mot de passe par défaut. Cette initiative fait partie d'une série de mesures décidées par l'équipe sécurité pour renforcer la protection des données et éviter tout risque de compromission.

## 1. Méthodologie

Afin de répondre à ce besoin, j'ai développé deux scripts PowerShell complémentaires :

### 1.1 Premier script : Encryption du mot de passe

Le premier script demande à l'utilisateur de saisir un mot de passe qu'il souhaite crypter. Ce mot de passe est ensuite sauvegardé dans un fichier sécurisé. Notez que ce mot de passe crypté sera uniquement utilisable sur la machine ayant généré ce fichier, garantissant ainsi sa confidentialité et sa sécurité.

### 1.2 Deuxième script : Gestion et renouvellement des mots de passe

Le second script exécute plusieurs fonctions essentielles :

- **Fonction de log** : Enregistre toutes les actions du script avec la date et l'heure.
- **Fonction de détection** : Identifie les comptes utilisateurs actifs depuis plus d'un mois et nécessitant un changement de mot de passe à leur prochaine connexion.
- **Génération de mot de passe sécurisé** : Crée un mot de passe aléatoire et sécurisé.

Ce script tente ensuite de changer les mots de passe des utilisateurs dont le mot de passe actuel correspond à celui par défaut contenu dans le fichier généré par le premier script. Si un utilisateur est identifié avec le mot de passe par défaut, un nouveau mot de passe est automatiquement attribué.

## 2. Mise en œuvre et automatisation

Depuis son développement, ce processus est exécuté chaque semaine de manière automatisée. Cela permet de maintenir un haut niveau de sécurité et de prévenir les risques liés à l'utilisation prolongée de mots de passe initiaux.
