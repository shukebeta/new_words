import 'package:flutter_test/flutter_test.dart';
import 'package:new_words/providers/provider_base.dart';

class MockAuthAwareProvider extends AuthAwareProvider {
  final List<String> _data = [];
  List<String> get data => _data;

  bool _onLoginCalled = false;
  bool _onLogoutCalled = false;
  bool _clearAllDataCalled = false;
  final List<String> _operationOrder = [];

  bool get onLoginCalled => _onLoginCalled;
  bool get onLogoutCalled => _onLogoutCalled;
  bool get clearAllDataCalled => _clearAllDataCalled;
  List<String> get operationOrder => _operationOrder;

  @override
  void clearAllData() {
    _clearAllDataCalled = true;
    _operationOrder.add('clearAllData');
    _data.clear();
    notifyListeners();
  }

  @override
  Future<void> onLogin() async {
    _onLoginCalled = true;
    _operationOrder.add('onLogin');
    _data.add('login_data');
    notifyListeners();
  }

  @override
  Future<void> onLogout() async {
    _onLogoutCalled = true;
    await super.onLogout(); // This calls clearAllData
  }

  void addData(String item) {
    _data.add(item);
    notifyListeners();
  }

  void resetForTesting() {
    _onLoginCalled = false;
    _onLogoutCalled = false;
    _clearAllDataCalled = false;
    _operationOrder.clear();
  }
}

void main() {
  group('AuthAwareProvider', () {
    late MockAuthAwareProvider provider;

    setUp(() {
      provider = MockAuthAwareProvider();
    });

    test('should initialize with empty state', () {
      expect(provider.data, isEmpty);
      expect(provider.isAuthStateInitialized, false);
      expect(provider.onLoginCalled, false);
      expect(provider.onLogoutCalled, false);
      expect(provider.clearAllDataCalled, false);
      expect(provider.operationOrder, isEmpty);
    });

    test(
      'should call onLogin when auth state changes to authenticated',
      () async {
        await provider.onAuthStateChanged(true);

        expect(provider.onLoginCalled, true);
        expect(provider.isAuthStateInitialized, true);
        expect(provider.data, contains('login_data'));
      },
    );

    test(
      'should call onLogin every time auth state changes to true (prevents data leakage)',
      () async {
        await provider.onAuthStateChanged(true);
        provider.resetForTesting(); // Reset for testing

        await provider.onAuthStateChanged(true);

        expect(
          provider.onLoginCalled,
          true,
        ); // Should be called again to ensure clean state
      },
    );

    test(
      'should call onLogout when auth state changes to unauthenticated',
      () async {
        // First authenticate
        await provider.onAuthStateChanged(true);
        provider.addData('test_data');

        // Then logout
        await provider.onAuthStateChanged(false);

        expect(provider.onLogoutCalled, true);
        expect(provider.isAuthStateInitialized, false);
        expect(provider.data, isEmpty); // Data should be cleared
      },
    );

    test('should not call onLogout if not previously authenticated', () async {
      await provider.onAuthStateChanged(false);

      expect(provider.onLogoutCalled, false);
    });

    test('should clear all data when clearAllData is called', () {
      provider.addData('test1');
      provider.addData('test2');

      provider.clearAllData();

      expect(provider.data, isEmpty);
    });

    test('should reset auth state when resetAuthState is called', () async {
      await provider.onAuthStateChanged(true);

      provider.resetAuthState();

      expect(provider.isAuthStateInitialized, false);
    });

    test('should handle rapid auth state changes correctly', () async {
      await provider.onAuthStateChanged(true);
      await provider.onAuthStateChanged(false);
      await provider.onAuthStateChanged(true);

      expect(provider.isAuthStateInitialized, true);
      expect(provider.data, contains('login_data'));
    });

    test(
      'should clear data on every login to prevent user data leakage',
      () async {
        // Simulate User A login
        await provider.onAuthStateChanged(true);
        provider.addData('user_a_data');

        // User A logout
        await provider.onAuthStateChanged(false);

        // User B login - should start with clean state
        await provider.onAuthStateChanged(true);

        // Data should be cleared and only contain login data
        expect(provider.data, ['login_data']);
        expect(provider.data, isNot(contains('user_a_data')));
      },
    );

    test('should call onLogin on every auth state change to true', () async {
      // First login
      await provider.onAuthStateChanged(true);
      expect(provider.onLoginCalled, true);

      // Reset flag
      provider.resetForTesting();

      // Logout
      await provider.onAuthStateChanged(false);

      // Second login should call onLogin again
      await provider.onAuthStateChanged(true);
      expect(provider.onLoginCalled, true);
    });

    test(
      'should call onLogin when auth state changes to true (clearAllData called separately by AppStateProvider)',
      () async {
        // Add some data first
        provider.addData('existing_data');

        // Simulate AppStateProvider behavior: call clearAllData first
        provider.clearAllData();

        // Then call onAuthStateChanged(true) which should call onLogin
        await provider.onAuthStateChanged(true);

        // Verify operation order (clearAllData was called manually, then onLogin by onAuthStateChanged)
        expect(provider.operationOrder, ['clearAllData', 'onLogin']);
        expect(provider.clearAllDataCalled, true);
        expect(provider.onLoginCalled, true);
        // Data should only contain login data, not the existing data
        expect(provider.data, ['login_data']);
      },
    );

    test(
      'should simulate complete AppStateProvider workflow for data isolation',
      () async {
        // Simulate User A session
        provider.clearAllData(); // AppStateProvider clears data
        await provider.onAuthStateChanged(true); // User A logs in
        provider.addData('user_a_data'); // User A adds data

        // Simulate logout
        await provider.onAuthStateChanged(false);

        // Simulate User B session
        provider.resetForTesting(); // Reset test flags
        provider.clearAllData(); // AppStateProvider clears data
        await provider.onAuthStateChanged(true); // User B logs in

        // Verify User B has clean state
        expect(provider.data, ['login_data']); // Only fresh login data
        expect(provider.data, isNot(contains('user_a_data'))); // No User A data
        expect(provider.onLoginCalled, true); // onLogin was called for User B
      },
    );
  });
}
