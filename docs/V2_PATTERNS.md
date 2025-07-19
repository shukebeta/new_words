# V2 Architecture Patterns & Best Practices

## Overview

This document provides detailed patterns and best practices for implementing features using the V2 architecture. All new development should follow these patterns to ensure consistency, maintainability, and reliability.

## Foundation Patterns

### Base Class Usage

#### API Layer Pattern
```dart
class MyFeatureApiV2 extends BaseApi {
  /// Constructor with optional custom Dio for testing
  MyFeatureApiV2([super.customDio]);

  /// Standard CRUD operation
  Future<ApiResponseV2<MyEntity>> createEntity(MyEntityRequest request) async {
    // 1. Validate input
    validateInput({
      'name': request.name,
      'type': request.type,
    });

    // 2. Make API call with type-safe response
    return await post<MyEntity>(
      '/my-feature/entities',
      data: request.toJson(),
      fromJson: (json) => MyEntity.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Paginated list operation
  Future<ApiResponseV2<PageData<MyEntity>>> listEntities(
    int pageNumber,
    int pageSize,
  ) async {
    // 1. Validate pagination parameters
    final paginationParams = processPaginationParams(pageNumber, pageSize);

    // 2. Make API call with pagination
    return await get<PageData<MyEntity>>(
      '/my-feature/entities',
      queryParameters: paginationParams,
      fromJson: (json) => PageData<MyEntity>.fromJson(
        json as Map<String, dynamic>,
        (entityJson) => MyEntity.fromJson(entityJson as Map<String, dynamic>),
      ),
    );
  }

  /// Void operation (no return data)
  Future<ApiResponseV2<void>> deleteEntity(int entityId) async {
    validateNumericField(entityId, 'entityId', min: 1);

    return await delete<void>('/my-feature/entities/$entityId');
  }
}
```

#### Service Layer Pattern
```dart
class MyFeatureServiceV2 extends BaseService {
  final MyFeatureApiV2 _api;
  final AppLoggerInterface _logger;

  MyFeatureServiceV2({
    required MyFeatureApiV2 api,
    AppLoggerInterface? logger,
  })  : _api = api,
        _logger = logger ?? AppLogger.instance;

  /// Business logic operation with proper error handling
  Future<MyEntity> createEntity(MyEntityRequest request) async {
    logOperation('createEntity', parameters: {
      'name': request.name,
      'type': request.type,
    });

    try {
      // 1. Business rule validation
      _validateBusinessRules(request);

      // 2. API call
      final response = await _api.createEntity(request);

      // 3. Process response
      return processResponse(response);
    } catch (e) {
      // 4. Convert to service exception
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Paginated operation
  Future<PageData<MyEntity>> listEntities(int pageNumber, int pageSize) async {
    logOperation('listEntities', parameters: {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    });

    try {
      final response = await _api.listEntities(pageNumber, pageSize);
      return processResponse(response);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Void operation
  Future<void> deleteEntity(int entityId) async {
    logOperation('deleteEntity', parameters: {'entityId': entityId});

    try {
      final response = await _api.deleteEntity(entityId);
      processVoidResponse(response);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Private business rule validation
  void _validateBusinessRules(MyEntityRequest request) {
    if (request.name.length < 2) {
      throw const ValidationException('Entity name must be at least 2 characters');
    }
    // Add more business rules as needed
  }
}
```

