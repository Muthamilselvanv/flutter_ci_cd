import 'package:flutter_ci_cd/config/api_end_point.dart';
import 'package:flutter_ci_cd/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig defaults', () {
    test('uses development when no Dart define is supplied', () {
      expect(AppConfig.environment, 'development');
    });

    test('uses the expected default API URLs', () {
      expect(
        AppConfig.apiBaseUrl,
        'https://gulftest.traitsolutions.in/RestApi/app_api',
      );
      expect(
        AppConfig.webBaseUrl,
        'https://gulftest.traitsolutions.in/RestApi/web_api/',
      );
    });
  });

  group('ApiEndPoint', () {
    test('builds client information endpoint from the selected base URL', () {
      expect(
        ApiEndPoint.clientInformation,
        '${AppConfig.apiBaseUrl}/client_information.php',
      );
    });

    test('builds attendance endpoint from the selected base URL', () {
      expect(
        ApiEndPoint.attendanceList,
        '${AppConfig.apiBaseUrl}/attendance_list.php',
      );
    });
  });
}
