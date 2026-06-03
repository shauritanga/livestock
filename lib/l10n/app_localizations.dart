import 'package:flutter/material.dart';

/// Localization class for the application
/// Supports English (en) and Swahili (sw)
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  /// Get the current localization instance from context
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  /// Localization delegate
  static const LocalizationsDelegate<AppLocalizations> delegate = 
      _AppLocalizationsDelegate();
  
  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('sw', ''), // Swahili
  ];
  
  // Common translations
  String get appName => _localizedValues[locale.languageCode]!['app_name']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;
  
  // Authentication
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get phoneNumber => _localizedValues[locale.languageCode]!['phone_number']!;
  String get appSubtitle => _localizedValues[locale.languageCode]!['app_subtitle']!;
  String get forgotPassword => _localizedValues[locale.languageCode]!['forgot_password']!;
  String get loginWithEmail => _localizedValues[locale.languageCode]!['login_with_email']!;
  String get loginWithPhone => _localizedValues[locale.languageCode]!['login_with_phone']!;
  String get resetPassword => _localizedValues[locale.languageCode]!['reset_password']!;
  String get resetPasswordTitle => _localizedValues[locale.languageCode]!['reset_password_title']!;
  String get resetPasswordInstructions => _localizedValues[locale.languageCode]!['reset_password_instructions']!;
  String get sendResetLink => _localizedValues[locale.languageCode]!['send_reset_link']!;
  String get sendResetCode => _localizedValues[locale.languageCode]!['send_reset_code']!;
  String get resetEmailSent => _localizedValues[locale.languageCode]!['reset_email_sent']!;
  String get resetSmsSent => _localizedValues[locale.languageCode]!['reset_sms_sent']!;
  String get resetEmailError => _localizedValues[locale.languageCode]!['reset_email_error']!;
  String get resetSmsError => _localizedValues[locale.languageCode]!['reset_sms_error']!;
  String get backToLogin => _localizedValues[locale.languageCode]!['back_to_login']!;
  String get enterEmailOrPhone => _localizedValues[locale.languageCode]!['enter_email_or_phone']!;
  String get resetMethod => _localizedValues[locale.languageCode]!['reset_method']!;
  String get useEmail => _localizedValues[locale.languageCode]!['use_email']!;
  String get usePhone => _localizedValues[locale.languageCode]!['use_phone']!;
  
  // Farmer Management
  String get registerFarmer => _localizedValues[locale.languageCode]!['register_farmer']!;
  String get farmerName => _localizedValues[locale.languageCode]!['farmer_name']!;
  String get farmerList => _localizedValues[locale.languageCode]!['farmer_list']!;
  
  // Milk Collection
  String get recordMilk => _localizedValues[locale.languageCode]!['record_milk']!;
  String get milkQuantity => _localizedValues[locale.languageCode]!['milk_quantity']!;
  String get qualityGrade => _localizedValues[locale.languageCode]!['quality_grade']!;
  String get paymentAmount => _localizedValues[locale.languageCode]!['payment_amount']!;
  String get milkCollection => _localizedValues[locale.languageCode]!['milk_collection']!;
  String get recordCollection => _localizedValues[locale.languageCode]!['record_collection']!;
  String get pleaseLogIn => _localizedValues[locale.languageCode]!['please_log_in']!;
  String get viewAllHistory => _localizedValues[locale.languageCode]!['view_all_history']!;
  String get viewAllHistoryComingSoon => _localizedValues[locale.languageCode]!['view_all_history_coming_soon']!;
  String get recentCollections => _localizedValues[locale.languageCode]!['recent_collections']!;
  String get today => _localizedValues[locale.languageCode]!['today']!;
  String get noCollectionsToday => _localizedValues[locale.languageCode]!['no_collections_today']!;
  String get deliveryHistory => _localizedValues[locale.languageCode]!['delivery_history']!;
  String get collectionDate => _localizedValues[locale.languageCode]!['collection_date']!;
  String get collectionTime => _localizedValues[locale.languageCode]!['collection_time']!;
  String get morning => _localizedValues[locale.languageCode]!['morning']!;
  String get evening => _localizedValues[locale.languageCode]!['evening']!;
  String get selectDate => _localizedValues[locale.languageCode]!['select_date']!;
  
  // Cattle Management
  String get registerCattle => _localizedValues[locale.languageCode]!['register_cattle']!;
  String get cattleList => _localizedValues[locale.languageCode]!['cattle_list']!;
  String get cattleTracking => _localizedValues[locale.languageCode]!['cattle_tracking']!;
  String get viewAllCattle => _localizedValues[locale.languageCode]!['view_all_cattle']!;
  String get cattleListComingSoon => _localizedValues[locale.languageCode]!['cattle_list_coming_soon']!;
  String get cattleRegistrationComingSoon => _localizedValues[locale.languageCode]!['cattle_registration_coming_soon']!;
  String get searchCattleHint => _localizedValues[locale.languageCode]!['search_cattle_hint']!;
  String get viewManageCattle => _localizedValues[locale.languageCode]!['view_manage_cattle']!;
  String get lactating => _localizedValues[locale.languageCode]!['lactating']!;
  String get dry => _localizedValues[locale.languageCode]!['dry']!;
  String get pregnant => _localizedValues[locale.languageCode]!['pregnant']!;
  String get calves => _localizedValues[locale.languageCode]!['calves']!;
  String get calf => _localizedValues[locale.languageCode]!['calf']!;
  String get yesterday => _localizedValues[locale.languageCode]!['yesterday']!;
  
  // Dashboard
  String get dashboard => _localizedValues[locale.languageCode]!['dashboard']!;
  String get todayCollection => _localizedValues[locale.languageCode]!['today_collection']!;
  String get totalFarmers => _localizedValues[locale.languageCode]!['total_farmers']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get farmers => _localizedValues[locale.languageCode]!['farmers']!;
  String get cattle => _localizedValues[locale.languageCode]!['cattle']!;
  String get collection => _localizedValues[locale.languageCode]!['collection']!;
  String get more => _localizedValues[locale.languageCode]!['more']!;
  String get analytics => _localizedValues[locale.languageCode]!['analytics']!;
  String get analyticsReport => _localizedValues[locale.languageCode]!['analytics_report']!;
  String get goodMorning => _localizedValues[locale.languageCode]!['good_morning']!;
  String get goodAfternoon => _localizedValues[locale.languageCode]!['good_afternoon']!;
  String get goodEvening => _localizedValues[locale.languageCode]!['good_evening']!;
  String get totalLiters => _localizedValues[locale.languageCode]!['total_liters']!;
  String get payment => _localizedValues[locale.languageCode]!['payment']!;
  String get recentDeliveries => _localizedValues[locale.languageCode]!['recent_deliveries']!;
  String get viewAll => _localizedValues[locale.languageCode]!['view_all']!;
  String get noDeliveriesRecorded => _localizedValues[locale.languageCode]!['no_deliveries_recorded']!;
  String get errorLoadingDeliveries => _localizedValues[locale.languageCode]!['error_loading_deliveries']!;
  String get unknownFarmer => _localizedValues[locale.languageCode]!['unknown_farmer']!;
  String get justNow => _localizedValues[locale.languageCode]!['just_now']!;
  String get minAgo => _localizedValues[locale.languageCode]!['min_ago']!;
  String get syncingData => _localizedValues[locale.languageCode]!['syncing_data']!;
  String get offlineMode => _localizedValues[locale.languageCode]!['offline_mode']!;
  String get syncError => _localizedValues[locale.languageCode]!['sync_error']!;
  String get allDataSynced => _localizedValues[locale.languageCode]!['all_data_synced']!;
  String get itemsPending => _localizedValues[locale.languageCode]!['items_pending']!;
  String get lastSynced => _localizedValues[locale.languageCode]!['last_synced']!;
  String get tapToViewDetails => _localizedValues[locale.languageCode]!['tap_to_view_details']!;
  String get noCollectionData => _localizedValues[locale.languageCode]!['no_collection_data']!;
  String get errorLoadingSummary => _localizedValues[locale.languageCode]!['error_loading_summary']!;
  String get errorLoadingTrend => _localizedValues[locale.languageCode]!['error_loading_trend']!;
  String get week => _localizedValues[locale.languageCode]!['week']!;
  String get month => _localizedValues[locale.languageCode]!['month']!;
  String get year => _localizedValues[locale.languageCode]!['year']!;
  
  // Settings
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get notificationsSubtitle => _localizedValues[locale.languageCode]!['notifications_subtitle']!;
  String get darkTheme => _localizedValues[locale.languageCode]!['dark_theme']!;
  String get darkThemeSubtitle => _localizedValues[locale.languageCode]!['dark_theme_subtitle']!;
  String get privacy => _localizedValues[locale.languageCode]!['privacy']!;
  String get privacySubtitle => _localizedValues[locale.languageCode]!['privacy_subtitle']!;
  String get security => _localizedValues[locale.languageCode]!['security']!;
  String get securitySubtitle => _localizedValues[locale.languageCode]!['security_subtitle']!;
  String get helpSupport => _localizedValues[locale.languageCode]!['help_support']!;
  String get helpSupportSubtitle => _localizedValues[locale.languageCode]!['help_support_subtitle']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get aboutSubtitle => _localizedValues[locale.languageCode]!['about_subtitle']!;
  String get logOut => _localizedValues[locale.languageCode]!['log_out']!;
  String get deleteAccount => _localizedValues[locale.languageCode]!['delete_account']!;
  String get general => _localizedValues[locale.languageCode]!['general']!;
  String get privacySecurity => _localizedValues[locale.languageCode]!['privacy_security']!;
  String get support => _localizedValues[locale.languageCode]!['support']!;
  String get account => _localizedValues[locale.languageCode]!['account']!;
  String get selectLanguage => _localizedValues[locale.languageCode]!['select_language']!;
  String get financialServices => _localizedValues[locale.languageCode]!['financial_services']!;
  String get insurance => _localizedValues[locale.languageCode]!['insurance']!;
  String get insuranceSubtitle => _localizedValues[locale.languageCode]!['insurance_subtitle']!;
  String get loans => _localizedValues[locale.languageCode]!['loans']!;
  String get loansSubtitle => _localizedValues[locale.languageCode]!['loans_subtitle']!;
  String get records => _localizedValues[locale.languageCode]!['records']!;
  String get inventory => _localizedValues[locale.languageCode]!['inventory']!;
  String get inventorySubtitle => _localizedValues[locale.languageCode]!['inventory_subtitle']!;
  String get sales => _localizedValues[locale.languageCode]!['sales']!;
  String get salesSubtitle => _localizedValues[locale.languageCode]!['sales_subtitle']!;
  String get offTakers => _localizedValues[locale.languageCode]!['off_takers']!;
  String get offTakersSubtitle => _localizedValues[locale.languageCode]!['off_takers_subtitle']!;
  String get createOffTaker => _localizedValues[locale.languageCode]!['create_off_taker']!;
  String get businessName => _localizedValues[locale.languageCode]!['business_name']!;
  String get contactPerson => _localizedValues[locale.languageCode]!['contact_person']!;
  String get offTakerCategory => _localizedValues[locale.languageCode]!['off_taker_category']!;
  String get selectOffTaker => _localizedValues[locale.languageCode]!['select_off_taker']!;
  String get business => _localizedValues[locale.languageCode]!['business']!;
  String get entrance => _localizedValues[locale.languageCode]!['entrance']!;
  String get entranceSubtitle => _localizedValues[locale.languageCode]!['entrance_subtitle']!;
  String get stock => _localizedValues[locale.languageCode]!['stock']!;
  String get stockSubtitle => _localizedValues[locale.languageCode]!['stock_subtitle']!;
  String get expenses => _localizedValues[locale.languageCode]!['expenses']!;
  String get expensesSubtitle => _localizedValues[locale.languageCode]!['expenses_subtitle']!;
  String get addExpense => _localizedValues[locale.languageCode]!['add_expense']!;
  String get expenseDescription => _localizedValues[locale.languageCode]!['expense_description']!;
  String get expenseAmount => _localizedValues[locale.languageCode]!['expense_amount']!;
  String get expenseCategory => _localizedValues[locale.languageCode]!['expense_category']!;
  String get expenseDate => _localizedValues[locale.languageCode]!['expense_date']!;
  String get totalExpenses => _localizedValues[locale.languageCode]!['total_expenses']!;
  String get recentExpenses => _localizedValues[locale.languageCode]!['recent_expenses']!;
  String get noExpensesYet => _localizedValues[locale.languageCode]!['no_expenses_yet']!;
  String get spendingByCategory => _localizedValues[locale.languageCode]!['spending_by_category']!;
  String get categoryFeed => _localizedValues[locale.languageCode]!['category_feed']!;
  String get categoryVeterinary => _localizedValues[locale.languageCode]!['category_veterinary']!;
  String get categoryTransport => _localizedValues[locale.languageCode]!['category_transport']!;
  String get categoryUtilities => _localizedValues[locale.languageCode]!['category_utilities']!;
  String get categorySalaries => _localizedValues[locale.languageCode]!['category_salaries']!;
  String get categoryMaintenance => _localizedValues[locale.languageCode]!['category_maintenance']!;
  String get categorySupplies => _localizedValues[locale.languageCode]!['category_supplies']!;
  String get categoryOther => _localizedValues[locale.languageCode]!['category_other']!;
  String get expenseCreatedSuccessfully => _localizedValues[locale.languageCode]!['expense_created_successfully']!;
  String get failedToCreateExpense => _localizedValues[locale.languageCode]!['failed_to_create_expense']!;
  String get failedToLoadExpenses => _localizedValues[locale.languageCode]!['failed_to_load_expenses']!;
  String get descriptionRequired => _localizedValues[locale.languageCode]!['description_required']!;
  String get amountRequired => _localizedValues[locale.languageCode]!['amount_required']!;
  String get amountMustBePositive => _localizedValues[locale.languageCode]!['amount_must_be_positive']!;
  String get expensesRecorded => _localizedValues[locale.languageCode]!['expenses_recorded']!;
  String get filterByDate => _localizedValues[locale.languageCode]!['filter_by_date']!;
  String get startDate => _localizedValues[locale.languageCode]!['start_date']!;
  String get endDate => _localizedValues[locale.languageCode]!['end_date']!;
  String get notSet => _localizedValues[locale.languageCode]!['not_set']!;
  String get clear => _localizedValues[locale.languageCode]!['clear']!;
  String get apply => _localizedValues[locale.languageCode]!['apply']!;
  String get custom => _localizedValues[locale.languageCode]!['custom']!;
  String get history => _localizedValues[locale.languageCode]!['history']!;
  String get historySubtitle => _localizedValues[locale.languageCode]!['history_subtitle']!;
  String get profileSubtitle => _localizedValues[locale.languageCode]!['profile_subtitle']!;
  String get settingsSubtitle => _localizedValues[locale.languageCode]!['settings_subtitle']!;
  String get notificationSettingsComingSoon => _localizedValues[locale.languageCode]!['notification_settings_coming_soon']!;
  String get privacySettingsComingSoon => _localizedValues[locale.languageCode]!['privacy_settings_coming_soon']!;
  String get securitySettingsComingSoon => _localizedValues[locale.languageCode]!['security_settings_coming_soon']!;
  String get darkThemeEnabled => _localizedValues[locale.languageCode]!['dark_theme_enabled']!;
  String get darkThemeDisabled => _localizedValues[locale.languageCode]!['dark_theme_disabled']!;
  String get needHelp => _localizedValues[locale.languageCode]!['need_help']!;
  String get supportEmail => _localizedValues[locale.languageCode]!['support_email']!;
  String get supportPhone => _localizedValues[locale.languageCode]!['support_phone']!;
  String get supportHours => _localizedValues[locale.languageCode]!['support_hours']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;
  String get build => _localizedValues[locale.languageCode]!['build']!;
  String get appDescription => _localizedValues[locale.languageCode]!['app_description']!;
  String get copyright => _localizedValues[locale.languageCode]!['copyright']!;
  String get logOutConfirm => _localizedValues[locale.languageCode]!['log_out_confirm']!;
  String get logOutFailed => _localizedValues[locale.languageCode]!['log_out_failed']!;
  String get deleteAccountConfirm => _localizedValues[locale.languageCode]!['delete_account_confirm']!;
  String get deleteAccountComingSoon => _localizedValues[locale.languageCode]!['delete_account_coming_soon']!;

  // Insurance - General
  String get insuranceManagement => _localizedValues[locale.languageCode]!['insurance_management']!;
  String get enrollInInsurance => _localizedValues[locale.languageCode]!['enroll_in_insurance']!;
  String get viewPolicies => _localizedValues[locale.languageCode]!['view_policies']!;
  String get submitClaim => _localizedValues[locale.languageCode]!['submit_claim']!;
  String get insurancePolicy => _localizedValues[locale.languageCode]!['insurance_policy']!;
  String get policies => _localizedValues[locale.languageCode]!['policies']!;
  String get claims => _localizedValues[locale.languageCode]!['claims']!;
  String get premium => _localizedValues[locale.languageCode]!['premium']!;
  String get coverage => _localizedValues[locale.languageCode]!['coverage']!;
  
  // Insurance Enrollment
  String get insuranceEnrollment => _localizedValues[locale.languageCode]!['insurance_enrollment']!;
  String get selectFarmer => _localizedValues[locale.languageCode]!['select_farmer']!;
  String get selectCattle => _localizedValues[locale.languageCode]!['select_cattle']!;
  String get selectedCattle => _localizedValues[locale.languageCode]!['selected_cattle']!;
  String get selectCattleToInsure => _localizedValues[locale.languageCode]!['select_cattle_to_insure']!;
  String get noCattleAvailable => _localizedValues[locale.languageCode]!['no_cattle_available']!;
  String get selectAtLeastOneCattle => _localizedValues[locale.languageCode]!['select_at_least_one_cattle']!;
  String get productiveCattle => _localizedValues[locale.languageCode]!['productive_cattle']!;
  String get calculatingPremium => _localizedValues[locale.languageCode]!['calculating_premium']!;
  String get premiumCalculation => _localizedValues[locale.languageCode]!['premium_calculation']!;
  String get premiumBreakdown => _localizedValues[locale.languageCode]!['premium_breakdown']!;
  String get totalAnnualPremium => _localizedValues[locale.languageCode]!['total_annual_premium']!;
  String get paymentFrequency => _localizedValues[locale.languageCode]!['payment_frequency']!;
  String get monthly => _localizedValues[locale.languageCode]!['monthly']!;
  String get quarterly => _localizedValues[locale.languageCode]!['quarterly']!;
  String get monthlyInstallment => _localizedValues[locale.languageCode]!['monthly_installment']!;
  String get quarterlyInstallment => _localizedValues[locale.languageCode]!['quarterly_installment']!;
  String get policySummary => _localizedValues[locale.languageCode]!['policy_summary']!;
  String get policyDuration => _localizedValues[locale.languageCode]!['policy_duration']!;
  String get months12 => _localizedValues[locale.languageCode]!['months_12']!;
  String get enrolling => _localizedValues[locale.languageCode]!['enrolling']!;
  String get enrollmentSuccess => _localizedValues[locale.languageCode]!['enrollment_success']!;
  String get enrollmentFailed => _localizedValues[locale.languageCode]!['enrollment_failed']!;
  String get policyCreated => _localizedValues[locale.languageCode]!['policy_created']!;
  
  // Policy Management
  String get policyNumber => _localizedValues[locale.languageCode]!['policy_number']!;
  String get policyStatus => _localizedValues[locale.languageCode]!['policy_status']!;
  String get policyStartDate => _localizedValues[locale.languageCode]!['policy_start_date']!;
  String get policyEndDate => _localizedValues[locale.languageCode]!['policy_end_date']!;
  String get policyDetails => _localizedValues[locale.languageCode]!['policy_details']!;
  String get coveredCattle => _localizedValues[locale.languageCode]!['covered_cattle']!;
  String get coveredCattleCount => _localizedValues[locale.languageCode]!['covered_cattle_count']!;
  String get active => _localizedValues[locale.languageCode]!['active']!;
  String get expired => _localizedValues[locale.languageCode]!['expired']!;
  String get suspended => _localizedValues[locale.languageCode]!['suspended']!;
  String get cancelled => _localizedValues[locale.languageCode]!['cancelled']!;
  String get all => _localizedValues[locale.languageCode]!['all']!;
  String get noPoliciesFound => _localizedValues[locale.languageCode]!['no_policies_found']!;
  String get searchPolicies => _localizedValues[locale.languageCode]!['search_policies']!;
  String get filterByStatus => _localizedValues[locale.languageCode]!['filter_by_status']!;
  
  // Premium Information
  String get premiumInformation => _localizedValues[locale.languageCode]!['premium_information']!;
  String get totalPremium => _localizedValues[locale.languageCode]!['total_premium']!;
  String get installmentAmount => _localizedValues[locale.languageCode]!['installment_amount']!;
  String get totalPaid => _localizedValues[locale.languageCode]!['total_paid']!;
  String get outstandingBalance => _localizedValues[locale.languageCode]!['outstanding_balance']!;
  String get nextPaymentDue => _localizedValues[locale.languageCode]!['next_payment_due']!;
  String get paymentHistory => _localizedValues[locale.languageCode]!['payment_history']!;
  String get paymentDate => _localizedValues[locale.languageCode]!['payment_date']!;
  String get paymentMethod => _localizedValues[locale.languageCode]!['payment_method']!;
  String get milkDeduction => _localizedValues[locale.languageCode]!['milk_deduction']!;
  String get cash => _localizedValues[locale.languageCode]!['cash']!;
  String get mobileMoney => _localizedValues[locale.languageCode]!['mobile_money']!;
  String get noPaymentsRecorded => _localizedValues[locale.languageCode]!['no_payments_recorded']!;
  String get overduePremium => _localizedValues[locale.languageCode]!['overdue_premium']!;
  String get daysUntilExpiry => _localizedValues[locale.languageCode]!['days_until_expiry']!;
  String get renewPolicy => _localizedValues[locale.languageCode]!['renew_policy']!;
  
  // Claims
  String get claimSubmission => _localizedValues[locale.languageCode]!['claim_submission']!;
  String get claimHistory => _localizedValues[locale.languageCode]!['claim_history']!;
  String get claimDetails => _localizedValues[locale.languageCode]!['claim_details']!;
  String get claimNumber => _localizedValues[locale.languageCode]!['claim_number']!;
  String get claimStatus => _localizedValues[locale.languageCode]!['claim_status']!;
  String get claimAmount => _localizedValues[locale.languageCode]!['claim_amount']!;
  String get settlementAmount => _localizedValues[locale.languageCode]!['settlement_amount']!;
  String get selectPolicy => _localizedValues[locale.languageCode]!['select_policy']!;
  String get selectCattleForClaim => _localizedValues[locale.languageCode]!['select_cattle_for_claim']!;
  String get lossType => _localizedValues[locale.languageCode]!['loss_type']!;
  String get death => _localizedValues[locale.languageCode]!['death']!;
  String get theft => _localizedValues[locale.languageCode]!['theft']!;
  String get disease => _localizedValues[locale.languageCode]!['disease']!;
  String get lossDate => _localizedValues[locale.languageCode]!['loss_date']!;
  String get description => _localizedValues[locale.languageCode]!['description']!;
  String get describeCircumstances => _localizedValues[locale.languageCode]!['describe_circumstances']!;
  String get supportingDocuments => _localizedValues[locale.languageCode]!['supporting_documents']!;
  String get uploadDocument => _localizedValues[locale.languageCode]!['upload_document']!;
  String get uploadPhoto => _localizedValues[locale.languageCode]!['upload_photo']!;
  String get takePhoto => _localizedValues[locale.languageCode]!['take_photo']!;
  String get chooseFromGallery => _localizedValues[locale.languageCode]!['choose_from_gallery']!;
  String get uploading => _localizedValues[locale.languageCode]!['uploading']!;
  String get documentUploaded => _localizedValues[locale.languageCode]!['document_uploaded']!;
  String get submitting => _localizedValues[locale.languageCode]!['submitting']!;
  String get claimSubmitted => _localizedValues[locale.languageCode]!['claim_submitted']!;
  String get claimSubmissionFailed => _localizedValues[locale.languageCode]!['claim_submission_failed']!;
  String get submitted => _localizedValues[locale.languageCode]!['submitted']!;
  String get underReview => _localizedValues[locale.languageCode]!['under_review']!;
  String get approved => _localizedValues[locale.languageCode]!['approved']!;
  String get rejected => _localizedValues[locale.languageCode]!['rejected']!;
  String get settled => _localizedValues[locale.languageCode]!['settled']!;
  String get noClaimsFound => _localizedValues[locale.languageCode]!['no_claims_found']!;
  String get submissionDate => _localizedValues[locale.languageCode]!['submission_date']!;
  String get settlementDate => _localizedValues[locale.languageCode]!['settlement_date']!;
  String get reviewComments => _localizedValues[locale.languageCode]!['review_comments']!;
  String get claimTimeline => _localizedValues[locale.languageCode]!['claim_timeline']!;
  
  // Insurance Eligibility
  String get insuranceEligibility => _localizedValues[locale.languageCode]!['insurance_eligibility']!;
  String get notEligibleForLoan => _localizedValues[locale.languageCode]!['not_eligible_for_loan']!;
  String get insuranceRequired => _localizedValues[locale.languageCode]!['insurance_required']!;
  String get allProductiveCattleMustBeInsured => _localizedValues[locale.languageCode]!['all_productive_cattle_must_be_insured']!;
  String get uncoveredCattle => _localizedValues[locale.languageCode]!['uncovered_cattle']!;
  String get getInsuranceNow => _localizedValues[locale.languageCode]!['get_insurance_now']!;
  
  // Loans
  String get applyForLoan => _localizedValues[locale.languageCode]!['apply_for_loan']!;
  String get loanDetails => _localizedValues[locale.languageCode]!['loan_details']!;
  String get loanAmount => _localizedValues[locale.languageCode]!['loan_amount']!;
  String get loanTerm => _localizedValues[locale.languageCode]!['loan_term']!;
  String get interestRate => _localizedValues[locale.languageCode]!['interest_rate']!;
  String get perMonth => _localizedValues[locale.languageCode]!['per_month']!;
  String get annually => _localizedValues[locale.languageCode]!['annually']!;
  String get repaymentSchedule => _localizedValues[locale.languageCode]!['repayment_schedule']!;
  String get principal => _localizedValues[locale.languageCode]!['principal']!;
  String get totalInterest => _localizedValues[locale.languageCode]!['total_interest']!;
  String get totalRepayment => _localizedValues[locale.languageCode]!['total_repayment']!;
  String get monthlyPayment => _localizedValues[locale.languageCode]!['monthly_payment']!;
  String get repaymentDeductedFromMilkPayments => _localizedValues[locale.languageCode]!['repayment_deducted_from_milk_payments']!;
  String get eligibilityStatus => _localizedValues[locale.languageCode]!['eligibility_status']!;
  String get insuranceVerified => _localizedValues[locale.languageCode]!['insurance_verified']!;
  String get loanEligible => _localizedValues[locale.languageCode]!['loan_eligible']!;
  String get submitApplication => _localizedValues[locale.languageCode]!['submit_application']!;
  String get applicationSubmitted => _localizedValues[locale.languageCode]!['application_submitted']!;
  String get months => _localizedValues[locale.languageCode]!['months']!;
  String get outstanding => _localizedValues[locale.languageCode]!['outstanding']!;
  String get completed => _localizedValues[locale.languageCode]!['completed']!;
  String get pending => _localizedValues[locale.languageCode]!['pending']!;
  
  // Error Messages
  String get policyNotActive => _localizedValues[locale.languageCode]!['policy_not_active']!;
  String get cattleNotCovered => _localizedValues[locale.languageCode]!['cattle_not_covered']!;
  String get duplicateClaim => _localizedValues[locale.languageCode]!['duplicate_claim']!;
  String get invalidPremiumAmount => _localizedValues[locale.languageCode]!['invalid_premium_amount']!;
  String get noActivePolicies => _localizedValues[locale.languageCode]!['no_active_policies']!;
  String get errorLoadingPolicies => _localizedValues[locale.languageCode]!['error_loading_policies']!;
  String get errorLoadingClaims => _localizedValues[locale.languageCode]!['error_loading_claims']!;
  String get errorCalculatingPremium => _localizedValues[locale.languageCode]!['error_calculating_premium']!;
  
  // SMS Notification Templates (for reference)
  String get smsEnrollmentConfirmation => _localizedValues[locale.languageCode]!['sms_enrollment_confirmation']!;
  String get smsPremiumDeducted => _localizedValues[locale.languageCode]!['sms_premium_deducted']!;
  String get smsPremiumReminder => _localizedValues[locale.languageCode]!['sms_premium_reminder']!;
  String get smsPolicyExpiring => _localizedValues[locale.languageCode]!['sms_policy_expiring']!;
  String get smsClaimSubmitted => _localizedValues[locale.languageCode]!['sms_claim_submitted']!;
  String get smsClaimApproved => _localizedValues[locale.languageCode]!['sms_claim_approved']!;
  String get smsClaimRejected => _localizedValues[locale.languageCode]!['sms_claim_rejected']!;
  String get smsClaimSettled => _localizedValues[locale.languageCode]!['sms_claim_settled']!;

  // Sync
  String get syncStatus => _localizedValues[locale.languageCode]!['sync_status']!;
  String get syncing => _localizedValues[locale.languageCode]!['syncing']!;
  String get syncNow => _localizedValues[locale.languageCode]!['sync_now']!;
  String get syncCompleted => _localizedValues[locale.languageCode]!['sync_completed']!;
  String get allSynced => _localizedValues[locale.languageCode]!['all_synced']!;
  String get allSyncedSubtitle => _localizedValues[locale.languageCode]!['all_synced_subtitle']!;
  String get pendingSync => _localizedValues[locale.languageCode]!['pending_sync']!;
  String offlineSubtitle(int count) => _localizedValues[locale.languageCode]!['offline_subtitle']!.replaceAll('{count}', count.toString());
  String pendingSyncSubtitle(int count) => _localizedValues[locale.languageCode]!['pending_sync_subtitle']!.replaceAll('{count}', count.toString());
  String get syncErrorSubtitle => _localizedValues[locale.languageCode]!['sync_error_subtitle']!;
  String get connectionStatus => _localizedValues[locale.languageCode]!['connection_status']!;
  String get online => _localizedValues[locale.languageCode]!['online']!;
  String get offline => _localizedValues[locale.languageCode]!['offline']!;
  String get pendingItems => _localizedValues[locale.languageCode]!['pending_items']!;
  String get lastSync => _localizedValues[locale.languageCode]!['last_sync']!;
  String get never => _localizedValues[locale.languageCode]!['never']!;
  String minutesAgo(int minutes) => _localizedValues[locale.languageCode]!['minutes_ago']!.replaceAll('{minutes}', minutes.toString());
  String hoursAgo(int hours) => _localizedValues[locale.languageCode]!['hours_ago']!.replaceAll('{hours}', hours.toString());
  String daysAgo(int days) => _localizedValues[locale.languageCode]!['days_ago']!.replaceAll('{days}', days.toString());
  String get offlineMessage => _localizedValues[locale.languageCode]!['offline_message']!;
  String get aboutSync => _localizedValues[locale.languageCode]!['about_sync']!;
  String get syncDescription => _localizedValues[locale.languageCode]!['sync_description']!;
  
  // Farmer Self-Service (non-duplicate getters only)
  String get quickLinks => _localizedValues[locale.languageCode]!['quick_links']!;
  String get milkHistory => _localizedValues[locale.languageCode]!['milk_history']!;
  String get myCattle => _localizedValues[locale.languageCode]!['my_cattle']!;
  String get thisMonth => _localizedValues[locale.languageCode]!['this_month']!;
  String get deliveries => _localizedValues[locale.languageCode]!['deliveries']!;
  String get earnings => _localizedValues[locale.languageCode]!['earnings']!;
  String get pendingPayment => _localizedValues[locale.languageCode]!['pending_payment']!;
  String get loanBalance => _localizedValues[locale.languageCode]!['loan_balance']!;
  String get insuranceStatus => _localizedValues[locale.languageCode]!['insurance_status']!;
  String get inactive => _localizedValues[locale.languageCode]!['inactive']!;
  String get cattleCovered => _localizedValues[locale.languageCode]!['cattle_covered']!;
  String get allTime => _localizedValues[locale.languageCode]!['all_time']!;
  String get lastWeek => _localizedValues[locale.languageCode]!['last_week']!;
  String get noDeliveriesFound => _localizedValues[locale.languageCode]!['no_deliveries_found']!;
  String get totalCattle => _localizedValues[locale.languageCode]!['total_cattle']!;
  String get avgProduction => _localizedValues[locale.languageCode]!['avg_production']!;
  String get noCattleRegistered => _localizedValues[locale.languageCode]!['no_cattle_registered']!;
  String get errorLoadingCattle => _localizedValues[locale.languageCode]!['error_loading_cattle']!;
  String get avgDaily => _localizedValues[locale.languageCode]!['avg_daily']!;
  String get lastDelivery => _localizedValues[locale.languageCode]!['last_delivery']!;
  String get noActiveLoans => _localizedValues[locale.languageCode]!['no_active_loans']!;
  String get applyForLoanToGetStarted => _localizedValues[locale.languageCode]!['apply_for_loan_to_get_started']!;
  String get activeLoans => _localizedValues[locale.languageCode]!['active_loans']!;
  String get completedLoans => _localizedValues[locale.languageCode]!['completed_loans']!;
  String get errorLoadingLoans => _localizedValues[locale.languageCode]!['error_loading_loans']!;
  String get inputLoan => _localizedValues[locale.languageCode]!['input_loan']!;
  String get repaymentProgress => _localizedValues[locale.languageCode]!['repayment_progress']!;
  String get disbursed => _localizedValues[locale.languageCode]!['disbursed']!;
  String get defaulted => _localizedValues[locale.languageCode]!['defaulted']!;
  String get loanSummary => _localizedValues[locale.languageCode]!['loan_summary']!;
  String get disbursementDate => _localizedValues[locale.languageCode]!['disbursement_date']!;
  String get noPaymentsYet => _localizedValues[locale.languageCode]!['no_payments_yet']!;
  String get errorLoadingPayments => _localizedValues[locale.languageCode]!['error_loading_payments']!;
  String get flat => _localizedValues[locale.languageCode]!['flat']!;
  String get reducingBalance => _localizedValues[locale.languageCode]!['reducing_balance']!;
  String get activePolicy => _localizedValues[locale.languageCode]!['active_policy']!;
  String get validUntil => _localizedValues[locale.languageCode]!['valid_until']!;
  String get noCoveredCattle => _localizedValues[locale.languageCode]!['no_covered_cattle']!;
  String get noClaimsSubmitted => _localizedValues[locale.languageCode]!['no_claims_submitted']!;
  String get profileSettings => _localizedValues[locale.languageCode]!['profile_settings']!;
  String get contactInformation => _localizedValues[locale.languageCode]!['contact_information']!;
  String get appSettings => _localizedValues[locale.languageCode]!['app_settings']!;
  String get manageNotificationSettings => _localizedValues[locale.languageCode]!['manage_notification_settings']!;
  String get pricingInformation => _localizedValues[locale.languageCode]!['pricing_information']!;
  String get currentMilkPrice => _localizedValues[locale.languageCode]!['current_milk_price']!;
  String get liter => _localizedValues[locale.languageCode]!['liter']!;
  String get priceVariesByQuality => _localizedValues[locale.languageCode]!['price_varies_by_quality']!;
  String get confirmLogout => _localizedValues[locale.languageCode]!['confirm_logout']!;
  
  // Analytics & Reporting
  String get analyticsDashboard => _localizedValues[locale.languageCode]!['analytics_dashboard']!;
  String get milkProduction => _localizedValues[locale.languageCode]!['milk_production']!;
  String get farmerDemographics => _localizedValues[locale.languageCode]!['farmer_demographics']!;
  String get livestock => _localizedValues[locale.languageCode]!['livestock']!;
  String get financial => _localizedValues[locale.languageCode]!['financial']!;
  String get overview => _localizedValues[locale.languageCode]!['overview']!;
  String get filter => _localizedValues[locale.languageCode]!['filter']!;
  String get export => _localizedValues[locale.languageCode]!['export']!;
  String get refresh => _localizedValues[locale.languageCode]!['refresh']!;
  
  // KPIs and Metrics
  String get totalMilkCollected => _localizedValues[locale.languageCode]!['total_milk_collected']!;
  String get averagePerDay => _localizedValues[locale.languageCode]!['average_per_day']!;
  String get averagePerFarmer => _localizedValues[locale.languageCode]!['average_per_farmer']!;
  String get qualityDistribution => _localizedValues[locale.languageCode]!['quality_distribution']!;
  String get premiumQuality => _localizedValues[locale.languageCode]!['premium_quality']!;
  String get standard => _localizedValues[locale.languageCode]!['standard']!;
  String get substandard => _localizedValues[locale.languageCode]!['substandard']!;
  String get productionTrend => _localizedValues[locale.languageCode]!['production_trend']!;
  String get collectionCenters => _localizedValues[locale.languageCode]!['collection_centers']!;
  String get peakHours => _localizedValues[locale.languageCode]!['peak_hours']!;
  String get vsLastPeriod => _localizedValues[locale.languageCode]!['vs_last_period']!;
  
  // Farmer Analytics
  String get newFarmers => _localizedValues[locale.languageCode]!['new_farmers']!;
  String get genderDistribution => _localizedValues[locale.languageCode]!['gender_distribution']!;
  String get male => _localizedValues[locale.languageCode]!['male']!;
  String get female => _localizedValues[locale.languageCode]!['female']!;
  String get ageDistribution => _localizedValues[locale.languageCode]!['age_distribution']!;
  String get geographicDistribution => _localizedValues[locale.languageCode]!['geographic_distribution']!;
  String get appAdoption => _localizedValues[locale.languageCode]!['app_adoption']!;
  String get creditScoreDistribution => _localizedValues[locale.languageCode]!['credit_score_distribution']!;
  String get registrationTrend => _localizedValues[locale.languageCode]!['registration_trend']!;
  
  // Livestock Analytics
  String get totalCattleCount => _localizedValues[locale.languageCode]!['total_cattle_count']!;
  String get lactationRate => _localizedValues[locale.languageCode]!['lactation_rate']!;
  String get breedDistribution => _localizedValues[locale.languageCode]!['breed_distribution']!;
  String get healthStatus => _localizedValues[locale.languageCode]!['health_status']!;
  String get healthy => _localizedValues[locale.languageCode]!['healthy']!;
  String get sick => _localizedValues[locale.languageCode]!['sick']!;
  String get underTreatment => _localizedValues[locale.languageCode]!['under_treatment']!;
  String get farmAssets => _localizedValues[locale.languageCode]!['farm_assets']!;
  String get avocadoTrees => _localizedValues[locale.languageCode]!['avocado_trees']!;
  String get chickens => _localizedValues[locale.languageCode]!['chickens']!;
  String get beehives => _localizedValues[locale.languageCode]!['beehives']!;
  
  // Financial Analytics
  String get totalPayments => _localizedValues[locale.languageCode]!['total_payments']!;
  String get averagePricePerLiter => _localizedValues[locale.languageCode]!['average_price_per_liter']!;
  String get paymentTrend => _localizedValues[locale.languageCode]!['payment_trend']!;
  String get loanMetrics => _localizedValues[locale.languageCode]!['loan_metrics']!;
  String get totalDisbursed => _localizedValues[locale.languageCode]!['total_disbursed']!;
  String get totalOutstanding => _localizedValues[locale.languageCode]!['total_outstanding']!;
  String get repaymentRate => _localizedValues[locale.languageCode]!['repayment_rate']!;
  String get defaultRate => _localizedValues[locale.languageCode]!['default_rate']!;
  String get insuranceMetrics => _localizedValues[locale.languageCode]!['insurance_metrics']!;
  String get activePolicies => _localizedValues[locale.languageCode]!['active_policies']!;
  String get premiumCollected => _localizedValues[locale.languageCode]!['premium_collected']!;
  String get coveragePercentage => _localizedValues[locale.languageCode]!['coverage_percentage']!;
  String get revenueBreakdown => _localizedValues[locale.languageCode]!['revenue_breakdown']!;
  
  // Inventory Analytics
  String get totalInventoryValue => _localizedValues[locale.languageCode]!['total_inventory_value']!;
  String get lowStockProducts => _localizedValues[locale.languageCode]!['low_stock_products']!;
  String get outOfStockProducts => _localizedValues[locale.languageCode]!['out_of_stock_products']!;
  String get salesRevenue => _localizedValues[locale.languageCode]!['sales_revenue']!;
  String get topSellingProducts => _localizedValues[locale.languageCode]!['top_selling_products']!;
  String get categoryBreakdown => _localizedValues[locale.languageCode]!['category_breakdown']!;
  String get stockTurnoverRate => _localizedValues[locale.languageCode]!['stock_turnover_rate']!;
  
  // Comparative Analytics
  String get comparativeAnalytics => _localizedValues[locale.languageCode]!['comparative_analytics']!;
  String get currentPeriod => _localizedValues[locale.languageCode]!['current_period']!;
  String get comparisonPeriod => _localizedValues[locale.languageCode]!['comparison_period']!;
  String get percentageChange => _localizedValues[locale.languageCode]!['percentage_change']!;
  String get improving => _localizedValues[locale.languageCode]!['improving']!;
  String get declining => _localizedValues[locale.languageCode]!['declining']!;
  String get stable => _localizedValues[locale.languageCode]!['stable']!;
  String get benchmarking => _localizedValues[locale.languageCode]!['benchmarking']!;
  String get topPerformers => _localizedValues[locale.languageCode]!['top_performers']!;
  String get bottomPerformers => _localizedValues[locale.languageCode]!['bottom_performers']!;
  
  // Predictive Analytics
  String get predictiveAnalytics => _localizedValues[locale.languageCode]!['predictive_analytics']!;
  String get forecast => _localizedValues[locale.languageCode]!['forecast']!;
  String get trendLine => _localizedValues[locale.languageCode]!['trend_line']!;
  String get confidenceInterval => _localizedValues[locale.languageCode]!['confidence_interval']!;
  String get seasonalPatterns => _localizedValues[locale.languageCode]!['seasonal_patterns']!;
  String get projectedGrowth => _localizedValues[locale.languageCode]!['projected_growth']!;
  String get forecastDays => _localizedValues[locale.languageCode]!['forecast_days']!;
  String get days30 => _localizedValues[locale.languageCode]!['days_30']!;
  String get days60 => _localizedValues[locale.languageCode]!['days_60']!;
  String get days90 => _localizedValues[locale.languageCode]!['days_90']!;
  
  // Alerts
  String get alerts => _localizedValues[locale.languageCode]!['alerts']!;
  String get critical => _localizedValues[locale.languageCode]!['critical']!;
  String get warning => _localizedValues[locale.languageCode]!['warning']!;
  String get informational => _localizedValues[locale.languageCode]!['informational']!;
  String get productionDrop => _localizedValues[locale.languageCode]!['production_drop']!;
  String get lowStockAlert => _localizedValues[locale.languageCode]!['low_stock_alert']!;
  String get loanDefaultAlert => _localizedValues[locale.languageCode]!['loan_default_alert']!;
  String get insuranceLapseAlert => _localizedValues[locale.languageCode]!['insurance_lapse_alert']!;
  String get farmerEngagementAlert => _localizedValues[locale.languageCode]!['farmer_engagement_alert']!;
  String get qualityConcernAlert => _localizedValues[locale.languageCode]!['quality_concern_alert']!;
  String get markAsRead => _localizedValues[locale.languageCode]!['mark_as_read']!;
  String get dismiss => _localizedValues[locale.languageCode]!['dismiss']!;
  String get noAlertsFound => _localizedValues[locale.languageCode]!['no_alerts_found']!;
  
  // Reports
  String get reports => _localizedValues[locale.languageCode]!['reports']!;
  String get generateReport => _localizedValues[locale.languageCode]!['generate_report']!;
  String get reportTemplates => _localizedValues[locale.languageCode]!['report_templates']!;
  String get monthlySummary => _localizedValues[locale.languageCode]!['monthly_summary']!;
  String get quarterlyReview => _localizedValues[locale.languageCode]!['quarterly_review']!;
  String get annualReport => _localizedValues[locale.languageCode]!['annual_report']!;
  String get governmentSubmission => _localizedValues[locale.languageCode]!['government_submission']!;
  String get customReport => _localizedValues[locale.languageCode]!['custom_report']!;
  String get exportFormat => _localizedValues[locale.languageCode]!['export_format']!;
  String get pdf => _localizedValues[locale.languageCode]!['pdf']!;
  String get excel => _localizedValues[locale.languageCode]!['excel']!;
  String get csv => _localizedValues[locale.languageCode]!['csv']!;
  String get preview => _localizedValues[locale.languageCode]!['preview']!;
  String get download => _localizedValues[locale.languageCode]!['download']!;
  String get share => _localizedValues[locale.languageCode]!['share']!;
  String get scheduledReports => _localizedValues[locale.languageCode]!['scheduled_reports']!;
  String get scheduleReport => _localizedValues[locale.languageCode]!['schedule_report']!;
  String get frequency => _localizedValues[locale.languageCode]!['frequency']!;
  String get daily => _localizedValues[locale.languageCode]!['daily']!;
  String get weekly => _localizedValues[locale.languageCode]!['weekly']!;
  String get onDemand => _localizedValues[locale.languageCode]!['on_demand']!;
  String get recipients => _localizedValues[locale.languageCode]!['recipients']!;
  String get reportGenerated => _localizedValues[locale.languageCode]!['report_generated']!;
  String get reportGenerationFailed => _localizedValues[locale.languageCode]!['report_generation_failed']!;
  
  // Filters
  String get dateRange => _localizedValues[locale.languageCode]!['date_range']!;
  String get thisWeek => _localizedValues[locale.languageCode]!['this_week']!;
  String get thisQuarter => _localizedValues[locale.languageCode]!['this_quarter']!;
  String get thisYear => _localizedValues[locale.languageCode]!['this_year']!;
  String get customRange => _localizedValues[locale.languageCode]!['custom_range']!;
  String get cooperative => _localizedValues[locale.languageCode]!['cooperative']!;
  String get collectionCenter => _localizedValues[locale.languageCode]!['collection_center']!;
  String get location => _localizedValues[locale.languageCode]!['location']!;
  String get region => _localizedValues[locale.languageCode]!['region']!;
  String get district => _localizedValues[locale.languageCode]!['district']!;
  String get ward => _localizedValues[locale.languageCode]!['ward']!;
  String get village => _localizedValues[locale.languageCode]!['village']!;
  String get farmerFilters => _localizedValues[locale.languageCode]!['farmer_filters']!;
  String get gender => _localizedValues[locale.languageCode]!['gender']!;
  String get ageRange => _localizedValues[locale.languageCode]!['age_range']!;
  String get creditScoreRange => _localizedValues[locale.languageCode]!['credit_score_range']!;
  String get appAccessStatus => _localizedValues[locale.languageCode]!['app_access_status']!;
  String get cattleFilters => _localizedValues[locale.languageCode]!['cattle_filters']!;
  String get breed => _localizedValues[locale.languageCode]!['breed']!;
  String get lactationStatus => _localizedValues[locale.languageCode]!['lactation_status']!;
  String get healthStatusFilter => _localizedValues[locale.languageCode]!['health_status_filter']!;
  String get applyFilters => _localizedValues[locale.languageCode]!['apply_filters']!;
  String get resetFilters => _localizedValues[locale.languageCode]!['reset_filters']!;
  String get saveFilter => _localizedValues[locale.languageCode]!['save_filter']!;
  String get savedFilters => _localizedValues[locale.languageCode]!['saved_filters']!;
  String get filterName => _localizedValues[locale.languageCode]!['filter_name']!;
  
  // Chart Labels
  String get days7 => _localizedValues[locale.languageCode]!['days_7']!;
  String get days30Chart => _localizedValues[locale.languageCode]!['days_30_chart']!;
  String get days90Chart => _localizedValues[locale.languageCode]!['days_90_chart']!;
  String get months12Chart => _localizedValues[locale.languageCode]!['months_12_chart']!;
  String get liters => _localizedValues[locale.languageCode]!['liters']!;
  String get count => _localizedValues[locale.languageCode]!['count']!;
  String get percentage => _localizedValues[locale.languageCode]!['percentage']!;
  String get amount => _localizedValues[locale.languageCode]!['amount']!;
  String get date => _localizedValues[locale.languageCode]!['date']!;
  String get value => _localizedValues[locale.languageCode]!['value']!;
  
  // Error Messages
  String get errorLoadingAnalytics => _localizedValues[locale.languageCode]!['error_loading_analytics']!;
  String get insufficientData => _localizedValues[locale.languageCode]!['insufficient_data']!;
  String get invalidFilter => _localizedValues[locale.languageCode]!['invalid_filter']!;
  String get noDataAvailable => _localizedValues[locale.languageCode]!['no_data_available']!;
  String get errorGeneratingReport => _localizedValues[locale.languageCode]!['error_generating_report']!;
  
  // Loading States
  String get loadingAnalytics => _localizedValues[locale.languageCode]!['loading_analytics']!;
  String get calculatingMetrics => _localizedValues[locale.languageCode]!['calculating_metrics']!;
  String get generatingReport => _localizedValues[locale.languageCode]!['generating_report']!;
  String get exportingData => _localizedValues[locale.languageCode]!['exporting_data']!;
}