#### Provider Layer Pattern
```dart
class MyFeatureProvider extends AuthAwareProvider {
  final MyFeatureServiceV2 _service;

  MyFeatureProvider(this._service);

  // State variables
  List<MyEntity> _entities = [];
  List<MyEntity> get entities => _entities;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Pagination state
  int _currentPage = 1;
  int _totalCount = 0;
  final int _pageSize = AppConfig.pageSize;
  bool get canLoadMore => _entities.length < _totalCount;

  /// Load entities with standardized error handling
  Future<void> loadEntities({bool loadMore = false}) async {
    if (_isLoading) return;
    if (loadMore && !canLoadMore) return;

    // Reset pagination for refresh
    if (!loadMore) {
      _currentPage = 1;
      _entities = [];
    }

    final result = await executeWithErrorHandling<PageData<MyEntity>>(
      operation: () => _service.listEntities(_currentPage, _pageSize),
      setLoading: (loading) => _isLoading = loading,
      setError: (error) => _error = error,
      operationName: 'load entities',
    );

    if (result != null) {
      if (loadMore) {
        _entities.addAll(result.dataList);
      } else {
        _entities = result.dataList;
      }
      _totalCount = result.totalCount;
      if (result.dataList.isNotEmpty) {
        _currentPage++;
      }
    }
  }

  /// Create entity operation
  Future<MyEntity?> createEntity(MyEntityRequest request) async {
    final result = await executeWithErrorHandling<MyEntity>(
      operation: () => _service.createEntity(request),
      setLoading: (loading) => _isLoading = loading,
      setError: (error) => _error = error,
      operationName: 'create entity',
    );

    if (result != null) {
      _entities.insert(0, result);
      _totalCount++;
    }

    return result;
  }

  /// Delete entity operation
  Future<bool> deleteEntity(int entityId) async {
    final result = await executeWithErrorHandling<void>(
      operation: () => _service.deleteEntity(entityId),
      setLoading: (loading) => _isLoading = loading,
      setError: (error) => _error = error,
      operationName: 'delete entity',
    );

    if (result != null) {
      _entities.removeWhere((entity) => entity.id == entityId);
      _totalCount--;
      return true;
    }

    return false;
  }

  /// AuthAwareProvider implementation
  @override
  void clearAllData() {
    _entities = [];
    _isLoading = false;
    _error = null;
    _currentPage = 1;
    _totalCount = 0;
    notifyListeners();
  }

  @override
  Future<void> onLogin() async {
    await loadEntities();
  }
}
```

## Error Handling Patterns

### Exception Hierarchy Usage

```dart
// API Business Logic Errors
throw const ApiBusinessException(
  'Entity not found',
  backendErrorCode: 404,
);

// Network/Connection Errors
throw const NetworkException(
  'Unable to connect to server',
  statusCode: 500,
);

// Validation Errors
throw const ValidationException(
  'Invalid input: name cannot be empty',
);

// Data Processing Errors
throw const DataException(
  'Failed to parse response data',
);
```

### Provider Error Handling

```dart
// ✅ Correct: Use executeWithErrorHandling
final result = await executeWithErrorHandling<MyData>(
  operation: () => _service.getData(),
  setLoading: (loading) => _isLoading = loading,
  setError: (error) => _error = error,
  operationName: 'load data',
);

// ❌ Incorrect: Manual try-catch (avoid unless special handling needed)
try {
  _isLoading = true;
  _error = null;
  notifyListeners();
  final data = await _service.getData();
  _data = data;
} catch (e) {
  _error = e.toString();
} finally {
  _isLoading = false;
  notifyListeners();
}
```

## Validation Patterns

### Input Validation

```dart
// API Layer Validation
void validateUserInput(String email, String password) {
  validateInput({
    'email': email,
    'password': password,
  });

  validateStringField(
    email,
    'email',
    minLength: 1,
    maxLength: 254,
    pattern: RegExp(r'^[^@]+@[^@]+\.[^@]+$'),
    patternErrorMessage: 'Invalid email format',
  );

  validateStringField(
    password,
    'password',
    minLength: 8,
    maxLength: 128,
    customValidator: (value) {
      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
        return 'Password must contain at least one letter and one number';
      }
      return null;
    },
  );
}

// Numeric Validation
validateNumericField(pageSize, 'pageSize', min: 1, max: 100);

// Pagination Validation
final params = processPaginationParams(pageNumber, pageSize);
```

### Business Rule Validation

```dart
// Service Layer Business Rules
void _validateBusinessRules(CreateStoryRequest request) {
  // Rule 1: Story must have content
  if (request.content.trim().isEmpty) {
    throw const ValidationException('Story content cannot be empty');
  }

  // Rule 2: Story must have reasonable length
  if (request.content.length > 10000) {
    throw const ValidationException('Story content too long (max 10,000 characters)');
  }

  // Rule 3: Story words must be valid
  if (request.storyWords.isEmpty) {
    throw const ValidationException('Story must include at least one vocabulary word');
  }

  // Rule 4: Learning language validation
  final validLanguages = ['en', 'zh', 'es', 'fr'];
  if (!validLanguages.contains(request.learningLanguage)) {
    throw ValidationException('Unsupported learning language: ${request.learningLanguage}');
  }
}
```

