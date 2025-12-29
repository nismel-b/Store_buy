# store_buy
# Marketplace E-commerce Flutter Application

Application Flutter complète pour un centre commercial virtuel avec deux types d'utilisateurs : vendeurs et clients.

## Fonctionnalités

### Pour les Vendeurs

#### Création de Magasin
- Nom de l'entreprise
- Description (histoire de l'entreprise)
- Catégorie de produit (20 catégories disponibles)
- Mot de passe de sécurité
- Adresse du magasin physique (optionnel)

- Taille du magasin : (à venir)
    - Petit magasin : 1-100 articles
    - Moyen magasin : 1-500 articles
    - Grand magasin : 1-1500 articles
    - Extra-box : Articles illimités + boost de visibilité

- Photo du magasin et logo
- Informations de livraison :
    - Mode de livraison
    - Modalités
    - Temps de livraison
    - Zones de livraison
- Politiques de l'entreprise :
    - Remboursement
    - Garanties
    - Réductions
    - Promotions
- Modes de paiement (Carte, Orange Money, MTN Mobile Money)

#### Gestion des Produits
- Ajouter un produit :
    - Nom du produit
    - Caractéristiques, modèle et référence
    - Photo du produit
    - Prix
    - Quantité
- Modifier un produit
- Ajouter/retirer des promotions
- Voir les statistiques de vente
- Classement des produits les plus vendus

#### Gestion des Commandes
- Voir toutes les commandes
- Confirmer les commandes
- Traiter les commandes
- Marquer comme expédié/livré
- Gérer les remboursements

#### Statistiques
- Ventes totales
- Nombre de commandes
- Produits les plus vendus

#### Employés (à venir)
- Ajouter des employés
- Gérer les permissions

### Factures
- Ajouter/supprimer des factures
- Modifier des factures
- Consuler les factures/archives
- Archiver des factures
- imprimer des factures 

### Stories
- Ajouter/supprimer  des stories 


### Pour les Clients

#### Inscription/Connexion
- Création de compte avec :
    - Nom d'utilisateur
    - Mot de passe
    - Numéro de téléphone (optionnel)
    - Email (optionnel)
    - Localisation (optionnel)
    - Modes de paiement
- Connexion en tant que visiteur (sans transaction)

#### Navigation
- Parcourir les boutiques
- Voir les produits par boutique
- Détails des produits
- Ajouter au panier
- Gérer le panier
- Passer commande

#### Fonctionnalités
- Chat avec les vendeurs
- Ajouter aux favoris (à venir)
- Laisser des avis (à venir)
- Annuler une commande
- Remboursement selon la politique de la boutique
- Abonnement à un magasin pour prix spéciaux (à venir)
- Cartes de fidélité (à venir)

## Structure du Projet

```## 📁 Structure du Projet
```
lib/
├── main.dart                      # Point d'entrée de l'application
│
├── model/                         # Modèles de données
│   ├── commande.dart             # Modèle des commandes
│   ├── login_model.dart          # Modèle d'authentification
│   ├── panier_model.dart         # Modèle du panier
│   ├── product_model.dart        # Modèle des produits
│   └── store_model.dart          # Modèle des magasins
│
├── service/                       # Services de gestion des données
│   ├── auth_service.dart         # Service d'authentification
│   ├── shop_service.dart         # Service de gestion des magasins
│   ├── product_service.dart      # Service de gestion des produits
│   ├── order_service.dart        # Service de gestion des commandes
│   ├── cart_service.dart         # Service de gestion du panier
│   ├── review_service.dart       # Service de gestion des avis
│   └── message_service.dart      # Service de messagerie/chat
│
└── screens/                       # Écrans de l'application
    │
    ├── bienvenue_screen.dart                # Écran de bienvenue
    ├── login_screen.dart                    # Écran de connexion
    │
    ├── # INSCRIPTION
    ├── vendor_register_screen.dart          # Inscription vendeur
    ├── customer_register_screen.dart        # Inscription client
    │
    ├── # VENDEURS
    ├── create_shop_screen.dart              # Création de magasin
    ├── vendor_home_screen.dart              # Tableau de bord vendeur
    ├── add_product_screen.dart              # Ajout de produit
    ├── vendor_products_screen.dart          # Liste des produits du vendeur
    ├── edit_product_screen.dart             # Modification de produit
    ├── vendor_orders_screen.dart            # Gestion des commandes
    ├── vendor_statistics_screen.dart        # Statistiques de vente
    ├── vendor_employees_screen.dart         # Gestion des employés
    │
    ├── # CLIENTS
    ├── customer_home_screen.dart            # Page d'accueil client
    ├── shop_list_screen.dart                # Liste des boutiques
    ├── shop_detail_screen.dart              # Détails d'une boutique
    ├── product_detail_screen.dart           # Détails d'un produit
    ├── cart_screen.dart                     # Panier d'achat
    ├── customer_orders_screen.dart          # Historique des commandes client
    ├── favorites_screen.dart                # Produits favoris
    └── chat_screen.dart                     # Messagerie avec les vendeurs
```
```

## Installation

1. Assurez-vous d'avoir Flutter installé (SDK ^3.9.2)

2. Installez les dépendances :
```bash
flutter pub get
```

3. Lancez l'application :
```bash
flutter run
```

## Dépendances

- `provider` : Gestion d'état
- `image_picker` : Sélection d'images
- `geolocator` : Géolocalisation
- `geocoding` : Géocodage
- `shared_preferences` : Stockage local
- `cached_network_image` : Cache d'images réseau
- `flutter_svg` : Support SVG
- `http` : Requêtes HTTP
- `intl` : Formatage de dates

## Stockage des Données

L'application utilise actuellement `SharedPreferences` pour le stockage local.

Pour une application de production, il est recommandé d'utiliser :
- Une base de données locale (SQLite avec sqflite)
- Un backend avec API REST
- Firebase ou un autre service cloud

## Catégories de Produits Disponibles

1. Vente de produit frais
2. Produit cosmétique
3. Vente d'accessoire et d'électroménager
4. Bazar et vente de choses diverses
5. Vente de vêtements en tout genre
6. Vente de matériel scolaire
7. Vente d'aliment en conserve
8. Appareil électronique
9. Ustensile de cuisine
10. Coiffure et mèche
11. Produit d'hygiène
12. Luminaire
13. Literie et meuble
14. Laine et accessoire de crochet
15. Mercerie
16. Chaussure et chaussette
17. Bijoux
18. Matériaux de construction
19. Vente de nourriture transformée
20. Parapluie, imperméable et tout ce qui est waterproof

## Notes

- L'application est actuellement en mode développement avec stockage local
- Certaines fonctionnalités sont marquées "à venir" et nécessitent une implémentation complète
- Pour la production, il faudra intégrer un backend et une base de données
- Les images sont stockées localement (chemin de fichier) - pour la production, utilisez un service de stockage cloud

## Licence

Ce projet est une application Flutter pour une marketplace e-commerce.

