class CameroonConstants {
  static const String countryCode = 'CM';
  static const String currencyCode = 'XAF';
  static const String currencySymbol = 'FCFA';
  static const double vatRate = 0.1925;
  static const int defaultPaymentTermsDays = 30;

  static const List<String> regions = [
    'Adamawa',
    'Centre',
    'East',
    'FarNorth',
    'Littoral',
    'North',
    'Northwest',
    'South',
    'Southwest',
    'West',
  ];

  static const Map<String, List<String>> divisionsByRegion = {
    'Adamawa': ['Djérem', 'Faro-et-Déo', 'Mayo-Banyo', 'Mbéré', 'Vina'],
    'Centre': ['Haute-Sanaga', 'Lekié', 'Mbam-et-Inoubou', 'Mbam-et-Kim', 'Méfou-et-Afamba', 'Méfou-et-Akono', 'Mfoundi', 'Nyong-et-Kéllé', 'Nyong-et-Mfoumou', 'Nyong-et-So\'o'],
    'East': ['Boumba-et-Ngoko', 'Haut-Nyong', 'Kadey', 'Lom-et-Djérem'],
    'FarNorth': ['Diamaré', 'Logone-et-Chari', 'Mayo-Danay', 'Mayo-Kani', 'Mayo-Sava', 'Mayo-Tsanaga'],
    'Littoral': ['Mouffa', 'Nkam', 'Sanaga-Maritime', 'Wouri'],
    'North': ['Bénoué', 'Faro', 'Mayo-Louti', 'Mayo-Rey'],
    'Northwest': ['Bui', 'Donga-Mantung', 'Menchum', 'Mezam', 'Momo', 'Ngo-Ketunjia', 'Boyo'],
    'South': ['Dja-et-Lobo', 'Mvila', 'Océan', 'Vallée-du-Ntem'],
    'Southwest': ['Fako', 'Koupé-Manengouba', 'Lebialem', 'Manyu', 'Meme', 'Ndian'],
    'West': ['Bamboutos', 'Haut-Nkam', 'Haut-Plateaux', 'Koung-Khi', 'Menoua', 'Mifi', 'Ndé', 'Noun'],
  };

  static const Map<String, String> regionNamesFr = {
    'Adamawa': 'Adamaoua',
    'Centre': 'Centre',
    'East': 'Est',
    'FarNorth': 'Extrême-Nord',
    'Littoral': 'Littoral',
    'North': 'Nord',
    'Northwest': 'Nord-Ouest',
    'South': 'Sud',
    'Southwest': 'Sud-Ouest',
    'West': 'Ouest',
  };

  static const List<String> clientTypes = [
    'Wholesaler',
    'Retailer',
    'Supermarket',
    'Restaurant',
    'Bar',
    'Hotel',
    'Event Organizer',
    'Institution',
    'Other',
  ];

  static const List<String> clientTypesFr = [
    'Grossiste',
    'Détaillant',
    'Supermarché',
    'Restaurant',
    'Bar',
    'Hôtel',
    'Organisateur événement',
    'Institution',
    'Autre',
  ];

  static const List<String> paymentMethods = [
    'Cash',
    'MTN MoMo',
    'Orange Money',
    'Bank Transfer',
    'Check',
    'Credit',
  ];

  static const List<String> paymentMethodsFr = [
    'Espèces',
    'MTN MoMo',
    'Orange Money',
    'Virement bancaire',
    'Chèque',
    'Crédit',
  ];

  static const List<String> orderStatuses = [
    'Draft',
    'Confirmed',
    'Processing',
    'Ready for Delivery',
    'Out for Delivery',
    'Delivered',
    'Partially Delivered',
    'Cancelled',
    'Returned',
  ];

  static const List<String> orderStatusesFr = [
    'Brouillon',
    'Confirmé',
    'En préparation',
    'Prêt pour livraison',
    'En livraison',
    'Livré',
    'Partiellement livré',
    'Annulé',
    'Retourné',
  ];

  static const List<String> deliveryStatuses = [
    'Pending',
    'Assigned',
    'Out for Delivery',
    'Delivered',
    'Failed',
    'Rescheduled',
  ];

  static const List<String> deliveryStatusesFr = [
    'En attente',
    'Assigné',
    'En livraison',
    'Livré',
    'Échec',
    'Replanifié',
  ];

  static const List<String> productCategories = [
    'Beer',
    'Soft Drink',
    'Water',
    'Juice',
    'Energy Drink',
    'Other',
  ];

  static const List<String> productCategoriesFr = [
    'Bière',
    'Boisson gazeuse',
    'Eau minérale',
    'Jus de fruit',
    'Boisson énergisante',
    'Autre',
  ];

  static const List<String> bottleSizes = [
    '25cl',
    '33cl',
    '50cl',
    '65cl',
    '75cl',
    '1L',
    '1.5L',
    '2L',
  ];

  static const Map<String, double> defaultBottleDeposits = {
    '25cl': 25.0,
    '33cl': 25.0,
    '50cl': 50.0,
    '65cl': 50.0,
    '75cl': 75.0,
    '1L': 100.0,
    '1.5L': 150.0,
    '2L': 200.0,
  };

  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> daysOfWeekFr = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  static const int maxCreditDaysOverdue = 90;
  static const double minOrderAmount = 5000.0;
  static const double freeDeliveryThreshold = 100000.0;
}