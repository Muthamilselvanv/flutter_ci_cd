/// Values injected at compile time with `--dart-define`.
///
/// Do not put secrets here: values compiled into a mobile app can be extracted.
class AppConfig {
  const AppConfig._();

  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://gulftest.traitsolutions.in/RestApi/app_api',
  );

  static const String webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: 'https://gulftest.traitsolutions.in/RestApi/web_api/',
  );
}
