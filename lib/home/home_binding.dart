import 'package:flutter_ci_cd/home/home_controller.dart';
import 'package:flutter_ci_cd/services/api_service.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(ApiService.new, fenix: true);
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<ApiService>()),
      fenix: true,
    );
  }
}