/// Translation maps
const Map<String, Map<String, String>> _localizedValues = {
  'en': {
    'app_name': 'Agripoa',
    'ok': 'OK',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'search': 'Search',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'retry': 'Retry',
    'login': 'Login',
    'logout': 'Logout',
    'email': 'Email',
    'password': 'Password',
    'phone_number': 'Phone Number',
    'app_subtitle': 'Digital Dairy Farming Platform',
    'forgot_password': 'Forgot Password?',
    'login_with_email': 'Login with Email',
    'login_with_phone': 'Login with Phone Number',
    'reset_password': 'Reset Password',
    'reset_password_title': 'Reset Your Password',
    'reset_password_instructions': 'Enter your email or phone number and we\'ll send you instructions to reset your password',
    'send_reset_link': 'Send Reset Link',
    'send_reset_code': 'Send Reset Code',
    'reset_email_sent': 'Password reset email sent! Check your inbox for instructions.',
    'reset_sms_sent': 'Password reset code sent! Check your messages for instructions.',
    'reset_email_error': 'Failed to send reset email. Please check the email address and try again.',
    'reset_sms_error': 'Failed to send reset code. Please check the phone number and try again.',
    'back_to_login': 'Back to Login',
    'enter_email_or_phone': 'Enter your email or phone number',
    'reset_method': 'Reset Method',
    'use_email': 'Use Email',
    'use_phone': 'Use Phone Number',
    'register_farmer': 'Register Farmer',
    'farmer_name': 'Farmer Name',
    'farmer_list': 'Farmer List',
    'record_milk': 'Record Milk',
    'milk_quantity': 'Milk Quantity',
    'quality_grade': 'Quality Grade',
    'payment_amount': 'Payment Amount',
    'milk_collection': 'Milk Collection',
    'record_collection': 'Record Collection',
    'please_log_in': 'Please log in',
    'view_all_history': 'View All History',
    'view_all_history_coming_soon': 'View all history coming soon',
    'recent_collections': 'Recent Collections',
    'today': 'Today',
    'no_collections_today': 'No collections recorded today',
    'delivery_history': 'Delivery History',
    'collection_date': 'Collection Date',
    'collection_time': 'Collection Time',
    'morning': 'Morning',
    'evening': 'Evening',
    'select_date': 'Select Date',
    'register_cattle': 'Register Cattle',
    'cattle_list': 'Cattle List',
    'cattle_tracking': 'Cattle Tracking',
    'view_all_cattle': 'View All Cattle',
    'cattle_list_coming_soon': 'Cattle list view coming soon',
    'cattle_registration_coming_soon': 'Cattle registration coming soon',
    'search_cattle_hint': 'Search cattle by tag, breed, or farmer...',
    'view_manage_cattle': 'View and manage all cattle across your cooperative',
    'lactating': 'Lactating',
    'dry': 'Dry',
    'pregnant': 'Pregnant',
    'calves': 'Calves',
    'calf': 'Calf',
    'yesterday': 'Yesterday',
    'inventory': 'Inventory',
    'sales': 'Sales',
    'off_takers': 'Off-Takers',
    'inventory_subtitle': 'Manage product inventory and stock',
    'sales_subtitle': 'Track sales and revenue',
    'off_takers_subtitle': 'Manage buyers and distributors',
    
    // Off-Takers Management (MVP)
    'create_off_taker': 'Create Off-Taker',
    'business_name': 'Business Name',
    'contact_person': 'Contact Person',
    'off_taker_category': 'Category',
    'select_off_taker': 'Select Off-Taker (Optional)',
    
    // Inventory Management
    'add_product': 'Add Product',
    'edit_product': 'Edit Product',
    'product_name': 'Product Name',
    'sku': 'SKU',
    'category': 'Category',
    'unit_of_measure': 'Unit of Measure',
    'unit_price': 'Unit Price',
    'reorder_point': 'Reorder Point',
    'current_stock': 'Current Stock',
    'initial_stock': 'Initial Stock',
    'low_stock_alert': 'Low Stock Alert',
    'products_need_restocking': 'products need restocking',
    'product_needs_restocking': 'product needs restocking',
    'no_products_registered': 'No products registered yet',
    'add_your_first_product': 'Add your first product to get started',
    'product_added_successfully': 'Product added successfully',
    'product_updated_successfully': 'Product updated successfully',
    'product_details': 'Product Details',
    'stock_summary': 'Stock Summary',
    'in_stock': 'In Stock',
    'low_stock': 'Low Stock',
    'out_of_stock': 'Out of Stock',
    'add_stock': 'Add Stock',
    'adjust_stock': 'Adjust Stock',
    'stock_added_successfully': 'Stock added successfully',
    'quantity_to_add': 'Quantity to Add',
    'new_stock_level': 'New Stock Level',
    'reason_notes': 'Reason/Notes',
    'transaction_history': 'Transaction History',
    'recent_activity': 'Recent Activity',
    'stock_addition': 'Stock Addition',
    'stock_adjustment': 'Stock Adjustment',
    'sale': 'Sale',
    'additions': 'Additions',
    'adjustments': 'Adjustments',
    'all': 'All',
    'pricing': 'Pricing',
    'inventory_value': 'Inventory Value',
    'active': 'Active',
    'inactive': 'Inactive',
    'active_status': 'Active Status',
    'product_is_active': 'Product is active and available',
    'product_is_inactive': 'Product is inactive',
    
    // Product Categories
    'animal_feed': 'Animal Feed',
    'veterinary_supplies': 'Veterinary Supplies',
    'farm_equipment': 'Farm Equipment',
    'seeds': 'Seeds',
    'fertilizers': 'Fertilizers',
    'other': 'Other',
    
    // Sales Management
    'record_sale': 'Record Sale',
    'sale_recorded_successfully': 'Sale recorded successfully',
    'recent_sales': 'Recent Sales',
    'no_sales_recorded': 'No sales recorded yet',
    'record_your_first_sale': 'Record your first sale to get started',
    'select_product': 'Select Product',
    'quantity': 'Quantity',
    'customer_name': 'Customer Name',
    'notes': 'Notes',
    'total_amount': 'Total Amount',
    'sale_details': 'Sale Details',
    'today_sales': 'Today',
    'this_week': 'This Week',
    'this_month': 'This Month',
    'sales_count': 'sales',
    'insufficient_stock': 'Insufficient stock',
    'only_available': 'Only {count} available',
    
    // Error Messages
    'product_name_required': 'Product name is required',
    'sku_required': 'SKU is required',
    'unit_price_required': 'Unit price is required',
    'quantity_required': 'Quantity is required',
    'quantity_must_be_positive': 'Quantity must be a positive number',
    'price_must_be_positive': 'Price must be a positive number',
    'product_not_found': 'Product not found',
    'error_loading_products': 'Error loading products',
    'error_loading_sales': 'Error loading sales',
    'sku_already_exists': 'SKU already exists',
    'network_error': 'Network error. Changes will sync when online',
    'offline_mode': 'Offline Mode',
    'syncing': 'Syncing...',
    'all_synced': 'All synced',
    'pending_sync': 'Pending sync',
    'business': 'BUSINESS',
    'entrance': 'Entrance',
    'entrance_subtitle': 'Record milk intake and receipts',
    'stock': 'Stock',
    'stock_subtitle': 'Monitor current milk stock levels',
    'expenses': 'Expenses',
    'expenses_subtitle': 'Track operational expenses',
    'add_expense': 'Add Expense',
    'expense_description': 'Description',
    'expense_amount': 'Amount',
    'expense_category': 'Category',
    'expense_date': 'Date',
    'total_expenses': 'Total Expenses',
    'recent_expenses': 'Recent Expenses',
    'no_expenses_yet': 'No expenses yet',
    'spending_by_category': 'Spending by Category',
    'last_month': 'Last Month',
    'category_feed': 'Feed',
    'category_veterinary': 'Veterinary',
    'category_transport': 'Transport',
    'category_utilities': 'Utilities',
    'category_salaries': 'Salaries',
    'category_maintenance': 'Maintenance',
    'category_supplies': 'Supplies',
    'category_other': 'Other',
    'expense_created_successfully': 'Expense created successfully',
    'failed_to_create_expense': 'Failed to create expense',
    'failed_to_load_expenses': 'Failed to load expenses',
    'description_required': 'Description is required',
    'amount_required': 'Amount is required',
    'amount_must_be_positive': 'Amount must be greater than zero',
    'expenses_recorded': 'expenses recorded',
    'filter_by_date': 'Filter by Date',
    'start_date': 'Start Date',
    'end_date': 'End Date',
    'not_set': 'Not set',
    'clear': 'Clear',
    'apply': 'Apply',
    'custom': 'Custom',
    'dashboard': 'Dashboard',
    'today_collection': 'Today\'s Collection',
    'total_farmers': 'Total Farmers',
    'home': 'Home',
    'farmers': 'Farmers',
    'cattle': 'Cattle',
    'collection': 'Collection',
    'more': 'More',
    'analytics': 'Analytics',
    'analytics_report': 'Analytics & Report',
    'good_morning': 'Good morning',
    'good_afternoon': 'Good afternoon',
    'good_evening': 'Good evening',
    'total_liters': 'Total Liters',
    'payment': 'Payment',
    'recent_deliveries': 'Recent Deliveries',
    'view_all': 'View All',
    'no_deliveries_recorded': 'No deliveries recorded today',
    'error_loading_deliveries': 'Error loading deliveries',
    'unknown_farmer': 'Unknown Farmer',
    'min_ago': 'min ago',
    'syncing_data': 'Syncing data...',
    'all_data_synced': 'All data synced',
    'items_pending': 'items pending',
    'last_synced': 'Last synced',
    'tap_to_view_details': 'Tap to view details',
    'no_collection_data': 'No collection data available',
    'error_loading_summary': 'Error loading summary',
    'error_loading_trend': 'Error loading trend data',
    'week': 'Week',
    'month': 'Month',
    'year': 'Year',
    'settings': 'Settings',
    'language': 'Language',
    'profile': 'Profile',
    'notifications': 'Notifications',
    'notifications_subtitle': 'Manage notification preferences',
    'dark_theme': 'Dark Theme',
    'dark_theme_subtitle': 'Adjust app appearance',
    'privacy': 'Privacy',
    'privacy_subtitle': 'Control your privacy settings',
    'security': 'Security',
    'security_subtitle': 'Password and authentication',
    'help_support': 'Help & Support',
    'help_support_subtitle': 'Get help and contact us',
    'about': 'About',
    'about_subtitle': 'App version and information',
    'log_out': 'Log out',
    'delete_account': 'Delete Account',
    'general': 'GENERAL',
    'privacy_security': 'PRIVACY & SECURITY',
    'support': 'SUPPORT',
    'account': 'ACCOUNT',
    'select_language': 'Select Language',
    'financial_services': 'FINANCIAL SERVICES',
    'insurance': 'Insurance',
    'insurance_subtitle': 'Manage livestock insurance',
    'loans': 'Loans',
    'loans_subtitle': 'Access financial services',
    'records': 'RECORDS',
    'history': 'History',
    'history_subtitle': 'View delivery records',
    'profile_subtitle': 'Manage your account',
    'settings_subtitle': 'App preferences',
    'notification_settings_coming_soon': 'Notification settings coming soon',
    'privacy_settings_coming_soon': 'Privacy settings coming soon',
    'security_settings_coming_soon': 'Security settings coming soon',
    'dark_theme_enabled': 'Dark theme enabled',
    'dark_theme_disabled': 'Dark theme disabled',
    'need_help': 'Need help?',
    'support_email': 'Email: support@agripoa.com',
    'support_phone': 'Phone: +255 123 456 789',
    'support_hours': 'Hours: Mon-Fri, 8AM-5PM EAT',
    'close': 'Close',
    'version': 'Version',
    'build': 'Build',
    'app_description': 'AgriPOA - Livestock Management Platform',
    'copyright': '© 2024 AgriPOA. All rights reserved.',
    'log_out_confirm': 'Are you sure you want to log out?',
    'log_out_failed': 'Logout failed',
    'delete_account_confirm': 'Are you sure you want to delete your account? This action cannot be undone.',
    'delete_account_coming_soon': 'Account deletion coming soon',
    // Insurance - General
    'insurance_management': 'Insurance Management',
    'enroll_in_insurance': 'Enroll in Insurance',
    'view_policies': 'View Policies',
    'submit_claim': 'Submit Claim',
    'insurance_policy': 'Insurance Policy',
    'policies': 'Policies',
    'claims': 'Claims',
    'premium': 'Premium',
    'coverage': 'Coverage',
    // Insurance Enrollment
    'insurance_enrollment': 'Insurance Enrollment',
    'select_farmer': 'Select Farmer',
    'select_cattle': 'Select Cattle',
    'selected_cattle': 'Selected Cattle',
    'select_cattle_to_insure': 'Select cattle to insure',
    'no_cattle_available': 'No cattle available for insurance',
    'select_at_least_one_cattle': 'Please select at least one cattle',
    'productive_cattle': 'Productive Cattle',
    'calculating_premium': 'Calculating premium...',
    'premium_calculation': 'Premium Calculation',
    'premium_breakdown': 'Premium Breakdown',
    'total_annual_premium': 'Total Annual Premium',
    'payment_frequency': 'Payment Frequency',
    'monthly': 'Monthly',
    'quarterly': 'Quarterly',
    'monthly_installment': 'Monthly Installment',
    'quarterly_installment': 'Quarterly Installment',
    'policy_summary': 'Policy Summary',
    'policy_duration': 'Policy Duration',
    'months_12': '12 months',
    'enrolling': 'Enrolling...',
    'enrollment_success': 'Enrollment Successful',
    'enrollment_failed': 'Enrollment Failed',
    'policy_created': 'Policy created successfully',
    // Policy Management
    'policy_number': 'Policy Number',
    'policy_status': 'Policy Status',
    'policy_start_date': 'Start Date',
    'policy_end_date': 'End Date',
    'policy_details': 'Policy Details',
    'covered_cattle': 'Covered Cattle',
    'covered_cattle_count': 'Covered Cattle',
    'policy_active': 'Active',
    'policy_expired': 'Expired',
    'policy_suspended': 'Suspended',
    'policy_cancelled': 'Cancelled',
    'policy_all': 'All',
    'no_policies_found': 'No policies found',
    'search_policies': 'Search policies...',
    'filter_by_status': 'Filter by status',
    // Premium Information
    'premium_information': 'Premium Information',
    'total_premium': 'Total Premium',
    'installment_amount': 'Installment Amount',
    'total_paid': 'Total Paid',
    'outstanding_balance': 'Outstanding Balance',
    'next_payment_due': 'Next Payment Due',
    'payment_history': 'Payment History',
    'payment_date': 'Payment Date',
    'payment_method': 'Payment Method',
    'milk_deduction': 'Milk Deduction',
    'cash': 'Cash',
    'mobile_money': 'Mobile Money',
    'no_payments_recorded': 'No payments recorded',
    'overdue_premium': 'Overdue Premium',
    'days_until_expiry': 'Days Until Expiry',
    'renew_policy': 'Renew Policy',
    // Claims
    'claim_submission': 'Claim Submission',
    'claim_history': 'Claim History',
    'claim_details': 'Claim Details',
    'claim_number': 'Claim Number',
    'claim_status': 'Claim Status',
    'claim_amount': 'Claim Amount',
    'settlement_amount': 'Settlement Amount',
    'select_policy': 'Select Policy',
    'select_cattle_for_claim': 'Select cattle for claim',
    'loss_type': 'Loss Type',
    'death': 'Death',
    'theft': 'Theft',
    'disease': 'Disease',
    'loss_date': 'Loss Date',
    'description': 'Description',
    'describe_circumstances': 'Describe the circumstances',
    'supporting_documents': 'Supporting Documents',
    'upload_document': 'Upload Document',
    'upload_photo': 'Upload Photo',
    'take_photo': 'Take Photo',
    'choose_from_gallery': 'Choose from Gallery',
    'uploading': 'Uploading...',
    'document_uploaded': 'Document uploaded',
    'submitting': 'Submitting...',
    'claim_submitted': 'Claim submitted successfully',
    'claim_submission_failed': 'Claim submission failed',
    'submitted': 'Submitted',
    'under_review': 'Under Review',
    'approved': 'Approved',
    'rejected': 'Rejected',
    'settled': 'Settled',
    'no_claims_found': 'No claims found',
    'submission_date': 'Submission Date',
    'settlement_date': 'Settlement Date',
    'review_comments': 'Review Comments',
    'claim_timeline': 'Claim Timeline',
    // Insurance Eligibility
    'insurance_eligibility': 'Insurance Eligibility',
    'not_eligible_for_loan': 'Not Eligible for Loan',
    'insurance_required': 'Insurance Required',
    'all_productive_cattle_must_be_insured': 'All productive cattle must be insured to access loans',
    'uncovered_cattle': 'Uncovered Cattle',
    'get_insurance_now': 'Get Insurance Now',
    // Loans
    'apply_for_loan': 'Apply for Loan',
    'loan_details': 'Loan Details',
    'loan_amount': 'Loan Amount',
    'loan_term': 'Loan Term',
    'interest_rate': 'Interest Rate',
    'per_month': 'per month',
    'annually': 'annually',
    'repayment_schedule': 'Repayment Schedule',
    'principal': 'Principal',
    'total_interest': 'Total Interest',
    'total_repayment': 'Total Repayment',
    'monthly_payment': 'Monthly Payment',
    'repayment_deducted_from_milk_payments': 'Repayments will be automatically deducted from your milk payments',
    'eligibility_status': 'Eligibility Status',
    'insurance_verified': 'Insurance Verified',
    'loan_eligible': 'Eligible for Loan',
    'submit_application': 'Submit Application',
    'application_submitted': 'Application submitted successfully',
    'months': 'months',
    'outstanding': 'Outstanding',
    'completed': 'Completed',
    'pending': 'Pending',
    // Error Messages
    'policy_not_active': 'Policy is not active',
    'cattle_not_covered': 'Cattle is not covered by this policy',
    'duplicate_claim': 'A claim already exists for this cattle',
    'invalid_premium_amount': 'Invalid premium amount',
    'no_active_policies': 'No active policies found',
    'error_loading_policies': 'Error loading policies',
    'error_loading_claims': 'Error loading claims',
    'error_calculating_premium': 'Error calculating premium',
    // SMS Notification Templates
    'sms_enrollment_confirmation': 'Insurance policy {policyNumber} created. Premium: {premium}. Payment: {frequency}',
    'sms_premium_deducted': 'Premium payment of {amount} deducted. Next due: {nextDue}',
    'sms_premium_reminder': 'Premium payment of {amount} due on {dueDate}',
    'sms_policy_expiring': 'Your insurance policy expires in {days} days. Please renew.',
    'sms_claim_submitted': 'Claim {claimNumber} submitted for cattle {cattleId}. We will notify you of updates.',
    'sms_claim_approved': 'Claim {claimNumber} approved. Settlement amount: {amount}',
    'sms_claim_rejected': 'Claim {claimNumber} rejected. Reason: {reason}',
    'sms_claim_settled': 'Claim {claimNumber} settled. Amount: {amount} paid.',
    // Sync
    'sync_status': 'Sync Status',
    'sync_now': 'Sync Now',
    'sync_completed': 'Sync completed successfully',
    'all_synced_subtitle': 'All your data is up to date',
    'offline_subtitle': '{count} items waiting to sync',
    'pending_sync_subtitle': '{count} items pending sync',
    'sync_error_subtitle': 'Failed to sync data',
    'connection_status': 'Connection Status',
    'online': 'Online',
    'offline': 'Offline',
    'pending_items': 'Pending Items',
    'last_sync': 'Last Sync',
    'never': 'Never',
    'minutes_ago': '{minutes} minutes ago',
    'hours_ago': '{hours} hours ago',
    'days_ago': '{days} days ago',
    'offline_message': 'You are offline. Data will sync automatically when connection is restored.',
    'about_sync': 'About Sync',
    'sync_description': 'The app automatically syncs your data when you have an internet connection. You can work offline and all changes will be saved and synced later.',
    // Farmer Self-Service (additional keys)
    'quick_links': 'Quick Links',
    'milk_history': 'Milk History',
    'my_cattle': 'My Cattle',
    'deliveries': 'Deliveries',
    'earnings': 'Earnings',
    'pending_payment': 'Pending Payment',
    'loan_balance': 'Loan Balance',
    'insurance_status': 'Insurance Status',
    'cattle_covered': 'cattle covered',
    'all_time': 'All Time',
    'last_week': 'Last Week',
    'no_deliveries_found': 'No deliveries found',
    'total_cattle': 'Total Cattle',
    'avg_production': 'Avg Production',
    'no_cattle_registered': 'No cattle registered',
    'error_loading_cattle': 'Error loading cattle',
    'avg_daily': 'Avg Daily',
    'last_delivery': 'Last Delivery',
    'no_active_loans': 'No active loans',
    'apply_for_loan_to_get_started': 'Apply for a loan to get started',
    'active_loans': 'Active Loans',
    'completed_loans': 'Completed Loans',
    'error_loading_loans': 'Error loading loans',
    'input_loan': 'Input Loan',
    'repayment_progress': 'Repayment Progress',
    'disbursed': 'Disbursed',
    'defaulted': 'Defaulted',
    'loan_summary': 'Loan Summary',
    'disbursement_date': 'Disbursement Date',
    'no_payments_yet': 'No payments yet',
    'error_loading_payments': 'Error loading payments',
    'flat': 'Flat',
    'reducing_balance': 'Reducing Balance',
    'active_policy': 'Active Policy',
    'valid_until': 'Valid Until',
    'no_covered_cattle': 'No covered cattle',
    'no_claims_submitted': 'No claims submitted',
    'profile_settings': 'Profile & Settings',
    'contact_information': 'Contact Information',
    'app_settings': 'App Settings',
    'manage_notification_settings': 'Manage notification settings',
    'pricing_information': 'Pricing Information',
    'current_milk_price': 'Current Milk Price',
    'liter': 'liter',
    'price_varies_by_quality': 'Price varies by quality grade',
    'confirm_logout': 'Are you sure you want to logout?',
    
    // Analytics & Reporting
    'analytics_dashboard': 'Analytics Dashboard',
    'milk_production': 'Milk Production',
    'farmer_demographics': 'Farmer Demographics',
    'livestock': 'Livestock',
    'financial': 'Financial',
    'overview': 'Overview',
    'filter': 'Filter',
    'export': 'Export',
    'refresh': 'Refresh',
    
    // KPIs and Metrics
    'total_milk_collected': 'Total Milk Collected',
    'average_per_day': 'Average Per Day',
    'average_per_farmer': 'Average Per Farmer',
    'quality_distribution': 'Quality Distribution',
    'premium_quality': 'Premium',
    'standard': 'Standard',
    'substandard': 'Substandard',
    'production_trend': 'Production Trend',
    'collection_centers': 'Collection Centers',
    'peak_hours': 'Peak Hours',
    'vs_last_period': 'vs Last Period',
    
    // Farmer Analytics
    'new_farmers': 'New Farmers',
    'gender_distribution': 'Gender Distribution',
    'male': 'Male',
    'female': 'Female',
    'age_distribution': 'Age Distribution',
    'geographic_distribution': 'Geographic Distribution',
    'app_adoption': 'App Adoption',
    'credit_score_distribution': 'Credit Score Distribution',
    'registration_trend': 'Registration Trend',
    
    // Livestock Analytics
    'total_cattle_count': 'Total Cattle',
    'lactation_rate': 'Lactation Rate',
    'breed_distribution': 'Breed Distribution',
    'health_status': 'Health Status',
    'healthy': 'Healthy',
    'sick': 'Sick',
    'under_treatment': 'Under Treatment',
    'farm_assets': 'Farm Assets',
    'avocado_trees': 'Avocado Trees',
    'chickens': 'Chickens',
    'beehives': 'Beehives',
    
    // Financial Analytics
    'total_payments': 'Total Payments',
    'average_price_per_liter': 'Average Price Per Liter',
    'payment_trend': 'Payment Trend',
    'loan_metrics': 'Loan Metrics',
    'total_disbursed': 'Total Disbursed',
    'total_outstanding': 'Total Outstanding',
    'repayment_rate': 'Repayment Rate',
    'default_rate': 'Default Rate',
    'insurance_metrics': 'Insurance Metrics',
    'active_policies': 'Active Policies',
    'premium_collected': 'Premium Collected',
    'coverage_percentage': 'Coverage Percentage',
    'revenue_breakdown': 'Revenue Breakdown',
    
    // Inventory Analytics
    'total_inventory_value': 'Total Inventory Value',
    'low_stock_products': 'Low Stock Products',
    'out_of_stock_products': 'Out of Stock Products',
    'sales_revenue': 'Sales Revenue',
    'top_selling_products': 'Top Selling Products',
    'category_breakdown': 'Category Breakdown',
    'stock_turnover_rate': 'Stock Turnover Rate',
    
    // Comparative Analytics
    'comparative_analytics': 'Comparative Analytics',
    'current_period': 'Current Period',
    'comparison_period': 'Comparison Period',
    'percentage_change': 'Percentage Change',
    'improving': 'Improving',
    'declining': 'Declining',
    'stable': 'Stable',
    'benchmarking': 'Benchmarking',
    'top_performers': 'Top Performers',
    'bottom_performers': 'Bottom Performers',
    
    // Predictive Analytics
    'predictive_analytics': 'Predictive Analytics',
    'forecast': 'Forecast',
    'trend_line': 'Trend Line',
    'confidence_interval': 'Confidence Interval',
    'seasonal_patterns': 'Seasonal Patterns',
    'projected_growth': 'Projected Growth',
    'forecast_days': 'Forecast Days',
    'days_30': '30 Days',
    'days_60': '60 Days',
    'days_90': '90 Days',
    
    // Alerts
    'alerts': 'Alerts',
    'critical': 'Critical',
    'warning': 'Warning',
    'informational': 'Informational',
    'production_drop': 'Production Drop',
    'loan_default_alert': 'Loan Default Alert',
    'insurance_lapse_alert': 'Insurance Lapse Alert',
    'farmer_engagement_alert': 'Farmer Engagement Alert',
    'quality_concern_alert': 'Quality Concern Alert',
    'mark_as_read': 'Mark as Read',
    'dismiss': 'Dismiss',
    'no_alerts_found': 'No alerts found',
    
    // Reports
    'reports': 'Reports',
    'generate_report': 'Generate Report',
    'report_templates': 'Report Templates',
    'monthly_summary': 'Monthly Summary',
    'quarterly_review': 'Quarterly Review',
    'annual_report': 'Annual Report',
    'government_submission': 'Government Submission',
    'custom_report': 'Custom Report',
    'export_format': 'Export Format',
    'pdf': 'PDF',
    'excel': 'Excel',
    'csv': 'CSV',
    'preview': 'Preview',
    'download': 'Download',
    'share': 'Share',
    'scheduled_reports': 'Scheduled Reports',
    'schedule_report': 'Schedule Report',
    'frequency': 'Frequency',
    'daily': 'Daily',
    'weekly': 'Weekly',
    'on_demand': 'On Demand',
    'recipients': 'Recipients',
    'report_generated': 'Report generated successfully',
    'report_generation_failed': 'Report generation failed',
    
    // Filters
    'date_range': 'Date Range',
    'this_quarter': 'This Quarter',
    'this_year': 'This Year',
    'custom_range': 'Custom Range',
    'cooperative': 'Cooperative',
    'collection_center': 'Collection Center',
    'location': 'Location',
    'region': 'Region',
    'district': 'District',
    'ward': 'Ward',
    'village': 'Village',
    'farmer_filters': 'Farmer Filters',
    'gender': 'Gender',
    'age_range': 'Age Range',
    'credit_score_range': 'Credit Score Range',
    'app_access_status': 'App Access Status',
    'cattle_filters': 'Cattle Filters',
    'breed': 'Breed',
    'lactation_status': 'Lactation Status',
    'health_status_filter': 'Health Status',
    'apply_filters': 'Apply Filters',
    'reset_filters': 'Reset Filters',
    'save_filter': 'Save Filter',
    'saved_filters': 'Saved Filters',
    'filter_name': 'Filter Name',
    
    // Chart Labels
    'days_7': '7 Days',
    'days_30_chart': '30 Days',
    'days_90_chart': '90 Days',
    'months_12_chart': '12 Months',
    'liters': 'Liters',
    'count': 'Count',
    'percentage': 'Percentage',
    'amount': 'Amount',
    'date': 'Date',
    'value': 'Value',
    
    // Error Messages
    'error_loading_analytics': 'Error loading analytics',
    'insufficient_data': 'Insufficient data',
    'invalid_filter': 'Invalid filter',
    'no_data_available': 'No data available',
    'error_generating_report': 'Error generating report',
    
    // Loading States
    'loading_analytics': 'Loading analytics...',
    'calculating_metrics': 'Calculating metrics...',
    'generating_report': 'Generating report...',
    'exporting_data': 'Exporting data...',
  },
  'sw': {
    'app_name': 'Agripoa',
    'ok': 'Sawa',
    'cancel': 'Ghairi',
    'save': 'Hifadhi',
    'delete': 'Futa',
    'edit': 'Hariri',
    'search': 'Tafuta',
    'loading': 'Inapakia...',
    'error': 'Kosa',
    'success': 'Mafanikio',
    'retry': 'Jaribu Tena',
    'login': 'Ingia',
    'logout': 'Toka',
    'email': 'Barua Pepe',
    'password': 'Nywila',
    'phone_number': 'Nambari ya Simu',
    'app_subtitle': 'Jukwaa la Ufugaji wa Maziwa wa Kidijitali',
    'forgot_password': 'Umesahau Nywila?',
    'login_with_email': 'Ingia kwa Barua Pepe',
    'login_with_phone': 'Ingia kwa Nambari ya Simu',
    'reset_password': 'Weka Upya Nywila',
    'reset_password_title': 'Weka Upya Nywila Yako',
    'reset_password_instructions': 'Ingiza barua pepe au nambari yako ya simu na tutakutumia maagizo ya kuweka upya nywila yako',
    'send_reset_link': 'Tuma Kiungo cha Kuweka Upya',
    'send_reset_code': 'Tuma Msimbo wa Kuweka Upya',
    'reset_email_sent': 'Barua pepe ya kuweka upya nywila imetumwa! Angalia sanduku lako la barua kwa maagizo.',
    'reset_sms_sent': 'Msimbo wa kuweka upya nywila umetumwa! Angalia ujumbe wako kwa maagizo.',
    'reset_email_error': 'Imeshindwa kutuma barua pepe ya kuweka upya. Tafadhali angalia anwani ya barua pepe na jaribu tena.',
    'reset_sms_error': 'Imeshindwa kutuma msimbo wa kuweka upya. Tafadhali angalia nambari ya simu na jaribu tena.',
    'back_to_login': 'Rudi kwa Kuingia',
    'enter_email_or_phone': 'Ingiza barua pepe au nambari yako ya simu',
    'reset_method': 'Njia ya Kuweka Upya',
    'use_email': 'Tumia Barua Pepe',
    'use_phone': 'Tumia Nambari ya Simu',
    'register_farmer': 'Sajili Mkulima',
    'farmer_name': 'Jina la Mkulima',
    'farmer_list': 'Orodha ya Wakulima',
    'record_milk': 'Rekodi Maziwa',
    'milk_quantity': 'Kiasi cha Maziwa',
    'quality_grade': 'Kiwango cha Ubora',
    'payment_amount': 'Kiasi cha Malipo',
    'milk_collection': 'Ukusanyaji wa Maziwa',
    'record_collection': 'Rekodi Ukusanyaji',
    'please_log_in': 'Tafadhali ingia',
    'view_all_history': 'Angalia Historia Yote',
    'view_all_history_coming_soon': 'Historia yote inakuja hivi karibuni',
    'recent_collections': 'Ukusanyaji wa Hivi Karibuni',
    'today': 'Leo',
    'no_collections_today': 'Hakuna ukusanyaji ulioandikwa leo',
    'delivery_history': 'Historia ya Utoaji',
    'collection_date': 'Tarehe ya Ukusanyaji',
    'collection_time': 'Wakati wa Ukusanyaji',
    'morning': 'Asubuhi',
    'evening': 'Jioni',
    'select_date': 'Chagua Tarehe',
    'register_cattle': 'Sajili Ng\'ombe',
    'cattle_list': 'Orodha ya Ng\'ombe',
    'cattle_tracking': 'Ufuatiliaji wa Ng\'ombe',
    'view_all_cattle': 'Angalia Ng\'ombe Wote',
    'cattle_list_coming_soon': 'Orodha ya ng\'ombe inakuja hivi karibuni',
    'cattle_registration_coming_soon': 'Usajili wa ng\'ombe unakuja hivi karibuni',
    'search_cattle_hint': 'Tafuta ng\'ombe kwa lebo, aina, au mkulima...',
    'view_manage_cattle': 'Angalia na simamia ng\'ombe wote katika ushirika wako',
    'lactating': 'Wanaonyesha',
    'dry': 'Kavu',
    'pregnant': 'Wajawazito',
    'calves': 'Ndama',
    'calf': 'Ndama',
    'yesterday': 'Jana',
    'inventory': 'Hesabu',
    'sales': 'Mauzo',
    'off_takers': 'Wanunuzi',
    'inventory_subtitle': 'Simamia hesabu ya bidhaa na hisa',
    'sales_subtitle': 'Fuatilia mauzo na mapato',
    'off_takers_subtitle': 'Simamia wanunuzi na wasambazaji',
    
    // Off-Takers Management (MVP)
    'create_off_taker': 'Unda Mnunuzi',
    'business_name': 'Jina la Biashara',
    'contact_person': 'Mtu wa Kuwasiliana',
    'off_taker_category': 'Aina',
    'select_off_taker': 'Chagua Mnunuzi (Si Lazima)',
    
    // Inventory Management
    'add_product': 'Ongeza Bidhaa',
    'edit_product': 'Hariri Bidhaa',
    'product_name': 'Jina la Bidhaa',
    'sku': 'SKU',
    'category': 'Aina',
    'unit_of_measure': 'Kipimo',
    'unit_price': 'Bei ya Kipimo',
    'reorder_point': 'Kiwango cha Kuagiza',
    'current_stock': 'Hisa ya Sasa',
    'initial_stock': 'Hisa ya Awali',
    'low_stock_alert': 'Tahadhari ya Hisa Chache',
    'products_need_restocking': 'bidhaa zinahitaji kuongezwa',
    'product_needs_restocking': 'bidhaa inahitaji kuongezwa',
    'no_products_registered': 'Hakuna bidhaa zilizosajiliwa bado',
    'add_your_first_product': 'Ongeza bidhaa yako ya kwanza kuanza',
    'product_added_successfully': 'Bidhaa imeongezwa kwa mafanikio',
    'product_updated_successfully': 'Bidhaa imesasishwa kwa mafanikio',
    'product_details': 'Maelezo ya Bidhaa',
    'stock_summary': 'Muhtasari wa Hisa',
    'in_stock': 'Ipo Hisani',
    'low_stock': 'Hisa Chache',
    'out_of_stock': 'Hisa Imeisha',
    'add_stock': 'Ongeza Hisa',
    'adjust_stock': 'Rekebisha Hisa',
    'stock_added_successfully': 'Hisa imeongezwa kwa mafanikio',
    'quantity_to_add': 'Kiasi cha Kuongeza',
    'new_stock_level': 'Kiwango Kipya cha Hisa',
    'reason_notes': 'Sababu/Maelezo',
    'transaction_history': 'Historia ya Miamala',
    'recent_activity': 'Shughuli za Hivi Karibuni',
    'stock_addition': 'Kuongeza Hisa',
    'stock_adjustment': 'Marekebisho ya Hisa',
    'sale': 'Mauzo',
    'additions': 'Nyongeza',
    'adjustments': 'Marekebisho',
    'all': 'Zote',
    'pricing': 'Bei',
    'inventory_value': 'Thamani ya Hisa',
    'active': 'Inatumika',
    'inactive': 'Haitumiki',
    'active_status': 'Hali ya Matumizi',
    'product_is_active': 'Bidhaa inatumika na inapatikana',
    'product_is_inactive': 'Bidhaa haitumiki',
    
    // Product Categories
    'animal_feed': 'Chakula cha Wanyama',
    'veterinary_supplies': 'Vifaa vya Mifugo',
    'farm_equipment': 'Vifaa vya Kilimo',
    'seeds': 'Mbegu',
    'fertilizers': 'Mbolea',
    'other': 'Nyingine',
    
    // Sales Management
    'record_sale': 'Rekodi Mauzo',
    'sale_recorded_successfully': 'Mauzo yamerekodi kwa mafanikio',
    'recent_sales': 'Mauzo ya Hivi Karibuni',
    'no_sales_recorded': 'Hakuna mauzo yaliyorekodiwa bado',
    'record_your_first_sale': 'Rekodi mauzo yako ya kwanza kuanza',
    'select_product': 'Chagua Bidhaa',
    'quantity': 'Kiasi',
    'customer_name': 'Jina la Mteja',
    'notes': 'Maelezo',
    'total_amount': 'Jumla',
    'sale_details': 'Maelezo ya Mauzo',
    'today_sales': 'Leo',
    'this_week': 'Wiki Hii',
    'this_month': 'Mwezi Huu',
    'sales_count': 'mauzo',
    'insufficient_stock': 'Hisa haitoshi',
    'only_available': 'Ipo {count} tu',
    
    // Error Messages
    'product_name_required': 'Jina la bidhaa linahitajika',
    'sku_required': 'SKU inahitajika',
    'unit_price_required': 'Bei ya kipimo inahitajika',
    'quantity_required': 'Kiasi kinahitajika',
    'quantity_must_be_positive': 'Kiasi lazima kiwe namba chanya',
    'price_must_be_positive': 'Bei lazima iwe namba chanya',
    'product_not_found': 'Bidhaa haijapatikana',
    'error_loading_products': 'Kosa la kupakia bidhaa',
    'error_loading_sales': 'Kosa la kupakia mauzo',
    'sku_already_exists': 'SKU tayari ipo',
    'network_error': 'Kosa la mtandao. Mabadiliko yatasawazishwa mtandao unapopatikana',
    'offline_mode': 'Hali ya Nje ya Mtandao',
    'syncing': 'Inasawazisha...',
    'all_synced': 'Yote imesawazishwa',
    'pending_sync': 'Inasubiri kusawazishwa',
    'business': 'BIASHARA',
    'entrance': 'Kuingia',
    'entrance_subtitle': 'Rekodi maziwa yanayoingia na risiti',
    'stock': 'Hisa',
    'stock_subtitle': 'Fuatilia kiwango cha hisa ya maziwa',
    'expenses': 'Gharama',
    'expenses_subtitle': 'Fuatilia gharama za uendeshaji',
    'add_expense': 'Ongeza Gharama',
    'expense_description': 'Maelezo',
    'expense_amount': 'Kiasi',
    'expense_category': 'Aina',
    'expense_date': 'Tarehe',
    'total_expenses': 'Jumla ya Gharama',
    'recent_expenses': 'Gharama za Hivi Karibuni',
    'no_expenses_yet': 'Hakuna gharama bado',
    'spending_by_category': 'Matumizi kwa Aina',
    'last_month': 'Mwezi Uliopita',
    'category_feed': 'Chakula',
    'category_veterinary': 'Matibabu ya Wanyama',
    'category_transport': 'Usafiri',
    'category_utilities': 'Huduma',
    'category_salaries': 'Mishahara',
    'category_maintenance': 'Matengenezo',
    'category_supplies': 'Vifaa',
    'category_other': 'Nyingine',
    'expense_created_successfully': 'Gharama imeongezwa kwa mafanikio',
    'failed_to_create_expense': 'Imeshindwa kuongeza gharama',
    'failed_to_load_expenses': 'Imeshindwa kupakia gharama',
    'description_required': 'Maelezo yanahitajika',
    'amount_required': 'Kiasi kinahitajika',
    'amount_must_be_positive': 'Kiasi lazima kiwe zaidi ya sifuri',
    'expenses_recorded': 'gharama zilizoandikwa',
    'filter_by_date': 'Chuja kwa Tarehe',
    'start_date': 'Tarehe ya Kuanza',
    'end_date': 'Tarehe ya Mwisho',
    'not_set': 'Haijawekwa',
    'clear': 'Futa',
    'apply': 'Tekeleza',
    'custom': 'Maalum',
    'dashboard': 'Dashibodi',
    'today_collection': 'Ukusanyaji wa Leo',
    'total_farmers': 'Jumla ya Wakulima',
    'home': 'Nyumbani',
    'farmers': 'Wakulima',
    'cattle': 'Ng\'ombe',
    'collection': 'Ukusanyaji',
    'more': 'Zaidi',
    'analytics': 'Takwimu',
    'analytics_report': 'Takwimu na Ripoti',
    'good_morning': 'Habari ya asubuhi',
    'good_afternoon': 'Habari ya mchana',
    'good_evening': 'Habari ya jioni',
    'total_liters': 'Jumla ya Lita',
    'payment': 'Malipo',
    'recent_deliveries': 'Utoaji wa Hivi Karibuni',
    'view_all': 'Angalia Zote',
    'no_deliveries_recorded': 'Hakuna utoaji ulioandikwa leo',
    'error_loading_deliveries': 'Kosa la kupakia utoaji',
    'unknown_farmer': 'Mkulima Asiyejulikana',
    'min_ago': 'dakika zilizopita',
    'syncing_data': 'Inasawazisha data...',
    'all_data_synced': 'Data yote imesawazishwa',
    'items_pending': 'vitu vinasubiri',
    'last_synced': 'Usawazishaji wa mwisho',
    'tap_to_view_details': 'Gusa kuona maelezo',
    'no_collection_data': 'Hakuna data ya ukusanyaji',
    'error_loading_summary': 'Kosa la kupakia muhtasari',
    'error_loading_trend': 'Kosa la kupakia data ya mwenendo',
    'week': 'Wiki',
    'month': 'Mwezi',
    'year': 'Mwaka',
    'settings': 'Mipangilio',
    'language': 'Lugha',
    'profile': 'Wasifu',
    'notifications': 'Arifa',
    'notifications_subtitle': 'Dhibiti mapendeleo ya arifa',
    'dark_theme': 'Mandhari ya Giza',
    'dark_theme_subtitle': 'Rekebisha muonekano wa programu',
    'privacy': 'Faragha',
    'privacy_subtitle': 'Dhibiti mipangilio ya faragha',
    'security': 'Usalama',
    'security_subtitle': 'Nywila na uthibitishaji',
    'help_support': 'Msaada na Usaidizi',
    'help_support_subtitle': 'Pata msaada na wasiliana nasi',
    'about': 'Kuhusu',
    'about_subtitle': 'Toleo la programu na maelezo',
    'log_out': 'Toka',
    'delete_account': 'Futa Akaunti',
    'general': 'JUMLA',
    'privacy_security': 'FARAGHA NA USALAMA',
    'support': 'MSAADA',
    'account': 'AKAUNTI',
    'select_language': 'Chagua Lugha',
    'financial_services': 'HUDUMA ZA KIFEDHA',
    'insurance': 'Bima',
    'insurance_subtitle': 'Simamia bima ya mifugo',
    'loans': 'Mikopo',
    'loans_subtitle': 'Pata huduma za kifedha',
    'records': 'KUMBUKUMBU',
    'history': 'Historia',
    'history_subtitle': 'Angalia kumbukumbu za utoaji',
    'profile_subtitle': 'Simamia akaunti yako',
    'settings_subtitle': 'Mapendeleo ya programu',
    'notification_settings_coming_soon': 'Mipangilio ya arifa inakuja hivi karibuni',
    'privacy_settings_coming_soon': 'Mipangilio ya faragha inakuja hivi karibuni',
    'security_settings_coming_soon': 'Mipangilio ya usalama inakuja hivi karibuni',
    'dark_theme_enabled': 'Mandhari ya giza imewashwa',
    'dark_theme_disabled': 'Mandhari ya giza imezimwa',
    'need_help': 'Unahitaji msaada?',
    'support_email': 'Barua pepe: support@agripoa.com',
    'support_phone': 'Simu: +255 123 456 789',
    'support_hours': 'Masaa: Jumatatu-Ijumaa, 8AM-5PM EAT',
    'close': 'Funga',
    'version': 'Toleo',
    'build': 'Ujenzi',
    'app_description': 'AgriPOA - Jukwaa la Usimamizi wa Mifugo',
    'copyright': '© 2024 AgriPOA. Haki zote zimehifadhiwa.',
    'log_out_confirm': 'Una uhakika unataka kutoka?',
    'log_out_failed': 'Kutoka kumeshindwa',
    'delete_account_confirm': 'Una uhakika unataka kufuta akaunti yako? Hatua hii haiwezi kutenduliwa.',
    'delete_account_coming_soon': 'Ufutaji wa akaunti unakuja hivi karibuni',
    // Insurance - General
    'insurance_management': 'Usimamizi wa Bima',
    'enroll_in_insurance': 'Jiandikishe kwa Bima',
    'view_policies': 'Angalia Sera',
    'submit_claim': 'Wasilisha Madai',
    'insurance_policy': 'Sera ya Bima',
    'policies': 'Sera',
    'claims': 'Madai',
    'premium': 'Malipo ya Bima',
    'coverage': 'Ulinzi',
    // Insurance Enrollment
    'insurance_enrollment': 'Usajili wa Bima',
    'select_farmer': 'Chagua Mkulima',
    'select_cattle': 'Chagua Ng\'ombe',
    'selected_cattle': 'Ng\'ombe Waliochaguliwa',
    'select_cattle_to_insure': 'Chagua ng\'ombe wa kubima',
    'no_cattle_available': 'Hakuna ng\'ombe wanaopatikana kwa bima',
    'select_at_least_one_cattle': 'Tafadhali chagua angalau ng\'ombe mmoja',
    'productive_cattle': 'Ng\'ombe Wazalishaji',
    'calculating_premium': 'Inahesabu malipo ya bima...',
    'premium_calculation': 'Hesabu ya Malipo ya Bima',
    'premium_breakdown': 'Maelezo ya Malipo ya Bima',
    'total_annual_premium': 'Jumla ya Malipo ya Mwaka',
    'payment_frequency': 'Mzunguko wa Malipo',
    'monthly': 'Kila Mwezi',
    'quarterly': 'Kila Robo Mwaka',
    'monthly_installment': 'Awamu ya Kila Mwezi',
    'quarterly_installment': 'Awamu ya Kila Robo',
    'policy_summary': 'Muhtasari wa Sera',
    'policy_duration': 'Muda wa Sera',
    'months_12': 'Miezi 12',
    'enrolling': 'Inaandikisha...',
    'enrollment_success': 'Usajili Umefanikiwa',
    'enrollment_failed': 'Usajili Umeshindwa',
    'policy_created': 'Sera imeundwa kwa mafanikio',
    // Policy Management
    'policy_number': 'Nambari ya Sera',
    'policy_status': 'Hali ya Sera',
    'policy_start_date': 'Tarehe ya Kuanza',
    'policy_end_date': 'Tarehe ya Mwisho',
    'policy_details': 'Maelezo ya Sera',
    'covered_cattle': 'Ng\'ombe Waliolindwa',
    'covered_cattle_count': 'Ng\'ombe Waliolindwa',
    'policy_active': 'Hai',
    'policy_expired': 'Imeisha',
    'policy_suspended': 'Imesimamishwa',
    'policy_cancelled': 'Imefutwa',
    'policy_all': 'Zote',
    'no_policies_found': 'Hakuna sera zilizopatikana',
    'search_policies': 'Tafuta sera...',
    'filter_by_status': 'Chuja kwa hali',
    // Premium Information
    'premium_information': 'Maelezo ya Malipo ya Bima',
    'total_premium': 'Jumla ya Malipo',
    'installment_amount': 'Kiasi cha Awamu',
    'total_paid': 'Jumla Iliyolipwa',
    'outstanding_balance': 'Salio Linalobaki',
    'next_payment_due': 'Malipo Yanayofuata',
    'payment_history': 'Historia ya Malipo',
    'payment_date': 'Tarehe ya Malipo',
    'payment_method': 'Njia ya Malipo',
    'milk_deduction': 'Ukataji wa Maziwa',
    'cash': 'Taslimu',
    'mobile_money': 'Pesa ya Simu',
    'no_payments_recorded': 'Hakuna malipo yaliyoandikwa',
    'overdue_premium': 'Malipo Yaliyochelewa',
    'days_until_expiry': 'Siku Hadi Kuisha',
    'renew_policy': 'Fanya Upya Sera',
    // Claims
    'claim_submission': 'Uwasilishaji wa Madai',
    'claim_history': 'Historia ya Madai',
    'claim_details': 'Maelezo ya Madai',
    'claim_number': 'Nambari ya Madai',
    'claim_status': 'Hali ya Madai',
    'claim_amount': 'Kiasi cha Madai',
    'settlement_amount': 'Kiasi cha Malipo',
    'select_policy': 'Chagua Sera',
    'select_cattle_for_claim': 'Chagua ng\'ombe kwa madai',
    'loss_type': 'Aina ya Hasara',
    'death': 'Kifo',
    'theft': 'Wizi',
    'disease': 'Ugonjwa',
    'loss_date': 'Tarehe ya Hasara',
    'description': 'Maelezo',
    'describe_circumstances': 'Eleza hali',
    'supporting_documents': 'Nyaraka za Ushahidi',
    'upload_document': 'Pakia Nyaraka',
    'upload_photo': 'Pakia Picha',
    'take_photo': 'Piga Picha',
    'choose_from_gallery': 'Chagua kutoka Mkusanyiko',
    'uploading': 'Inapakia...',
    'document_uploaded': 'Nyaraka imepakiwa',
    'submitting': 'Inawasilisha...',
    'claim_submitted': 'Madai yamewasilishwa kwa mafanikio',
    'claim_submission_failed': 'Uwasilishaji wa madai umeshindwa',
    'submitted': 'Imewasilishwa',
    'under_review': 'Inakaguliwa',
    'approved': 'Imeidhinishwa',
    'rejected': 'Imekataliwa',
    'settled': 'Imelipwa',
    'no_claims_found': 'Hakuna madai yaliyopatikana',
    'submission_date': 'Tarehe ya Kuwasilisha',
    'settlement_date': 'Tarehe ya Malipo',
    'review_comments': 'Maoni ya Ukaguzi',
    'claim_timeline': 'Ratiba ya Madai',
    // Insurance Eligibility
    'insurance_eligibility': 'Ustahiki wa Bima',
    'not_eligible_for_loan': 'Haustahili Mkopo',
    'insurance_required': 'Bima Inahitajika',
    'all_productive_cattle_must_be_insured': 'Ng\'ombe wote wazalishaji lazima wabimwe ili kupata mikopo',
    'uncovered_cattle': 'Ng\'ombe Wasiolindwa',
    'get_insurance_now': 'Pata Bima Sasa',
    // Loans
    'apply_for_loan': 'Omba Mkopo',
    'loan_details': 'Maelezo ya Mkopo',
    'loan_amount': 'Kiasi cha Mkopo',
    'loan_term': 'Muda wa Mkopo',
    'interest_rate': 'Kiwango cha Riba',
    'per_month': 'kwa mwezi',
    'annually': 'kwa mwaka',
    'repayment_schedule': 'Ratiba ya Malipo',
    'principal': 'Mkopo Mkuu',
    'total_interest': 'Jumla ya Riba',
    'total_repayment': 'Jumla ya Malipo',
    'monthly_payment': 'Malipo ya Kila Mwezi',
    'repayment_deducted_from_milk_payments': 'Malipo yatakatwa moja kwa moja kutoka malipo ya maziwa yako',
    'eligibility_status': 'Hali ya Ustahiki',
    'insurance_verified': 'Bima Imethibitishwa',
    'loan_eligible': 'Unastahili Mkopo',
    'submit_application': 'Wasilisha Ombi',
    'application_submitted': 'Ombi limewasilishwa kwa mafanikio',
    'months': 'miezi',
    'outstanding': 'Inayobaki',
    'completed': 'Imekamilika',
    'pending': 'Inasubiri',
    // Error Messages
    'policy_not_active': 'Sera haiko hai',
    'cattle_not_covered': 'Ng\'ombe hajalindwa na sera hii',
    'duplicate_claim': 'Madai tayari yanapatikana kwa ng\'ombe huyu',
    'invalid_premium_amount': 'Kiasi cha malipo ya bima si sahihi',
    'no_active_policies': 'Hakuna sera hai zilizopatikana',
    'error_loading_policies': 'Kosa la kupakia sera',
    'error_loading_claims': 'Kosa la kupakia madai',
    'error_calculating_premium': 'Kosa la kuhesabu malipo ya bima',
    // SMS Notification Templates
    'sms_enrollment_confirmation': 'Sera ya bima {policyNumber} imeundwa. Malipo: {premium}. Mzunguko: {frequency}',
    'sms_premium_deducted': 'Malipo ya bima ya {amount} yamekatwa. Yanayofuata: {nextDue}',
    'sms_premium_reminder': 'Malipo ya bima ya {amount} yanahitajika tarehe {dueDate}',
    'sms_policy_expiring': 'Sera yako ya bima itaisha baada ya siku {days}. Tafadhali fanya upya.',
    'sms_claim_submitted': 'Madai {claimNumber} yamewasilishwa kwa ng\'ombe {cattleId}. Tutakujulisha mabadiliko.',
    'sms_claim_approved': 'Madai {claimNumber} yameidhinishwa. Kiasi cha malipo: {amount}',
    'sms_claim_rejected': 'Madai {claimNumber} yamekataliwa. Sababu: {reason}',
    'sms_claim_settled': 'Madai {claimNumber} yamelipwa. Kiasi: {amount} kimelipwa.',
    // Sync
    'sync_status': 'Hali ya Usawazishaji',
    'sync_now': 'Sawazisha Sasa',
    'sync_completed': 'Usawazishaji umekamilika',
    'all_synced_subtitle': 'Data yako yote iko sawa',
    'offline_subtitle': 'Vitu {count} vinasubiri kusawazishwa',
    'pending_sync_subtitle': 'Vitu {count} vinasubiri kusawazishwa',
    'sync_error_subtitle': 'Imeshindwa kusawazisha data',
    'connection_status': 'Hali ya Muunganisho',
    'online': 'Mtandaoni',
    'offline': 'Nje ya Mtandao',
    'pending_items': 'Vitu Vinavyosubiri',
    'last_sync': 'Usawazishaji wa Mwisho',
    'never': 'Kamwe',
    'minutes_ago': 'Dakika {minutes} zilizopita',
    'hours_ago': 'Masaa {hours} yaliyopita',
    'days_ago': 'Siku {days} zilizopita',
    'offline_message': 'Uko nje ya mtandao. Data itasawazishwa moja kwa moja muunganisho utakaporejeleshwa.',
    'about_sync': 'Kuhusu Usawazishaji',
    'sync_description': 'Programu inasawazisha data yako moja kwa moja unapokuwa na muunganisho wa mtandao. Unaweza kufanya kazi nje ya mtandao na mabadiliko yote yatahifadhiwa na kusawazishwa baadaye.',
    // Farmer Self-Service (additional keys)
    'quick_links': 'Viungo vya Haraka',
    'milk_history': 'Historia ya Maziwa',
    'my_cattle': 'Ng\'ombe Wangu',
    'deliveries': 'Utoaji',
    'earnings': 'Mapato',
    'pending_payment': 'Malipo Yanayosubiri',
    'loan_balance': 'Salio la Mkopo',
    'insurance_status': 'Hali ya Bima',
    'cattle_covered': 'ng\'ombe waliolindwa',
    'all_time': 'Wakati Wote',
    'last_week': 'Wiki Iliyopita',
    'no_deliveries_found': 'Hakuna utoaji uliopatikana',
    'total_cattle': 'Jumla ya Ng\'ombe',
    'avg_production': 'Wastani wa Uzalishaji',
    'no_cattle_registered': 'Hakuna ng\'ombe waliosajiliwa',
    'error_loading_cattle': 'Kosa la kupakia ng\'ombe',
    'avg_daily': 'Wastani wa Kila Siku',
    'last_delivery': 'Utoaji wa Mwisho',
    'no_active_loans': 'Hakuna mikopo hai',
    'apply_for_loan_to_get_started': 'Omba mkopo ili kuanza',
    'active_loans': 'Mikopo Hai',
    'completed_loans': 'Mikopo Iliyokamilika',
    'error_loading_loans': 'Kosa la kupakia mikopo',
    'input_loan': 'Mkopo wa Pembejeo',
    'repayment_progress': 'Maendeleo ya Malipo',
    'disbursed': 'Imetolewa',
    'defaulted': 'Imekosa',
    'loan_summary': 'Muhtasari wa Mkopo',
    'disbursement_date': 'Tarehe ya Utoaji',
    'no_payments_yet': 'Hakuna malipo bado',
    'error_loading_payments': 'Kosa la kupakia malipo',
    'flat': 'Papo Hapo',
    'reducing_balance': 'Salio Linalopungua',
    'active_policy': 'Sera Hai',
    'valid_until': 'Halali Hadi',
    'no_covered_cattle': 'Hakuna ng\'ombe waliolindwa',
    'no_claims_submitted': 'Hakuna madai yaliyowasilishwa',
    'profile_settings': 'Wasifu na Mipangilio',
    'contact_information': 'Maelezo ya Mawasiliano',
    'app_settings': 'Mipangilio ya Programu',
    'manage_notification_settings': 'Dhibiti mipangilio ya arifa',
    'pricing_information': 'Maelezo ya Bei',
    'current_milk_price': 'Bei ya Sasa ya Maziwa',
    'liter': 'lita',
    'price_varies_by_quality': 'Bei inabadilika kulingana na ubora',
    'confirm_logout': 'Una uhakika unataka kutoka?',
    
    // Analytics & Reporting
    'analytics_dashboard': 'Dashibodi ya Takwimu',
    'milk_production': 'Uzalishaji wa Maziwa',
    'farmer_demographics': 'Takwimu za Wakulima',
    'livestock': 'Mifugo',
    'financial': 'Fedha',
    'overview': 'Muhtasari',
    'filter': 'Chuja',
    'export': 'Hamisha',
    'refresh': 'Onyesha Upya',
    
    // KPIs and Metrics
    'total_milk_collected': 'Jumla ya Maziwa Yaliyokusanywa',
    'average_per_day': 'Wastani kwa Siku',
    'average_per_farmer': 'Wastani kwa Mkulima',
    'quality_distribution': 'Usambazaji wa Ubora',
    'premium_quality': 'Bora',
    'standard': 'Kawaida',
    'substandard': 'Chini ya Kiwango',
    'production_trend': 'Mwenendo wa Uzalishaji',
    'collection_centers': 'Vituo vya Ukusanyaji',
    'peak_hours': 'Masaa ya Kilele',
    'vs_last_period': 'dhidi ya Kipindi Kilichopita',
    
    // Farmer Analytics
    'new_farmers': 'Wakulima Wapya',
    'gender_distribution': 'Usambazaji wa Jinsia',
    'male': 'Kiume',
    'female': 'Kike',
    'age_distribution': 'Usambazaji wa Umri',
    'geographic_distribution': 'Usambazaji wa Kijiografia',
    'app_adoption': 'Matumizi ya Programu',
    'credit_score_distribution': 'Usambazaji wa Alama za Mkopo',
    'registration_trend': 'Mwenendo wa Usajili',
    
    // Livestock Analytics
    'total_cattle_count': 'Jumla ya Ng\'ombe',
    'lactation_rate': 'Kiwango cha Kunyonyesha',
    'breed_distribution': 'Usambazaji wa Aina',
    'health_status': 'Hali ya Afya',
    'healthy': 'Wenye Afya',
    'sick': 'Wagonjwa',
    'under_treatment': 'Chini ya Matibabu',
    'farm_assets': 'Mali za Shamba',
    'avocado_trees': 'Miti ya Parachichi',
    'chickens': 'Kuku',
    'beehives': 'Mizinga',
    
    // Financial Analytics
    'total_payments': 'Jumla ya Malipo',
    'average_price_per_liter': 'Bei ya Wastani kwa Lita',
    'payment_trend': 'Mwenendo wa Malipo',
    'loan_metrics': 'Vipimo vya Mikopo',
    'total_disbursed': 'Jumla Iliyotolewa',
    'total_outstanding': 'Jumla Inayobaki',
    'repayment_rate': 'Kiwango cha Malipo',
    'default_rate': 'Kiwango cha Kukosa',
    'insurance_metrics': 'Vipimo vya Bima',
    'active_policies': 'Sera Hai',
    'premium_collected': 'Malipo ya Bima Yaliyokusanywa',
    'coverage_percentage': 'Asilimia ya Ulinzi',
    'revenue_breakdown': 'Maelezo ya Mapato',
    
    // Inventory Analytics
    'total_inventory_value': 'Thamani ya Jumla ya Hisa',
    'low_stock_products': 'Bidhaa za Hisa Chache',
    'out_of_stock_products': 'Bidhaa Zilizokwisha',
    'sales_revenue': 'Mapato ya Mauzo',
    'top_selling_products': 'Bidhaa Zinazouzwa Zaidi',
    'category_breakdown': 'Maelezo ya Aina',
    'stock_turnover_rate': 'Kiwango cha Mzunguko wa Hisa',
    
    // Comparative Analytics
    'comparative_analytics': 'Takwimu za Kulinganisha',
    'current_period': 'Kipindi cha Sasa',
    'comparison_period': 'Kipindi cha Kulinganisha',
    'percentage_change': 'Mabadiliko ya Asilimia',
    'improving': 'Inaboreshwa',
    'declining': 'Inashuka',
    'stable': 'Imara',
    'benchmarking': 'Kipimo',
    'top_performers': 'Wazalishaji Bora',
    'bottom_performers': 'Wazalishaji Duni',
    
    // Predictive Analytics
    'predictive_analytics': 'Takwimu za Utabiri',
    'forecast': 'Utabiri',
    'trend_line': 'Mstari wa Mwenendo',
    'confidence_interval': 'Kipindi cha Kuamini',
    'seasonal_patterns': 'Mifumo ya Msimu',
    'projected_growth': 'Ukuaji Unaotarajiwa',
    'forecast_days': 'Siku za Utabiri',
    'days_30': 'Siku 30',
    'days_60': 'Siku 60',
    'days_90': 'Siku 90',
    
    // Alerts
    'alerts': 'Tahadhari',
    'critical': 'Muhimu Sana',
    'warning': 'Onyo',
    'informational': 'Taarifa',
    'production_drop': 'Kushuka kwa Uzalishaji',
    'loan_default_alert': 'Tahadhari ya Kukosa Mkopo',
    'insurance_lapse_alert': 'Tahadhari ya Kuisha Bima',
    'farmer_engagement_alert': 'Tahadhari ya Ushiriki wa Mkulima',
    'quality_concern_alert': 'Tahadhari ya Wasiwasi wa Ubora',
    'mark_as_read': 'Weka kama Imesomwa',
    'dismiss': 'Ondoa',
    'no_alerts_found': 'Hakuna tahadhari zilizopatikana',
    
    // Reports
    'reports': 'Ripoti',
    'generate_report': 'Tengeneza Ripoti',
    'report_templates': 'Violezo vya Ripoti',
    'monthly_summary': 'Muhtasari wa Mwezi',
    'quarterly_review': 'Mapitio ya Robo',
    'annual_report': 'Ripoti ya Mwaka',
    'government_submission': 'Uwasilishaji wa Serikali',
    'custom_report': 'Ripoti Maalum',
    'export_format': 'Muundo wa Kuhamisha',
    'pdf': 'PDF',
    'excel': 'Excel',
    'csv': 'CSV',
    'preview': 'Onyesha',
    'download': 'Pakua',
    'share': 'Shiriki',
    'scheduled_reports': 'Ripoti Zilizopangwa',
    'schedule_report': 'Panga Ripoti',
    'frequency': 'Mzunguko',
    'daily': 'Kila Siku',
    'weekly': 'Kila Wiki',
    'on_demand': 'Inapohitajika',
    'recipients': 'Wapokeaji',
    'report_generated': 'Ripoti imetengenezwa kwa mafanikio',
    'report_generation_failed': 'Kutengeneza ripoti kumeshindwa',
    
    // Filters
    'date_range': 'Kipindi cha Tarehe',
    'this_quarter': 'Robo Hii',
    'this_year': 'Mwaka Huu',
    'custom_range': 'Kipindi Maalum',
    'cooperative': 'Ushirika',
    'collection_center': 'Kituo cha Ukusanyaji',
    'location': 'Mahali',
    'region': 'Mkoa',
    'district': 'Wilaya',
    'ward': 'Kata',
    'village': 'Kijiji',
    'farmer_filters': 'Vichujio vya Wakulima',
    'gender': 'Jinsia',
    'age_range': 'Kipindi cha Umri',
    'credit_score_range': 'Kipindi cha Alama za Mkopo',
    'app_access_status': 'Hali ya Upatikanaji wa Programu',
    'cattle_filters': 'Vichujio vya Ng\'ombe',
    'breed': 'Aina',
    'lactation_status': 'Hali ya Kunyonyesha',
    'health_status_filter': 'Hali ya Afya',
    'apply_filters': 'Tekeleza Vichujio',
    'reset_filters': 'Weka Upya Vichujio',
    'save_filter': 'Hifadhi Kichujio',
    'saved_filters': 'Vichujio Vilivyohifadhiwa',
    'filter_name': 'Jina la Kichujio',
    
    // Chart Labels
    'days_7': 'Siku 7',
    'days_30_chart': 'Siku 30',
    'days_90_chart': 'Siku 90',
    'months_12_chart': 'Miezi 12',
    'liters': 'Lita',
    'count': 'Hesabu',
    'percentage': 'Asilimia',
    'amount': 'Kiasi',
    'date': 'Tarehe',
    'value': 'Thamani',
    
    // Error Messages
    'error_loading_analytics': 'Kosa la kupakia takwimu',
    'insufficient_data': 'Data haitoshi',
    'invalid_filter': 'Kichujio si sahihi',
    'no_data_available': 'Hakuna data inayopatikana',
    'error_generating_report': 'Kosa la kutengeneza ripoti',
    
    // Loading States
    'loading_analytics': 'Inapakia takwimu...',
    'calculating_metrics': 'Inahesabu vipimo...',
    'generating_report': 'Inatengeneza ripoti...',
    'exporting_data': 'Inahamisha data...',
  },
};

/// Localization delegate implementation
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'sw'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
