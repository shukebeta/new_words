import 'package:new_words/services/account_service.dart';
import 'package:new_words/entities/api_result.dart';

/// Mock AccountService for testing
/// This prevents GetIt dependency issues in unit tests
class MockAccountService extends AccountService {
  MockAccountService() : super(
    accountApi: MockAccountApi(),
    userSettingsService: MockUserSettingsService(),
    tokenUtils: MockTokenUtils(),
  );
  
  @override
  Future<ApiResult<void>> refreshToken() async {
    return ApiResult.success(null);
  }
  
  @override
  String? getValidToken() => 'mock-token';
  
  @override
  bool hasValidToken() => true;
}

// Minimal mock implementations to satisfy constructor
class MockAccountApi {
  // Minimal implementation
}

class MockUserSettingsService {
  // Minimal implementation  
}

class MockTokenUtils {
  // Minimal implementation
}