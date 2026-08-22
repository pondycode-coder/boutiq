class CameroonConfig {
  static const String currencyCode = 'XAF';
  static const String currencySymbol = 'FCFA';
  static const String localeFr = 'fr_CM';
  static const String localeEn = 'en_CM';

  static double vatRate = 0.1925;

  static const List<String> regions = [
    'Adamaoua',
    'Centre',
    'Est',
    'Extrême-Nord',
    'Littoral',
    'Nord',
    'Nord-Ouest',
    'Ouest',
    'Sud',
    'Sud-Ouest',
  ];

  static const Map<String, List<String>> divisionsByRegion = {
    'Adamaoua': ['Djérem', 'Faro-et-Déo', 'Mayo-Banyo', 'Mbéré', 'Vina'],
    'Centre': ['Haute-Sanaga', 'Lékifié', 'Mbam-et-Inoubou', 'Mbam-et-Kim', 'Méfou-et-Afamba', 'Méfou-et-Akono', 'Mfoundi', 'Nyong-et-Kellé', 'Nyong-et-Mfoumou', 'Nyong-et-So\'o'],
    'Est': ['Boumba-et-Ngoko', 'Haut-Nyong', 'Kadey', 'Lom-et-Djérem'],
    'Extrême-Nord': ['Diamaré', 'Logone-et-Chari', 'Mayo-Danay', 'Mayo-Kani', 'Mayo-Sava', 'Mayo-Tsanaga'],
    'Littoral': ['Moungo', 'Nkam', 'Sanaga-Maritime', 'Wouri'],
    'Nord': ['Bénoué', 'Faro', 'Mayo-Louti', 'Mayo-Rey'],
    'Nord-Ouest': ['Boyo', 'Bui', 'Donga-Mantung', 'Menchum', 'Mezam', 'Momo', 'Ngo-Ketunjia'],
    'Ouest': ['Bamboutos', 'Haut-Nkam', 'Hauts-Plateaux', 'Koung-Khi', 'Menoua', 'Mifi', 'Ndé', 'Noun'],
    'Sud': ['Dja-et-Lobo', 'Mvila', 'Océan', 'Vallée-du-Ntem'],
    'Sud-Ouest': ['Fako', 'Koupé-Manengouba', 'Lebialem', 'Manyu', 'Meme', 'Ndian'],
  };

  static const Map<String, String> paymentMethods = {
    'cash': 'Espèces',
    'mtn_momo': 'MTN Mobile Money',
    'orange_money': 'Orange Money',
    'bank_transfer': 'Virement bancaire',
    'check': 'Chèque',
  };

  static const Map<String, String> paymentStatuses = {
    'pending': 'En attente',
    'paid': 'Payé',
    'partial': 'Partiellement payé',
    'failed': 'Échoué',
    'refunded': 'Remboursé',
  };

  static const Map<String, String> orderStatuses = {
    'draft': 'Brouillon',
    'confirmed': 'Confirmé',
    'preparing': 'En préparation',
    'ready': 'Prêt pour livraison',
    'out_for_delivery': 'En cours de livraison',
    'delivered': 'Livré',
    'partial': 'Livraison partielle',
    'cancelled': 'Annulé',
    'returned': 'Retourné',
  };

  static const Map<String, String> deliveryStatuses = {
    'scheduled': 'Programmé',
    'in_progress': 'En cours',
    'completed': 'Terminé',
    'failed': 'Échoué',
    'rescheduled': 'Reprogrammé',
  };

  static const Map<String, String> bottleConditions = {
    'good': 'Bon état',
    'damaged': 'Endommagé',
    'broken': 'Cassé',
    'missing': 'Manquant',
  };

  static const Map<String, String> clientTypes = {
    'wholesaler': 'Grossiste',
    'retailer': 'Détaillant',
    'supermarket': 'Supermarché',
    'restaurant': 'Restaurant/Bar',
    'hotel': 'Hôtel',
    'depot': 'Dépôt',
  };

  static const List<String> languages = ['fr', 'en'];

  static const Map<String, double> bottleDeposits = {
    'beer_65cl': 100.0,
    'beer_33cl': 50.0,
    'soft_drink_1l': 50.0,
    'soft_drink_50cl': 30.0,
    'water_1_5l': 50.0,
    'water_50cl': 20.0,
  };

  static const List<String> bottleSizes = [
    '65cl', '33cl', '1L', '50cl', '1.5L', '25cl', '75cl'
  ];

  static const List<String> productCategories = [
    'Bière',
    'Boisson gazeuse',
    'Eau minérale',
    'Jus de fruit',
    'Boisson énergétique',
    'Autre',
  ];

  static const List<String> productCategoriesFr = [
    'Bière',
    'Boisson gazeuse',
    'Eau minérale',
    'Jus de fruit',
    'Boisson énergétique',
    'Autre',
  ];

  static const Map<String, String> daysOfWeek = {
    'monday': 'Lundi',
    'tuesday': 'Mardi',
    'wednesday': 'Mercredi',
    'thursday': 'Jeudi',
    'friday': 'Vendredi',
    'saturday': 'Samedi',
    'sunday': 'Dimanche',
  };

  static const Map<String, String> daysOfWeekShort = {
    'monday': 'Lun',
    'tuesday': 'Mar',
    'wednesday': 'Mer',
    'thursday': 'Jeu',
    'friday': 'Ven',
    'saturday': 'Sam',
    'sunday': 'Dim',
  };

  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} $currencySymbol';
  }

  static String formatCurrencyShort(double amount) {
    return '${amount.toStringAsFixed(0)} $currencySymbol';
  }

  static double calculateVat(double amount) {
    return amount * vatRate;
  }

  static double calculateTotalWithVat(double subtotal) {
    return subtotal + calculateVat(subtotal);
  }

  static String getRegionForDivision(String division) {
    for (var entry in divisionsByRegion.entries) {
      if (entry.value.contains(division)) {
        return entry.key;
      }
    }
    return '';
  }
}