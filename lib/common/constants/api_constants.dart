/// Centralized constants for API endpoints, headers, and response fields
/// 
/// This class contains all API-related constants to eliminate magic strings
/// and ensure consistency across the application.
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  // ======================
  // API ENDPOINTS
  // ======================
  
  // Authentication endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String accountRefreshToken = '/account/refreshToken';
  static const String accountMyInformation = '/account/myInformation';
  static const String accountChangePassword = '/account/changePassword';
  static const String accountUpdateLanguages = '/account/updateLanguages';
  static const String accountDelete = '/account/delete';
  
  // Settings endpoints
  static const String settingsLanguages = '/settings/languages';
  static const String settingsGetAll = '/settings/getAll';
  static const String settingsUpsert = '/settings/upsert';
  
  // Stories endpoints
  static const String storiesMyStories = '/stories/MyStories';
  static const String storiesStorySquare = '/stories/StorySquare';
  static const String storiesMyFavorite = '/stories/MyFavorite';
  static const String storiesGenerate = '/stories/Generate';
  static const String storiesToggleFavorite = '/stories/ToggleFavorite';
  static const String storiesMarkAsRead = '/stories/MarkAsRead';
  
  // Vocabulary endpoints
  static const String vocabularyAdd = '/vocabulary/add';
  static const String vocabularyList = '/vocabulary/list';
  static const String vocabularyDelete = '/vocabulary/delete';
  static const String vocabularyRefreshExplanation = '/vocabulary/refreshExplanation';
  static const String vocabularyMemories = '/vocabulary/Memories';
  static const String vocabularyMemoriesOn = '/vocabulary/MemoriesOn';
  
  // ======================
  // HTTP HEADERS
  // ======================
  
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String headerAllowAnonymous = 'AllowAnonymous';
  static const String headerAccept = 'Accept';
  static const String headerUserAgent = 'User-Agent';
  
  // Header values
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormData = 'application/x-www-form-urlencoded';
  static const String bearerPrefix = 'Bearer ';
  static const String allowAnonymousValue = 'true';
  
  // ======================
  // RESPONSE FIELDS
  // ======================
  
  // Standard response fields
  static const String responseFieldSuccessful = 'successful';
  static const String responseFieldData = 'data';
  static const String responseFieldMessage = 'message';
  static const String responseFieldErrorCode = 'errorCode';
  
  // Authentication response fields
  static const String responseFieldToken = 'token';
  static const String responseFieldUserId = 'userId';
  static const String responseFieldEmail = 'email';
  static const String responseFieldNativeLanguage = 'nativeLanguage';
  static const String responseFieldCurrentLearningLanguage = 'currentLearningLanguage';
  
  // Pagination fields
  static const String requestFieldPageNumber = 'pageNumber';
  static const String requestFieldPageSize = 'pageSize';
  static const String requestFieldLocalTimezone = 'localTimezone';
  static const String requestFieldYyyyMMdd = 'yyyyMMdd';
  
  // ======================
  // QUERY PARAMETERS
  // ======================
  
  // Common query parameters
  static const String paramEmail = 'email';
  static const String paramPassword = 'password';
  static const String paramNativeLanguage = 'nativeLanguage';
  static const String paramLearningLanguage = 'learningLanguage';
  static const String paramPageNumber = 'pageNumber';
  static const String paramPageSize = 'pageSize';
  static const String paramLocalTimezone = 'localTimezone';
  static const String paramYyyyMMdd = 'yyyyMMdd';
  
  // ======================
  // DEFAULT VALUES
  // ======================
  
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int minPageSize = 1;
  static const int defaultTimeout = 30000; // 30 seconds
  static const int longRunningTimeout = 300000; // 5 minutes for story generation
  
  // ======================
  // UTILITY METHODS
  // ======================
  
  /// Get all endpoint paths as a set for validation
  static Set<String> get allEndpoints => {
    authLogin,
    authRegister,
    accountRefreshToken,
    accountMyInformation,
    accountChangePassword,
    accountUpdateLanguages,
    accountDelete,
    settingsLanguages,
    settingsGetAll,
    settingsUpsert,
    storiesMyStories,
    storiesStorySquare,
    storiesMyFavorite,
    storiesGenerate,
    storiesToggleFavorite,
    storiesMarkAsRead,
    vocabularyAdd,
    vocabularyList,
    vocabularyDelete,
    vocabularyRefreshExplanation,
    vocabularyMemories,
    vocabularyMemoriesOn,
  };
  
  /// Get all header names as a set for validation
  static Set<String> get allHeaders => {
    headerContentType,
    headerAuthorization,
    headerAllowAnonymous,
    headerAccept,
    headerUserAgent,
  };
  
  /// Get all response field names as a set for validation
  static Set<String> get allResponseFields => {
    responseFieldSuccessful,
    responseFieldData,
    responseFieldMessage,
    responseFieldErrorCode,
    responseFieldToken,
    responseFieldUserId,
    responseFieldEmail,
    responseFieldNativeLanguage,
    responseFieldCurrentLearningLanguage,
  };
  
  /// Validate that an endpoint exists in the defined constants
  static bool isValidEndpoint(String endpoint) {
    return allEndpoints.contains(endpoint);
  }
  
  /// Get endpoints grouped by category for better organization
  static Map<String, Set<String>> get endpointsByCategory => {
    'authentication': {
      authLogin,
      authRegister,
      accountRefreshToken,
      accountMyInformation,
      accountChangePassword,
      accountUpdateLanguages,
      accountDelete,
    },
    'settings': {
      settingsLanguages,
      settingsGetAll,
      settingsUpsert,
    },
    'stories': {
      storiesMyStories,
      storiesStorySquare,
      storiesMyFavorite,
      storiesGenerate,
      storiesToggleFavorite,
      storiesMarkAsRead,
    },
    'vocabulary': {
      vocabularyAdd,
      vocabularyList,
      vocabularyDelete,
      vocabularyRefreshExplanation,
      vocabularyMemories,
      vocabularyMemoriesOn,
    },
  };
}