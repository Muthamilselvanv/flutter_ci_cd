import 'dart:async';
import 'package:flutter_ci_cd/core/errors/api_exception.dart';
import 'package:flutter_ci_cd/home/home_controller.dart';
import 'package:flutter_ci_cd/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _SuccessfulApiService extends ApiService {
  @override
  Future<dynamic> getAttendanceList() async {
    return <String, dynamic>{'success': true};
  }
}

class _ApiErrorService extends ApiService {
  @override
  Future<dynamic> getAttendanceList() async {
    throw const ApiException('Internal server error', statusCode: 500);
  }
}

class _TimeoutApiService extends ApiService {
  @override
  Future<dynamic> getAttendanceList() async {
    throw TimeoutException('Request timed out');
  }
}

void main() {
  test('starts in the idle state', () {
    final controller = HomeController(_SuccessfulApiService());

    expect(controller.status.value, ApiStatus.idle);
    expect(controller.responseText.value, isEmpty);
    expect(controller.errorMessage.value, isEmpty);
  });

  test('stores formatted data after a successful response', () async {
    final controller = HomeController(_SuccessfulApiService());

    await controller.loadAttendance();

    expect(controller.status.value, ApiStatus.success);
    expect(controller.responseText.value, contains('"success": true'));
    expect(controller.errorMessage.value, isEmpty);
  });

  test('exposes the status code and message after an API error', () async {
    final controller = HomeController(_ApiErrorService());

    await controller.loadAttendance();

    expect(controller.status.value, ApiStatus.error);
    expect(
      controller.errorMessage.value,
      'Request failed (500): Internal server error',
    );
  });

  test('exposes a helpful message after a timeout', () async {
    final controller = HomeController(_TimeoutApiService());

    await controller.loadAttendance();

    expect(controller.status.value, ApiStatus.error);
    expect(
      controller.errorMessage.value,
      'The request timed out. Please try again.',
    );
  });
}
