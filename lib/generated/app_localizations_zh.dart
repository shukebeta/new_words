// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get loginScreenTitle => '登录 / 注册';

  @override
  String get emailLabel => '电子邮件';

  @override
  String get passwordLabel => '密码';

  @override
  String get loginButton => '登录';

  @override
  String get loginSuccessful => '登录成功';

  @override
  String get logoutButton => '退出登录';

  @override
  String get invalidCredentials => '无效的凭证';

  @override
  String get anErrorOccurred => '发生错误';

  @override
  String get pleaseEnterEmailAndPassword => '请输入电子邮件和密码';
}
