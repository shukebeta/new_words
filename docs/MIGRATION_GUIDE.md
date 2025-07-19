# Migration Guide: Legacy to V2 Architecture

## Overview

This guide provides step-by-step instructions for migrating existing features from legacy patterns to the modern V2 architecture. It covers the migration process, common pitfalls, and validation steps.

## When to Migrate

### Immediate Migration Required
- **New Feature Development**: Always use V2 patterns
- **Bug Fixes in Critical Paths**: Upgrade to V2 during bug fixes
- **Performance Issues**: V2 patterns often resolve performance problems
- **Testing Gaps**: V2 includes comprehensive testing patterns

### Gradual Migration
- **Stable Legacy Features**: Migrate during regular maintenance cycles
- **Complex Features**: Break down into smaller migration chunks
- **Low-Traffic Features**: Lower priority but should eventually migrate

## Pre-Migration Checklist

### Environment Setup
- [ ] Ensure `flutter pub get` is up to date
- [ ] Run `flutter analyze` to check for existing issues
- [ ] Run existing tests to establish baseline: `flutter test`
- [ ] Create feature branch: `git checkout -b feature/migrate-[feature-name]`

### Understanding Current Implementation
- [ ] Identify all related files (API, Service, Provider, UI)
- [ ] Document current data flow and dependencies
- [ ] Note any custom error handling or business logic
- [ ] Check for existing tests and their coverage

## Step-by-Step Migration Process

### Step 1: Create V2 API Layer

#### 1.1 Create New API File
```bash
# Create new API file
touch lib/apis/[feature]_api_v2.dart
```

#### 1.2 Implement V2 API Pattern
```dart
// lib/apis/[feature]_api_v2.dart
import 'package:new_words/common/foundation/foundation.dart';
import 'package:new_words/entities/[feature]_entities.dart';

class [Feature]ApiV2 extends BaseApi {
  [Feature]ApiV2([super.customDio]);

  // Migrate each method from legacy API
  Future<ApiResponseV2<[Entity]>> get[Entity](int id) async {
    validateNumericField(id, 'id', min: 1);

    return await get<[Entity]>(
      '/[feature]/[entity]/$id',
      fromJson: (json) => [Entity].fromJson(json as Map<String, dynamic>),
    );
  }

  // Add other methods following V2 patterns...
}
```

#### 1.3 Update Dependency Registration
```dart
// lib/dependency_injection.dart
void _registerApis() {
  // Keep existing registration
  locator.registerLazySingleton(() => [Feature]Api());
  
  // Add V2 registration
  locator.registerLazySingleton(() => [Feature]ApiV2());
}
```

### Step 2: Create V2 Service Layer

#### 2.1 Create New Service File
```bash
touch lib/services/[feature]_service_v2.dart
```

#### 2.2 Implement V2 Service Pattern
```dart
// lib/services/[feature]_service_v2.dart
import 'package:new_words/apis/[feature]_api_v2.dart';
import 'package:new_words/common/foundation/foundation.dart';
import 'package:new_words/entities/[feature]_entities.dart';
import 'package:new_words/utils/app_logger.dart';
import 'package:new_words/utils/app_logger_interface.dart';

class [Feature]ServiceV2 extends BaseService {
  final [Feature]ApiV2 _api;
  final AppLoggerInterface _logger;

  [Feature]ServiceV2({
    required [Feature]ApiV2 api,
    AppLoggerInterface? logger,
  })  : _api = api,
        _logger = logger ?? AppLogger.instance;

  Future<[Entity]> get[Entity](int id) async {
    logOperation('get[Entity]', parameters: {'id': id});

    try {
      // Add business logic here if needed
      final response = await _api.get[Entity](id);
      return processResponse(response);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  // Migrate other methods...
}
```

#### 2.3 Update Service Registration
```dart
// lib/dependency_injection.dart
void _registerServices() {
  // Keep existing registration
  locator.registerLazySingleton(() => [Feature]Service());
  
  // Add V2 registration
  locator.registerLazySingleton(
    () => [Feature]ServiceV2(
      api: locator<[Feature]ApiV2>(),
      logger: locator<AppLoggerInterface>(),
    ),
  );
}
```

### Step 3: Update Provider Layer

#### 3.1 Update Provider Dependencies
```dart
// lib/providers/[feature]_provider.dart

// Change import
// OLD: import 'package:new_words/services/[feature]_service.dart';
// NEW: 
import 'package:new_words/services/[feature]_service_v2.dart';
import 'package:new_words/common/foundation/service_exceptions.dart';

class [Feature]Provider extends AuthAwareProvider {
  // Update service type
  final [Feature]ServiceV2 _service;

  [Feature]Provider(this._service);

  // Update methods to use executeWithErrorHandling
  Future<void> load[Entity]() async {
    if (_isLoading) return;

    final result = await executeWithErrorHandling<[Entity]>(
      operation: () => _service.get[Entity](),
      setLoading: (loading) => _isLoading = loading,
      setError: (error) => _error = error,
      operationName: 'load [entity]',
    );

    if (result != null) {
      _entity = result;
    }
  }
}
```