## Testing Patterns

### API Layer Testing

```dart
@GenerateMocks([Dio])
void main() {
  group('MyFeatureApiV2', () {
    late MyFeatureApiV2 api;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      api = MyFeatureApiV2(mockDio);
    });

    group('createEntity', () {
      test('should create entity successfully', () async {
        // Arrange
        final request = MyEntityRequest(name: 'Test', type: 'sample');
        final mockResponse = {
          'successful': true,
          'data': {
            'id': 1,
            'name': 'Test',
            'type': 'sample',
            'createdAt': 1234567890,
          },
        };

        when(mockDio.post(
          '/my-feature/entities',
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response(
          data: mockResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await api.createEntity(request);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.name, equals('Test'));
        verify(mockDio.post(
          '/my-feature/entities',
          data: request.toJson(),
          options: anyNamed('options'),
        )).called(1);
      });

      test('should throw ValidationException for invalid input', () async {
        // Arrange
        final request = MyEntityRequest(name: '', type: 'sample');

        // Act & Assert
        expect(
          () => api.createEntity(request),
          throwsA(isA<ValidationException>()),
        );
      });
    });
  });
}
```

### Service Layer Testing

```dart
@GenerateMocks([MyFeatureApiV2, AppLoggerInterface])
void main() {
  group('MyFeatureServiceV2', () {
    late MyFeatureServiceV2 service;
    late MockMyFeatureApiV2 mockApi;
    late MockAppLoggerInterface mockLogger;

    setUp(() {
      mockApi = MockMyFeatureApiV2();
      mockLogger = MockAppLoggerInterface();
      service = MyFeatureServiceV2(api: mockApi, logger: mockLogger);
    });

    test('should create entity and return processed result', () async {
      // Arrange
      final request = MyEntityRequest(name: 'Test', type: 'sample');
      final entity = MyEntity(id: 1, name: 'Test', type: 'sample');
      final successResponse = ApiResponseV2<MyEntity>.success(entity);

      when(mockApi.createEntity(any)).thenAnswer((_) async => successResponse);

      // Act
      final result = await service.createEntity(request);

      // Assert
      expect(result, equals(entity));
      verify(mockApi.createEntity(request)).called(1);
      verify(mockLogger.d(any)).called(1);
    });

    test('should convert exceptions to ServiceException', () async {
      // Arrange
      final request = MyEntityRequest(name: 'Test', type: 'sample');
      when(mockApi.createEntity(any)).thenThrow(
        const NetworkException('Connection failed'),
      );

      // Act & Assert
      expect(
        () => service.createEntity(request),
        throwsA(isA<ServiceException>()),
      );
    });
  });
}
```

### Provider Layer Testing

```dart
@GenerateMocks([MyFeatureServiceV2])
void main() {
  group('MyFeatureProvider', () {
    late MyFeatureProvider provider;
    late MockMyFeatureServiceV2 mockService;

    setUp(() {
      mockService = MockMyFeatureServiceV2();
      provider = MyFeatureProvider(mockService);
    });

    test('should load entities successfully', () async {
      // Arrange
      final entities = [
        MyEntity(id: 1, name: 'Test1', type: 'sample'),
        MyEntity(id: 2, name: 'Test2', type: 'sample'),
      ];
      final pageData = PageData<MyEntity>(
        pageIndex: 1,
        pageSize: 20,
        totalCount: 2,
        dataList: entities,
      );

      when(mockService.listEntities(any, any))
          .thenAnswer((_) async => pageData);

      // Act
      await provider.loadEntities();

      // Assert
      expect(provider.entities, equals(entities));
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      verify(mockService.listEntities(1, 20)).called(1);
    });

    test('should handle service exceptions correctly', () async {
      // Arrange
      when(mockService.listEntities(any, any))
          .thenThrow(const ApiBusinessException('Server error'));

      // Act
      await provider.loadEntities();

      // Assert
      expect(provider.entities, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, equals('Server error'));
    });
  });
}
```

## Dependency Injection Patterns

### Registration Order

