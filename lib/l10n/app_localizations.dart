import 'package:flutter/material.dart';

/// Localisations de l'application (Français/Anglais)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'app_title': 'Store Self',
      'welcome': 'Bienvenue',
      'login': 'Se connecter',
      'register': 'Créer un compte',
      'home': 'Accueil',
      'cart': 'Panier',
      'orders': 'Commandes',
      'favorites': 'Favoris',
      'messages': 'Messages',
      'profile': 'Profil',
      'search': 'Rechercher',
      'add_to_cart': 'Ajouter au panier',
      'price': 'Prix',
      'quantity': 'Quantité',
      'total': 'Total',
      'checkout': 'Passer la commande',
      'delivery': 'Livraison',
      'pickup': 'Retrait en magasin',
      'payment_method': 'Méthode de paiement',
      'address': 'Adresse',
      'reviews': 'Avis',
      'rating': 'Note',
      'comment': 'Commentaire',
      'submit': 'Envoyer',
      'cancel': 'Annuler',
      'save': 'Enregistrer',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'add': 'Ajouter',
      'remove': 'Retirer',
      'confirm': 'Confirmer',
      'budget_limit': 'Limite de budget',
      'purchase_history': 'Historique des achats',
      'tracking_list': 'Liste d\'attente',
      'stories': 'Stories',
      'live_shopping': 'Live Shopping',
      'support': 'Support',
      'report': 'Signaler',
      'settings': 'Paramètres',
      'language': 'Langue',
      'french': 'Français',
      'english': 'Anglais',
      'offline_mode': 'Mode hors connexion',
      'no_internet': 'Pas de connexion Internet',
      'sync': 'Synchroniser',
    },
    'en': {
      'app_title': 'Store Self',
      'welcome': 'Welcome',
      'login': 'Login',
      'register': 'Create account',
      'home': 'Home',
      'cart': 'Cart',
      'orders': 'Orders',
      'favorites': 'Favorites',
      'messages': 'Messages',
      'profile': 'Profile',
      'search': 'Search',
      'add_to_cart': 'Add to cart',
      'price': 'Price',
      'quantity': 'Quantity',
      'total': 'Total',
      'checkout': 'Checkout',
      'delivery': 'Delivery',
      'pickup': 'Store pickup',
      'payment_method': 'Payment method',
      'address': 'Address',
      'reviews': 'Reviews',
      'rating': 'Rating',
      'comment': 'Comment',
      'submit': 'Submit',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'remove': 'Remove',
      'confirm': 'Confirm',
      'budget_limit': 'Budget limit',
      'purchase_history': 'Purchase history',
      'tracking_list': 'Tracking list',
      'stories': 'Stories',
      'live_shopping': 'Live Shopping',
      'support': 'Support',
      'report': 'Report',
      'settings': 'Settings',
      'language': 'Language',
      'french': 'French',
      'english': 'English',
      'offline_mode': 'Offline mode',
      'no_internet': 'No Internet connection',
      'sync': 'Sync',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get appTitle => translate('app_title');
  String get welcome => translate('welcome');
  String get login => translate('login');
  String get register => translate('register');
  String get home => translate('home');
  String get cart => translate('cart');
  String get orders => translate('orders');
  String get favorites => translate('favorites');
  String get messages => translate('messages');
  String get profile => translate('profile');
  String get search => translate('search');
  String get addToCart => translate('add_to_cart');
  String get price => translate('price');
  String get quantity => translate('quantity');
  String get total => translate('total');
  String get checkout => translate('checkout');
  String get delivery => translate('delivery');
  String get pickup => translate('pickup');
  String get paymentMethod => translate('payment_method');
  String get address => translate('address');
  String get reviews => translate('reviews');
  String get rating => translate('rating');
  String get comment => translate('comment');
  String get submit => translate('submit');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get remove => translate('remove');
  String get confirm => translate('confirm');
  String get budgetLimit => translate('budget_limit');
  String get purchaseHistory => translate('purchase_history');
  String get trackingList => translate('tracking_list');
  String get stories => translate('stories');
  String get liveShopping => translate('live_shopping');
  String get support => translate('support');
  String get report => translate('report');
  String get settings => translate('settings');
  String get language => translate('language');
  String get french => translate('french');
  String get english => translate('english');
  String get offlineMode => translate('offline_mode');
  String get noInternet => translate('no_internet');
  String get sync => translate('sync');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}