#### 3.2 Update Provider Registration
```dart
// lib/main.dart
MultiProvider(
  providers: [
    // Update provider to use V2 service
    ChangeNotifierProvider(
      create: (_) => [Feature]Provider(di.locator<[Feature]ServiceV2>()),
    ),
  ],
)
```

### Step 4: Create Comprehensive Tests

#### 4.1 API Tests
```bash
touch test/apis/[feature]_api_v2_test.dart
```

```dart
// Follow patterns in existing V2 API tests
@GenerateMocks([Dio])
void main() {
  group('[Feature]ApiV2', () {
    // Test all methods following established patterns
  });
}
```

#### 4.2 Service Tests
```bash
touch test/services/[feature]_service_v2_test.dart
```

#### 4.3 Provider Tests (if needed)
```bash
touch test/providers/[feature]_provider_test.dart
```

### Step 5: Generate Mocks and Run Tests
```bash
# Generate mocks
dart run build_runner build

# Run tests
flutter test test/apis/[feature]_api_v2_test.dart
flutter test test/services/[feature]_service_v2_test.dart

# Run all tests to ensure no regressions
flutter test
```

### Step 6: Validate Migration

#### 6.1 Functional Testing
```bash
# Run the app
flutter run

# Test the migrated feature thoroughly
# - Happy path scenarios
# - Error scenarios (network errors, validation errors)
# - Edge cases (empty data, large datasets)
```

#### 6.2 Performance Testing
- Monitor API response times
- Check memory usage patterns
- Verify no memory leaks in provider state management

#### 6.3 Error Handling Testing
- Disconnect network and test error handling
- Simulate server errors (500, 404, etc.)
- Test validation errors with invalid input

## Common Migration Scenarios

### Scenario 1: Simple CRUD Operations

#### Legacy Pattern
```dart
// Legacy API
class OldApi {
  Future<Response> getData() async {
    return await _dio.get('/data');
  }
}

// Legacy Service  
class OldService {
  Future<List<DataItem>> getData() async {
    final response = await _api.getData();
    final result = ApiResult.fromJson(response.data);
    if (result.isSuccess) {
      return (result.data as List).map((item) => DataItem.fromJson(item)).toList();
    } else {
      throw ApiException(result.message);
    }
  }
}
```

#### V2 Migration
```dart
// V2 API
class DataApiV2 extends BaseApi {
  DataApiV2([super.customDio]);

  Future<ApiResponseV2<List<DataItem>>> getData() async {
    return await get<List<DataItem>>(
      '/data',
      fromJson: (json) => (json as List<dynamic>)
          .map((item) => DataItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

// V2 Service
class DataServiceV2 extends BaseService {
  final DataApiV2 _api;
  
  DataServiceV2({required DataApiV2 api, AppLoggerInterface? logger})
      : _api = api,
        super();

  Future<List<DataItem>> getData() async {
    logOperation('getData');
    
    try {
      final response = await _api.getData();
      return processResponse(response);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }
}
```

### Scenario 2: Complex Provider State

#### Legacy Pattern
```dart
// Legacy Provider with manual error handling
class LegacyProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Item> _items = [];

  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _service.getItems();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Unknown error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

#### V2 Migration
```dart
// V2 Provider with standardized error handling
class ItemProvider extends AuthAwareProvider {
  final ItemServiceV2 _service;
  
  ItemProvider(this._service);

  List<Item> _items = [];
  List<Item> get items => _items;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  Future<void> loadItems() async {
    if (_isLoading) return;

    final result = await executeWithErrorHandling<List<Item>>(
      operation: () => _service.getItems(),
      setLoading: (loading) => _isLoading = loading,
      setError: (error) => _error = error,
      operationName: 'load items',
    );

    if (result != null) {
      _items = result;
    }
  }

