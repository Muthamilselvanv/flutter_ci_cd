import 'dart:async';

import 'package:flutter_ci_cd/config/api_end_point.dart';
import 'package:flutter_ci_cd/core/errors/api_exception.dart';
import 'package:get/get.dart';

class ApiService extends GetxService {
  final GetConnect _client = GetConnect(timeout: const Duration(seconds: 15));

  Future<dynamic> getAttendanceList() async {
    final response = await _client.get<dynamic>(ApiEndPoint.attendanceList);

    if (!response.isOk) {
      throw ApiException(
        response.statusText ?? 'The server returned an error.',
        statusCode: response.statusCode,
      );
    }

    if (response.body == null) {
      throw const ApiException('The server returned an empty response.');
    }

    return response.body;
  }
}
