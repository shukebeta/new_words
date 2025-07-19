import 'package:new_words/apis/account_api.dart';
import 'package:new_words/apis/user_settings_api.dart';
import 'package:new_words/apis/settings_api.dart';
import 'package:new_words/apis/vocabulary_api.dart';
import 'package:new_words/apis/vocabulary_api_v2.dart';
import 'package:new_words/apis/stories_api.dart';
import 'package:new_words/services/account_service.dart';
import 'package:get_it/get_it.dart';
import 'package:new_words/services/user_settings_service.dart';
import 'package:new_words/services/settings_service.dart';
import 'package:new_words/services/vocabulary_service.dart';
import 'package:new_words/services/vocabulary_service_v2.dart';
import 'package:new_words/services/stories_service.dart';
import 'package:new_words/services/memories_service.dart';
import 'package:new_words/utils/token_utils.dart';

final locator = GetIt.instance;

void init() {
  _registerApis();
  _registerServices();
  _registerControllers();
  _registerUtils();
}

void _registerApis() {
  locator.registerLazySingleton(() => AccountApi());
  locator.registerLazySingleton(() => UserSettingsApi());
  locator.registerLazySingleton(() => SettingsApi());
  locator.registerLazySingleton(() => VocabularyApi());
  locator.registerLazySingleton(() => VocabularyApiV2());
  locator.registerLazySingleton(() => StoriesApi());
}

void _registerServices() {
  locator.registerLazySingleton(
    () => AccountService(
      accountApi: locator(),
      userSettingsService: locator(),
      tokenUtils: locator(),
    ),
  );
  locator.registerLazySingleton(
    () => UserSettingsService(userSettingsApi: locator()),
  );
  locator.registerLazySingleton(() => SettingsService(settingsApi: locator()));
  locator.registerLazySingleton(
    () => VocabularyService(locator<VocabularyApi>()),
  );
  locator.registerLazySingleton(
    () => VocabularyServiceV2(locator<VocabularyApiV2>()),
  );
  locator.registerLazySingleton(() => StoriesService(locator<StoriesApi>()));
  locator.registerLazySingleton(
    () => MemoriesService(locator<VocabularyApi>()),
  );
}

void _registerControllers() {}

void _registerUtils() {
  locator.registerLazySingleton(() => TokenUtils());
}
