import 'package:flutter/material.dart';
import 'package:flutter_ci_cd/home/home_binding.dart';
import 'package:flutter_ci_cd/home/home.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter CI/CD Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialBinding: HomeBinding(),
      home: const HomePage(),
    );
  }
}
