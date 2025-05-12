// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginScreenTitle => 'Login / Register';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginSuccessful => 'Login Successful';

  @override
  String get logoutButton => 'Logout';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get pleaseEnterEmailAndPassword => 'Please enter email and password';
}
