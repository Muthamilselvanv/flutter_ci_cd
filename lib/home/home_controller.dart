import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_ci_cd/core/errors/api_exception.dart';
import 'package:flutter_ci_cd/services/api_service.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/exceptions/exceptions.dart';

enum ApiStatus { idle, loading, success, error }

class HomeController extends GetxController {
  HomeController(this._apiService);

  final ApiService _apiService;

  final status = ApiStatus.idle.obs;
  final responseText = ''.obs;
  final errorMessage = ''.obs;

  Future<void> loadAttendance() async {
    status.value = ApiStatus.loading;
    errorMessage.value = '';

    try {
      final data = await _apiService.getAttendanceList();
      responseText.value = const JsonEncoder.withIndent('  ').convert(data);
      status.value = ApiStatus.success;
    } on ApiException catch (error) {
      final code = error.statusCode;
      errorMessage.value = code == null
          ? error.message
          : 'Request failed ($code): ${error.message}';
      status.value = ApiStatus.error;
    } on TimeoutException {
      errorMessage.value = 'The request timed out. Please try again.';
      status.value = ApiStatus.error;
    } on SocketException {
      errorMessage.value = 'No internet connection.';
      status.value = ApiStatus.error;
    } on GetHttpException catch (error) {
      errorMessage.value = 'Network error: ${error.message}';
      status.value = ApiStatus.error;
    } on FormatException {
      errorMessage.value = 'The server returned invalid data.';
      status.value = ApiStatus.error;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
      status.value = ApiStatus.error;
    }
  }
}
