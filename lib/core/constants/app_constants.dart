/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Agripoa';
  static const String appVersion = '1.0.0';
  
  // API & Network
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache
  static const int cacheExpiryHours = 24;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int phoneNumberLength = 10;
  
  // Milk Collection
  static const double minMilkQuantity = 0.5;
  static const double maxMilkQuantity = 15.0;
  static const double milkQuantityIncrement = 0.5;
  
  // Private constructor to prevent instantiation
  AppConstants._();
}
