import 'package:flutter/material.dart';
import 'package:flutter_ci_cd/config/app_config.dart';
import 'package:flutter_ci_cd/home/home_controller.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Environment Demo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text('Environment: ${AppConfig.environment}'),
            const SizedBox(height: 12),
            const Text('API: ${AppConfig.apiBaseUrl}'),
            const SizedBox(height: 12),
            const Text('Web: ${AppConfig.webBaseUrl}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.loadAttendance,
              child: const Text('Load attendance API'),
            ),
            const SizedBox(height: 16),
            Obx(() => _buildApiState()),
          ],
        ),
      ),
    );
  }

  Widget _buildApiState() {
    switch (controller.status.value) {
      case ApiStatus.idle:
        return const Text('Press the button to call the selected API.');
      case ApiStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ApiStatus.success:
        return SelectableText(controller.responseText.value);
      case ApiStatus.error:
        return Column(
          children: [
            Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
            TextButton(
              onPressed: controller.loadAttendance,
              child: const Text('Retry'),
            ),
          ],
        );
    }
  }
}
