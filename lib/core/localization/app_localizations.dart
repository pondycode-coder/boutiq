import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const List<Locale> supportedLocales = [
    Locale('fr', 'CM'),
    Locale('en', 'CM'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // App
  String get appName => locale.languageCode == 'fr' ? 'DistriTrack Cameroun' : 'DistriTrack Cameroon';

  // Auth
  String get login => locale.languageCode == 'fr' ? 'Connexion' : 'Login';
  String get pin => locale.languageCode == 'fr' ? 'Code PIN' : 'PIN';
  String get enterPin => locale.languageCode == 'fr' ? 'Entrez votre code PIN' : 'Enter your PIN';
  String get forgotPin => locale.languageCode == 'fr' ? 'Code PIN oublié?' : 'Forgot PIN?';
  String get loginButton => locale.languageCode == 'fr' ? 'Se connecter' : 'Login';

  // Navigation
  String get pos => locale.languageCode == 'fr' ? 'Caisse' : 'POS';
  String get orders => locale.languageCode == 'fr' ? 'Commandes' : 'Orders';
  String get reports => locale.languageCode == 'fr' ? 'Rapports' : 'Reports';
  String get dashboard => locale.languageCode == 'fr' ? 'Tableau de bord' : 'Dashboard';
  String get overview => locale.languageCode == 'fr' ? 'Vue d\'ensemble' : 'Overview';
  String get products => locale.languageCode == 'fr' ? 'Produits' : 'Products';
  String get staff => locale.languageCode == 'fr' ? 'Personnel' : 'Staff';
  String get clients => locale.languageCode == 'fr' ? 'Clients' : 'Clients';
  String get settings => locale.languageCode == 'fr' ? 'Paramètres' : 'Settings';
  String get logout => locale.languageCode == 'fr' ? 'Déconnexion' : 'Logout';

  // Support
  String get support => locale.languageCode == 'fr' ? 'Support' : 'Support';
  String get supportEmail => 'pondycode@gmail.com';
  String get supportPhone => '+237 674 667 234';
  String get contactSupport => locale.languageCode == 'fr' ? 'Contacter le support' : 'Contact Support';
  String get emailUs => locale.languageCode == 'fr' ? 'Nous envoyer un email' : 'Email Us';
  String get callUs => locale.languageCode == 'fr' ? 'Nous appeler' : 'Call Us';

  // Actions
  String get add => locale.languageCode == 'fr' ? 'Ajouter' : 'Add';
  String get edit => locale.languageCode == 'fr' ? 'Modifier' : 'Edit';
  String get delete => locale.languageCode == 'fr' ? 'Supprimer' : 'Delete';
  String get save => locale.languageCode == 'fr' ? 'Enregistrer' : 'Save';
  String get cancel => locale.languageCode == 'fr' ? 'Annuler' : 'Cancel';
  String get confirm => locale.languageCode == 'fr' ? 'Confirmer' : 'Confirm';
  String get search => locale.languageCode == 'fr' ? 'Rechercher' : 'Search';
  String get filter => locale.languageCode == 'fr' ? 'Filtrer' : 'Filter';
  String get sort => locale.languageCode == 'fr' ? 'Trier' : 'Sort';

  // Product
  String get name => locale.languageCode == 'fr' ? 'Nom' : 'Name';
  String get nameFr => locale.languageCode == 'fr' ? 'Nom (Français)' : 'Name (French)';
  String get code => locale.languageCode == 'fr' ? 'Code' : 'Code';
  String get category => locale.languageCode == 'fr' ? 'Catégorie' : 'Category';
  String get price => locale.languageCode == 'fr' ? 'Prix' : 'Price';
  String get salePrice => locale.languageCode == 'fr' ? 'Prix de vente' : 'Sale Price';
  String get costPrice => locale.languageCode == 'fr' ? 'Prix de revient' : 'Cost Price';
  String get margin => locale.languageCode == 'fr' ? 'Marge' : 'Margin';
  String get marginPercent => locale.languageCode == 'fr' ? 'Marge %' : 'Margin %';
  String get quantity => locale.languageCode == 'fr' ? 'Quantité' : 'Quantity';
  String get unit => locale.languageCode == 'fr' ? 'Unité' : 'Unit';
  String get total => locale.languageCode == 'fr' ? 'Total' : 'Total';
  String get subtotal => locale.languageCode == 'fr' ? 'Sous-total' : 'Subtotal';
  String get vat => locale.languageCode == 'fr' ? 'TVA (19,25%)' : 'VAT (19.25%)';
  String get vatRate => locale.languageCode == 'fr' ? 'Taux de TVA' : 'VAT Rate';
  String get stock => locale.languageCode == 'fr' ? 'Stock' : 'Stock';
  String get description => locale.languageCode == 'fr' ? 'Description' : 'Description';
  String get active => locale.languageCode == 'fr' ? 'Actif' : 'Active';
  String get inventoryValue => locale.languageCode == 'fr' ? 'Valeur du stock' : 'Inventory Value';
  String get stockCost => locale.languageCode == 'fr' ? 'Coût du stock' : 'Stock Cost';
  String get salesValue => locale.languageCode == 'fr' ? 'Valeur des ventes' : 'Sales Value';
  String get totalCostValue => locale.languageCode == 'fr' ? 'Coût total stock' : 'Total Cost Value';
  String get totalSalesValue => locale.languageCode == 'fr' ? 'Valeur totale ventes' : 'Total Sales Value';
  String get profit => locale.languageCode == 'fr' ? 'Bénéfice' : 'Profit';
  String get deposit => locale.languageCode == 'fr' ? 'Consigne' : 'Deposit';

  // Client
  String get client => locale.languageCode == 'fr' ? 'Client' : 'Client';
  String get clientType => locale.languageCode == 'fr' ? 'Type de client' : 'Client Type';
  String get region => locale.languageCode == 'fr' ? 'Région' : 'Region';
  String get division => locale.languageCode == 'fr' ? 'Département' : 'Division';
  String get subdivision => locale.languageCode == 'fr' ? 'Arrondissement' : 'Subdivision';
  String get address => locale.languageCode == 'fr' ? 'Adresse' : 'Address';
  String get phone => locale.languageCode == 'fr' ? 'Téléphone' : 'Phone';
  String get email => locale.languageCode == 'fr' ? 'Email' : 'Email';
  String get contactPerson => locale.languageCode == 'fr' ? 'Contact' : 'Contact Person';
  String get creditLimit => locale.languageCode == 'fr' ? 'Limite de crédit' : 'Credit Limit';
  String get currentBalance => locale.languageCode == 'fr' ? 'Solde actuel' : 'Current Balance';
  String get paymentTerms => locale.languageCode == 'fr' ? 'Conditions de paiement' : 'Payment Terms';

  // Order
  String get orderId => locale.languageCode == 'fr' ? 'N° Commande' : 'Order #';
  String get orderDate => locale.languageCode == 'fr' ? 'Date commande' : 'Order Date';
  String get status => locale.languageCode == 'fr' ? 'Statut' : 'Status';
  String get paymentMethod => locale.languageCode == 'fr' ? 'Mode de paiement' : 'Payment Method';
  String get paymentStatus => locale.languageCode == 'fr' ? 'Statut paiement' : 'Payment Status';
  String get items => locale.languageCode == 'fr' ? 'Articles' : 'Items';

  // Payment
  String get cash => locale.languageCode == 'fr' ? 'Espèces' : 'Cash';
  String get credit => locale.languageCode == 'fr' ? 'Crédit' : 'Credit';
  String get payLater => locale.languageCode == 'fr' ? 'Payer plus tard' : 'Pay Later';
  String get mtnMomo => locale.languageCode == 'fr' ? 'MTN MoMo' : 'MTN MoMo';
  String get orangeMoney => locale.languageCode == 'fr' ? 'Orange Money' : 'Orange Money';
  String get bankTransfer => locale.languageCode == 'fr' ? 'Virement' : 'Bank Transfer';
  String get selectClientForCredit => locale.languageCode == 'fr' ? 'Sélectionnez un client pour la vente à crédit' : 'Select a client for credit sale';
  String get saleOnCreditRecorded => locale.languageCode == 'fr' ? 'Vente à crédit enregistrée pour' : 'Credit sale recorded for';

  // Status
  String get pending => locale.languageCode == 'fr' ? 'En attente' : 'Pending';
  String get confirmed => locale.languageCode == 'fr' ? 'Confirmé' : 'Confirmed';
  String get preparing => locale.languageCode == 'fr' ? 'En préparation' : 'Preparing';
  String get ready => locale.languageCode == 'fr' ? 'Prêt' : 'Ready';
  String get outForDelivery => locale.languageCode == 'fr' ? 'En livraison' : 'Out for Delivery';
  String get delivered => locale.languageCode == 'fr' ? 'Livré' : 'Delivered';
  String get partial => locale.languageCode == 'fr' ? 'Partiel' : 'Partial';
  String get cancelled => locale.languageCode == 'fr' ? 'Annulé' : 'Cancelled';
  String get failed => locale.languageCode == 'fr' ? 'Échoué' : 'Failed';

  // Staff
  String get role => locale.languageCode == 'fr' ? 'Rôle' : 'Role';
  String get pinLabel => locale.languageCode == 'fr' ? 'PIN' : 'PIN';
  String get admin => locale.languageCode == 'fr' ? 'Administrateur' : 'Admin';
  String get salesperson => locale.languageCode == 'fr' ? 'Vendeur' : 'Salesperson';

  // Client Types
  String get retail => locale.languageCode == 'fr' ? 'Détaillant' : 'Retail';
  String get wholesale => locale.languageCode == 'fr' ? 'Grossiste' : 'Wholesale';
  String get corporate => locale.languageCode == 'fr' ? 'Entreprise' : 'Corporate';

  // Reports
  String get salesReport => locale.languageCode == 'fr' ? 'Rapport des ventes' : 'Sales Report';
  String get stockReport => locale.languageCode == 'fr' ? 'Rapport de stock' : 'Stock Report';
  String get totalSales => locale.languageCode == 'fr' ? 'CA Total' : 'Total Sales';
  String get totalVat => locale.languageCode == 'fr' ? 'TVA Totale' : 'Total VAT';
  String get totalOrders => locale.languageCode == 'fr' ? 'Nb Commandes' : 'Total Orders';
  String get period => locale.languageCode == 'fr' ? 'Période' : 'Period';
  String get generatedAt => locale.languageCode == 'fr' ? 'Généré le' : 'Generated At';
  String get today => locale.languageCode == 'fr' ? "Aujourd'hui" : 'Today';
  String get thisWeek => locale.languageCode == 'fr' ? 'Cette semaine' : 'This Week';
  String get thisMonth => locale.languageCode == 'fr' ? 'Ce mois' : 'This Month';

  // Sync
  String get sync => locale.languageCode == 'fr' ? 'Synchroniser' : 'Sync';
  String get syncNowLabel => locale.languageCode == 'fr' ? 'Synchroniser maintenant' : 'Sync Now';
  String get lastSync => locale.languageCode == 'fr' ? 'Dernière sync' : ' Last Sync';
  String get offlineMode => locale.languageCode == 'fr' ? 'Mode hors ligne' : 'Offline Mode';
  String get online => locale.languageCode == 'fr' ? 'En ligne' : 'Online';
  String get offline => locale.languageCode == 'fr' ? 'Hors ligne' : 'Offline';

  // Settings
  String get taxCurrency => locale.languageCode == 'fr' ? 'Taxe & Devise' : 'Tax & Currency';
  String get vatRateLabel => locale.languageCode == 'fr' ? 'Taux de TVA (%)' : 'VAT Rate (%)';
  String get currentVatRate => locale.languageCode == 'fr' ? 'Taux actuel' : 'Current Rate';
  String get saveVatRate => locale.languageCode == 'fr' ? 'Enregistrer le taux' : 'Save VAT Rate';
  String get vatRateSaved => locale.languageCode == 'fr' ? 'Taux de TVA mis à jour' : 'VAT rate updated';
  String get invalidVatRate => locale.languageCode == 'fr' ? 'Taux de TVA invalide (0-100)' : 'Invalid VAT rate (0-100)';
  String get cloudSync => locale.languageCode == 'fr' ? 'Synchronisation Cloud' : 'Cloud Sync';
  String get connectedToSupabase => locale.languageCode == 'fr' ? 'Connecté à Supabase' : 'Connected to Supabase';
  String get supabaseNotConfigured => locale.languageCode == 'fr' ? 'Supabase non configuré' : 'Supabase not configured';
  String get pushToCloud => locale.languageCode == 'fr' ? 'Envoyer vers le cloud' : 'Push to Cloud';
  String get pullFromCloud => locale.languageCode == 'fr' ? 'Récupérer du cloud' : 'Pull from Cloud';
  String get data => locale.languageCode == 'fr' ? 'Données' : 'Data';
  String get appInfo => locale.languageCode == 'fr' ? 'Infos application' : 'App Info';
  String get version => locale.languageCode == 'fr' ? 'Version' : 'Version';
  String get privacyPolicy => locale.languageCode == 'fr' ? 'Politique de confidentialité' : 'Privacy Policy';
  String get termsOfService => locale.languageCode == 'fr' ? 'Conditions d\'utilisation' : 'Terms of Service';
  String get account => locale.languageCode == 'fr' ? 'Compte' : 'Account';

  // Language
  String get language => locale.languageCode == 'fr' ? 'Langue' : 'Language';
  String get french => locale.languageCode == 'fr' ? 'Français' : 'French';
  String get english => locale.languageCode == 'fr' ? 'Anglais' : 'English';

  // Common
  String get success => locale.languageCode == 'fr' ? 'Succès' : 'Success';
  String get error => locale.languageCode == 'fr' ? 'Erreur' : 'Error';
  String get warning => locale.languageCode == 'fr' ? 'Attention' : 'Warning';
  String get info => locale.languageCode == 'fr' ? 'Info' : 'Info';
  String get noData => locale.languageCode == 'fr' ? 'Aucune donnée' : 'No Data';
  String get loading => locale.languageCode == 'fr' ? 'Chargement...' : 'Loading...';
  String get retry => locale.languageCode == 'fr' ? 'Réessayer' : 'Retry';
  String get confirmDelete => locale.languageCode == 'fr' ? 'Confirmer la suppression?' : 'Confirm delete?';
  String get deleteMessage => locale.languageCode == 'fr' ? 'Cette action est irréversible.' : 'This action cannot be undone.';
  String get yes => locale.languageCode == 'fr' ? 'Oui' : 'Yes';
  String get no => locale.languageCode == 'fr' ? 'Non' : 'No';

  // Product dialog
  String get addProduct => locale.languageCode == 'fr' ? 'Ajouter un produit' : 'Add Product';
  String get editProduct => locale.languageCode == 'fr' ? 'Modifier le produit' : 'Edit Product';
  String get deleteProduct => locale.languageCode == 'fr' ? 'Supprimer le produit' : 'Delete Product';
  String get fillRequiredFields => locale.languageCode == 'fr' ? 'Veuillez remplir tous les champs obligatoires' : 'Please fill all required fields';

  // Staff dialog
  String get addStaff => locale.languageCode == 'fr' ? 'Ajouter personnel' : 'Add Staff';
  String get editStaff => locale.languageCode == 'fr' ? 'Modifier personnel' : 'Edit Staff';
  String get deleteStaff => locale.languageCode == 'fr' ? 'Supprimer personnel' : 'Delete Staff';
  String get nameRequired => locale.languageCode == 'fr' ? 'Le nom est requis' : 'Name is required';
  String get pinRequired => locale.languageCode == 'fr' ? 'Le PIN est requis pour le nouveau personnel' : 'PIN is required for new staff';

  // Client dialog
  String get addClient => locale.languageCode == 'fr' ? 'Ajouter client' : 'Add Client';
  String get editClient => locale.languageCode == 'fr' ? 'Modifier client' : 'Edit Client';
  String get deleteClient => locale.languageCode == 'fr' ? 'Supprimer client' : 'Delete Client';

  // POS
  String get cashRegister => locale.languageCode == 'fr' ? 'Caisse enregistreuse' : 'Cash Register';
  String get cartEmpty => locale.languageCode == 'fr' ? 'Panier vide' : 'Cart is empty';
  String get completeSale => locale.languageCode == 'fr' ? 'Finaliser la vente' : 'Complete Sale';
  String get clearCart => locale.languageCode == 'fr' ? 'Vider le panier' : 'Clear Cart';
  String get walkInCustomer => locale.languageCode == 'fr' ? 'Client occasionnel' : 'Walk-in customer';
  String get cashPayment => locale.languageCode == 'fr' ? 'Paiement espèces' : 'Cash Payment';
  String get totalDue => locale.languageCode == 'fr' ? 'Total dû' : 'Total due';
  String get amountReceived => locale.languageCode == 'fr' ? 'Montant reçu' : 'Amount received';
  String get change => locale.languageCode == 'fr' ? 'Monnaie' : 'Change';
  String get orderCompleted => locale.languageCode == 'fr' ? 'Commande terminée' : 'Order completed';
  String get stockReturned => locale.languageCode == 'fr' ? 'Stock retourné' : 'Stock returned';
  String get noProducts => locale.languageCode == 'fr' ? 'Aucun produit. Ajoutez des produits d\'abord.' : 'No products. Add products first.';

  // Categories
  String get allCategories => locale.languageCode == 'fr' ? 'Toutes' : 'All';
  String get beer => locale.languageCode == 'fr' ? 'Bière' : 'Beer';
  String get softDrink => locale.languageCode == 'fr' ? 'Boisson gazeuse' : 'Soft Drink';
  String get water => locale.languageCode == 'fr' ? 'Eau minérale' : 'Water';
  String get juice => locale.languageCode == 'fr' ? 'Jus de fruit' : 'Juice';
  String get energyDrink => locale.languageCode == 'fr' ? 'Boisson énergisante' : 'Energy Drink';
  String get otherCategory => locale.languageCode == 'fr' ? 'Autre' : 'Other';

  // Dashboard
  String get salesTrend => locale.languageCode == 'fr' ? 'Tendance des ventes' : 'Sales Trend';
  String get topStaff => locale.languageCode == 'fr' ? 'Meilleurs vendeurs' : 'Top Staff';
  String get quickStats => locale.languageCode == 'fr' ? 'Statistiques rapides' : 'Quick Stats';
  String get totalProductsLabel => locale.languageCode == 'fr' ? 'Total produits' : 'Total Products';
  String get activeProductsLabel => locale.languageCode == 'fr' ? 'Produits actifs' : 'Active Products';
  String get lowStockAlert => locale.languageCode == 'fr' ? 'Alerte stock bas' : 'Low Stock Alert';
  String get activeStaffLabel => locale.languageCode == 'fr' ? 'Personnel actif' : 'Active Staff';
  String get weeklySales => locale.languageCode == 'fr' ? 'Ventes hebdo' : 'Weekly Sales';
  String get weeklyOrders => locale.languageCode == 'fr' ? 'Commandes hebdo' : 'Weekly Orders';
  String get salesToday => locale.languageCode == 'fr' ? 'Ventes aujourd\'hui' : 'Sales Today';
  String get ordersToday => locale.languageCode == 'fr' ? 'Commandes aujourd\'hui' : 'Orders Today';
  String get cashCollected => locale.languageCode == 'fr' ? 'Espèces encaissées' : 'Cash Collected';
  String get bySalesperson => locale.languageCode == 'fr' ? 'Par vendeur' : 'By salesperson';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}