import 'package:new_words/apis/account_api_v2.dart';
import 'package:new_words/apis/user_settings_api.dart';
import 'package:new_words/apis/user_settings_api_v2.dart';
import 'package:new_words/apis/settings_api.dart';
import 'package:new_words/apis/settings_api_v2.dart';
import 'package:new_words/apis/vocabulary_api.dart';
import 'package:new_words/apis/vocabulary_api_v2.dart';
import 'package:new_words/apis/stories_api_v2.dart';
import 'package:new_words/services/account_service_v2.dart';
import 'package:get_it/get_it.dart';
import 'package:new_words/services/user_settings_service.dart';
import 'package:new_words/services/user_settings_service_v2.dart';
import 'package:new_words/services/settings_service.dart';
import 'package:new_words/services/settings_service_v2.dart';
import 'package:new_words/services/vocabulary_service.dart';
import 'package:new_words/services/vocabulary_service_v2.dart';
import 'package:new_words/services/stories_service_v2.dart';
import 'package:new_words/services/memories_service.dart';
import 'package:new_words/utils/token_utils.dart';
import 'package:new_words/utils/app_logger_interface.dart';
import 'package:new_words/utils/app_logger.dart';

final locator = GetIt.instance;

void init() {
  _registerUtils();
  _registerApis();
  _registerServices();
  _registerControllers();
}

void _registerApis() {
  locator.registerLazySingleton(() => AccountApiV2());
  locator.registerLazySingleton(() => UserSettingsApi());
  locator.registerLazySingleton(() => UserSettingsApiV2());
  locator.registerLazySingleton(() => SettingsApi());
  locator.registerLazySingleton(() => SettingsApiV2());
  locator.registerLazySingleton(() => VocabularyApi());
  locator.registerLazySingleton(() => VocabularyApiV2());
  locator.registerLazySingleton(() => StoriesApiV2());
}

void _registerServices() {
  // Register base services first (no dependencies on other services)
  locator.registerLazySingleton(
    () => UserSettingsService(userSettingsApi: locator<UserSettingsApi>()),
  );
  locator.registerLazySingleton(
    () => UserSettingsServiceV2(
      userSettingsApi: locator<UserSettingsApiV2>(),
      logger: locator<AppLoggerInterface>(),
    ),
  );
  locator.registerLazySingleton(() => SettingsService(settingsApi: locator<SettingsApi>()));
  locator.registerLazySingleton(
    () => SettingsServiceV2(
      settingsApi: locator<SettingsApiV2>(),
      logger: locator<AppLoggerInterface>(),
    ),
  );
  locator.registerLazySingleton(
    () => VocabularyService(locator<VocabularyApi>()),
  );
  locator.registerLazySingleton(
    () => VocabularyServiceV2(locator<VocabularyApiV2>()),
  );
  locator.registerLazySingleton(
    () => StoriesServiceV2(
      storiesApi: locator<StoriesApiV2>(),
      logger: locator<AppLoggerInterface>(),
    ),
  );
  locator.registerLazySingleton(
    () => MemoriesService(locator<VocabularyApi>()),
  );
  
  // Register dependent services last
  locator.registerLazySingleton(
    () => AccountServiceV2(
      accountApi: locator<AccountApiV2>(),
      userSettingsService: locator<UserSettingsServiceV2>(),
      tokenUtils: locator<TokenUtils>(),
      logger: locator<AppLoggerInterface>(),
    ),
  );
}

void _registerControllers() {}

void _registerUtils() {
  locator.registerLazySingleton(() => TokenUtils());
  locator.registerLazySingleton<AppLoggerInterface>(() => AppLogger.instance);
}
