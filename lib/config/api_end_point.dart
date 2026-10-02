import 'package:flutter_ci_cd/config/app_config.dart';

class ApiEndPoint {
  const ApiEndPoint._();

  static const String baseUrl = AppConfig.apiBaseUrl;
  static const String webUrl = AppConfig.webBaseUrl;

  static const String clientInformation = '$baseUrl/client_information.php';
  static const String attendanceList = '$baseUrl/attendance_list.php';
}