```dart
void _registerApis() {
  locator.registerLazySingleton(() => MyFeatureApiV2());
  // Register all APIs first
}

void _registerServices() {
  // Register base services (no dependencies)
  locator.registerLazySingleton(
    () => MyFeatureServiceV2(
      api: locator<MyFeatureApiV2>(),
      logger: locator<AppLoggerInterface>(),
    ),
  );
  
  // Register dependent services last
}

void _registerProviders() {
  // In main.dart MultiProvider
  ChangeNotifierProvider(
    create: (_) => MyFeatureProvider(di.locator<MyFeatureServiceV2>()),
  ),
}
```

## Performance Patterns

### Efficient State Updates

```dart
// ✅ Correct: Batch updates before notifyListeners
void updateMultipleStates(List<MyEntity> newEntities, String newFilter) {
  _entities = newEntities;
  _currentFilter = newFilter;
  _isLoading = false;
  notifyListeners(); // Single notification
}

// ❌ Incorrect: Multiple notifications
void updateMultipleStatesIncorrect(List<MyEntity> newEntities, String newFilter) {
  _entities = newEntities;
  notifyListeners(); // First notification
  _currentFilter = newFilter;
  notifyListeners(); // Second notification - causes extra rebuilds
}
```

### Memory Management

```dart
@override
void clearAllData() {
  // Clear all data structures
  _entities.clear();
  _cache.clear();
  
  // Reset all state variables
  _isLoading = false;
  _error = null;
  _currentPage = 1;
  _totalCount = 0;
  
  // Force immediate UI update
  notifyListeners();
}
```

## Common Anti-Patterns to Avoid

### ❌ Direct API Usage in Providers
```dart
// DON'T DO THIS
class BadProvider extends ChangeNotifier {
  final MyFeatureApiV2 _api; // Never inject API directly into Provider
  
  Future<void> loadData() async {
    final response = await _api.getData(); // Skips business logic layer
  }
}
```

### ❌ Manual Error Handling
```dart
// DON'T DO THIS - Use executeWithErrorHandling instead
Future<void> manualErrorHandling() async {
  try {
    _isLoading = true;
    notifyListeners(); // Easy to forget
    final data = await _service.getData();
    _data = data;
  } catch (e) {
    _error = e.toString(); // Inconsistent error formatting
  } finally {
    _isLoading = false;
    notifyListeners(); // Easy to forget
  }
}
```

### ❌ Ignoring Validation
```dart
// DON'T DO THIS
Future<ApiResponseV2<MyEntity>> createEntityBad(MyEntityRequest request) async {
  // No validation - allows invalid data to reach backend
  return await post<MyEntity>('/entities', data: request.toJson());
}
```

### ❌ Not Using Type Safety
```dart
// DON'T DO THIS
Future<dynamic> getDataBad() async {
  final response = await _dio.get('/data');
  return response.data; // No type safety
}

// DO THIS INSTEAD
Future<ApiResponseV2<MyEntity>> getDataGood() async {
  return await get<MyEntity>(
    '/data',
    fromJson: (json) => MyEntity.fromJson(json as Map<String, dynamic>),
  );
}
```

## Migration Checklist

When creating new features or migrating existing ones:

### API Layer
- [ ] Extends `BaseApi`
- [ ] Uses `ApiResponseV2<T>` return types
- [ ] Implements proper input validation
- [ ] Uses typed `fromJson` callbacks
- [ ] Handles pagination consistently

### Service Layer
- [ ] Extends `BaseService`
- [ ] Uses `processResponse()` and `processVoidResponse()`
- [ ] Implements business rule validation
- [ ] Uses structured logging with `logOperation()`
- [ ] Converts exceptions with `ServiceExceptionFactory`

### Provider Layer
- [ ] Extends `AuthAwareProvider`
- [ ] Uses `executeWithErrorHandling()` for async operations
- [ ] Implements `clearAllData()` and `onLogin()`
- [ ] Manages loading and error states consistently
- [ ] Uses dependency injection properly

### Testing
- [ ] API tests cover validation and response parsing
- [ ] Service tests cover business logic and exception handling
- [ ] Provider tests cover state management and auth lifecycle
- [ ] Achieves >90% test coverage

Following these patterns ensures consistency, maintainability, and reliability across the entire application while providing excellent developer experience and user experience.