/// Centralized constants for app-wide values
/// 
/// This class contains application-wide constants including limits,
/// defaults, and configuration values used throughout the app.
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ======================
  // APP INFORMATION
  // ======================
  
  static const String appName = 'New Words';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A vocabulary learning app';
  static const String packageName = 'com.shukebeta.newwords';
  
  // ======================
  // NAVIGATION ROUTES
  // ======================
  
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeHome = '/home';
  static const String routeMainMenu = '/main-menu';
  static const String routeSettings = '/settings';
  static const String routeNewWordsList = '/new-words-list';
  static const String routeWordDetail = '/word-detail';
  static const String routeStories = '/stories';
  static const String routeMemories = '/memories';
  
  // ======================
  // UI/UX CONSTANTS
  // ======================
  
  // Animation durations (in milliseconds)
  static const int animationDurationFast = 150;
  static const int animationDurationNormal = 300;
  static const int animationDurationSlow = 500;
  
  // Delays and timeouts
  static const int splashScreenDuration = 2000;
  static const int snackbarDuration = 3000;
  static const int debounceDelay = 300;
  static const int autoHideDelay = 5000;
  
  // UI dimensions
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  // ======================
  // BUSINESS LOGIC LIMITS
  // ======================
  
  // Word management
  static const int maxWordLength = 100;
  static const int minWordLength = 1;
  static const int maxExplanationLength = 1000;
  static const int maxWordsPerPage = 50;
  static const int defaultWordsPerPage = 20;
  
  // Story management
  static const int maxStoryLength = 10000;
  static const int minStoryLength = 100;
  static const int maxStoriesPerPage = 20;
  static const int defaultStoriesPerPage = 10;
  
  // User input validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int maxEmailLength = 254;
  static const int maxNameLength = 100;
  
  // ======================
  // TIMING CONSTANTS
  // ======================
  
  // Auto-save intervals (in milliseconds)
  static const int autoSaveInterval = 30000; // 30 seconds
  static const int syncInterval = 300000; // 5 minutes
  
  // Session management
  static const int tokenRefreshThreshold = 300000; // 5 minutes before expiry
  static const int sessionTimeout = 3600000; // 1 hour
  static const int rememberMeDuration = 2592000000; // 30 days
  
  // Feature intervals
  static const int addWordReminderInterval = 3600000; // 1 hour
  static const int dailyWordsResetTime = 86400000; // 24 hours
  
  // ======================
  // LANGUAGE CONSTANTS
  // ======================
  
  static const String defaultLanguageCode = 'en';
  static const String defaultCountryCode = 'US';
  static const String defaultLocale = 'en_US';
  
  // Supported languages
  static const List<String> supportedLanguages = ['en', 'zh'];
  static const List<String> supportedCountries = ['US', 'CN'];
  
  // Language display names
  static const Map<String, String> languageNames = {
    'en': 'English',
    'zh': '中文',
  };
  
  // ======================
  // THEME CONSTANTS
  // ======================
  
  static const String themeLight = 'light';
  static const String themeDark = 'dark';
  static const String themeSystem = 'system';
  
  // ======================
  // FEATURE FLAGS
  // ======================
  
  static const bool enableDebugMode = false;
  static const bool enableLogging = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  
  // ======================
  // REGEX PATTERNS
  // ======================
  
  static const String emailRegex = r'^[\w+\-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String passwordRegex = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{6,}$';
  static const String wordRegex = r"^[\p{L}\s\-']+$";
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
  
  // ======================
  // ERROR MESSAGES
  // ======================
  
  static const String errorNetworkUnavailable = 'Network is not available. Please check your connection.';
  static const String errorServerUnavailable = 'Server is temporarily unavailable. Please try again later.';
  static const String errorInvalidCredentials = 'Invalid email or password. Please try again.';
  static const String errorSessionExpired = 'Your session has expired. Please log in again.';
  static const String errorGeneric = 'An unexpected error occurred. Please try again.';
  
  // ======================
  // SUCCESS MESSAGES
  // ======================
  
  static const String successWordAdded = 'Word added successfully!';
  static const String successWordDeleted = 'Word deleted successfully!';
  static const String successAccountCreated = 'Account created successfully!';
  static const String successPasswordChanged = 'Password changed successfully!';
  static const String successDataSaved = 'Data saved successfully!';
  
  // ======================
  // UTILITY METHODS
  // ======================
  
  /// Get all route names as a set for validation
  static Set<String> get allRoutes => {
    routeLogin,
    routeRegister,
    routeHome,
    routeMainMenu,
    routeSettings,
    routeNewWordsList,
    routeWordDetail,
    routeStories,
    routeMemories,
  };
  
  /// Get all supported languages as a set
  static Set<String> get supportedLanguageSet => supportedLanguages.toSet();
  
  /// Get all theme modes as a set
  static Set<String> get allThemes => {themeLight, themeDark, themeSystem};
  
  /// Validate that a route exists in the defined constants
  static bool isValidRoute(String route) {
    return allRoutes.contains(route);
  }
  
  /// Validate that a language is supported
  static bool isSupportedLanguage(String languageCode) {
    return supportedLanguageSet.contains(languageCode);
  }
  
  /// Validate that a theme mode is valid
  static bool isValidTheme(String theme) {
    return allThemes.contains(theme);
  }
  
  /// Get language display name
  static String getLanguageDisplayName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }
}