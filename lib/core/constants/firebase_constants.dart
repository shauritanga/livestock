/// Firebase collection and field name constants
class FirebaseConstants {
  // Top-level Collections
  static const String cooperativesCollection = 'cooperatives';
  static const String farmersCollection = 'farmers';
  static const String cattleCollection = 'cattle';
  static const String milkDeliveriesCollection = 'milkDeliveries';
  static const String insurancePoliciesCollection = 'insurancePolicies';
  static const String loansCollection = 'loans';
  static const String repaymentsCollection = 'repayments';
  static const String claimsCollection = 'claims';
  static const String offtakersCollection = 'offtakers';
  static const String salesCollection = 'sales';
  static const String productsCollection = 'products';
  static const String productionBatchesCollection = 'productionBatches';
  static const String productSalesCollection = 'productSales';
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String alertsCollection = 'alerts';
  static const String scheduledReportsCollection = 'scheduled_reports';
  static const String premiumRatesCollection = 'premiumRates';
  static const String locationsCollection = 'locations';
  static const String configCollection = 'config';
  static const String stockTransactionsCollection = 'stock_transactions';
  static const String saleTransactionsCollection = 'sale_transactions';
  static const String analyticsCacheCollection = 'analytics_cache';
  
  // Subcollections (nested under parent documents)
  static const String premiumPaymentsSubcollection = 'premiumPayments';
  static const String claimsSubcollection = 'claims';
  
  // Storage paths
  static const String cattleMuzzleImagesPath = 'cattle_muzzle_images';
  static const String farmerPhotosPath = 'farmer_photos';
  static const String claimDocumentsPath = 'claim_documents';
  
  // Private constructor to prevent instantiation
  FirebaseConstants._();
}