  @override
  void clearAllData() {
    _items = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  Future<void> onLogin() async {
    await loadItems();
  }
}
```

### Scenario 3: Pagination Migration

#### Legacy Pattern
```dart
// Legacy pagination
Future<void> loadMore() async {
  if (_isLoadingMore || !_hasMore) return;
  
  _isLoadingMore = true;
  notifyListeners();
  
  try {
    final response = await _api.getItems(_currentPage + 1, _pageSize);
    final result = ApiResult.fromResponse(response);
    if (result.isSuccess) {
      final newItems = (result.data['items'] as List)
          .map((item) => Item.fromJson(item))
          .toList();
      _items.addAll(newItems);
      _currentPage++;
      _hasMore = newItems.length == _pageSize;
    }
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoadingMore = false;
    notifyListeners();
  }
}
```

#### V2 Migration
```dart
// V2 pagination
Future<void> loadMore() async {
  if (_isLoading || !canLoadMore) return;

  final result = await executeWithErrorHandling<PageData<Item>>(
    operation: () => _service.getItems(_currentPage + 1, _pageSize),
    setLoading: (loading) => _isLoading = loading,
    setError: (error) => _error = error,
    operationName: 'load more items',
  );

  if (result != null) {
    _items.addAll(result.dataList);
    _currentPage++;
    _totalCount = result.totalCount;
  }
}

bool get canLoadMore => _items.length < _totalCount;
```

## Validation and Testing

### Pre-Release Checklist

#### Code Quality
- [ ] All new code follows V2 patterns
- [ ] No direct API usage in providers
- [ ] All async operations use `executeWithErrorHandling()`
- [ ] Proper input validation at API layer
- [ ] Business logic validation at service layer

#### Testing
- [ ] API tests cover all endpoints and validation scenarios
- [ ] Service tests cover business logic and error handling
- [ ] Provider tests cover state management if complex
- [ ] Integration tests pass
- [ ] All existing tests still pass

#### Performance
- [ ] No performance regressions in app startup
- [ ] Memory usage remains stable
- [ ] Network request patterns unchanged or improved

#### Error Handling
- [ ] All error types properly handled
- [ ] User-friendly error messages displayed
- [ ] No crashes on network errors
- [ ] Graceful degradation on API failures

### Rollback Plan

If issues are discovered after migration:

1. **Immediate Rollback**
   ```dart
   // In provider registration, revert to legacy service
   ChangeNotifierProvider(
     create: (_) => [Feature]Provider(di.locator<[Feature]Service>()), // Legacy
   ),
   ```

2. **Fix and Re-migrate**
   - Address issues in V2 implementation
   - Add additional tests for discovered edge cases
   - Re-deploy with fixes

3. **Legacy Cleanup**
   - Only remove legacy implementations after V2 is stable
   - Monitor for several release cycles before cleanup

## Common Pitfalls and Solutions

### Pitfall 1: Forgetting Auth Lifecycle
**Problem**: Provider doesn't clear data on logout
```dart
// Missing implementation
class BadProvider extends AuthAwareProvider {
  // Missing clearAllData() implementation
}
```

**Solution**: Always implement auth lifecycle methods
```dart
class GoodProvider extends AuthAwareProvider {
  @override
  void clearAllData() {
    _data = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  Future<void> onLogin() async {
    await loadInitialData();
  }
}
```

### Pitfall 2: Inconsistent Error Handling
**Problem**: Some operations use manual try-catch while others use `executeWithErrorHandling()`

**Solution**: Standardize all async operations
```dart
// Convert all manual try-catch blocks to use executeWithErrorHandling()
```

### Pitfall 3: Missing Input Validation
**Problem**: API accepts invalid data that should be caught early

**Solution**: Add comprehensive validation
```dart
Future<ApiResponseV2<Entity>> createEntity(CreateRequest request) async {
  validateInput({
    'name': request.name,
    'type': request.type,
  });

  validateStringField(request.name, 'name', minLength: 1, maxLength: 100);
  // Add more validation as needed
}
```

### Pitfall 4: Test Coverage Gaps
**Problem**: Migration doesn't include comprehensive tests

**Solution**: Follow test patterns from existing V2 implementations
- API: Test validation, success, and error scenarios
- Service: Test business logic and exception conversion
- Provider: Test state management if complex

## Migration Timeline

### Phase 1: Foundation (Week 1)
- [ ] Create V2 API and Service implementations
- [ ] Add basic test coverage
- [ ] Register in dependency injection

### Phase 2: Integration (Week 2)  
- [ ] Update provider to use V2 service
- [ ] Comprehensive testing and validation
- [ ] Performance testing

### Phase 3: Deployment (Week 3)
- [ ] Deploy with monitoring
- [ ] Validate in production
- [ ] Address any issues

### Phase 4: Cleanup (Week 4+)
- [ ] Remove legacy implementations after stability confirmed
- [ ] Update documentation
- [ ] Share learnings with team

## Success Metrics

### Technical Metrics
- **Test Coverage**: >90% for new V2 implementations
- **Performance**: No regressions in response times
- **Error Rate**: Reduced error rates due to better validation
- **Code Quality**: Improved maintainability scores

### User Experience Metrics
- **Crash Rate**: Should decrease due to better error handling
- **Error Messages**: More user-friendly and actionable
- **Feature Reliability**: Improved consistency across features

Following this migration guide ensures a smooth transition from legacy patterns to the modern V2 architecture while maintaining application stability and improving code quality.