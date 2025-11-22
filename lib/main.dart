import 'package:flutter/material.dart';
import 'package:flutter_zenolok/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_zenolok/features/event_todos/presentation/screens/event_todos_screen.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'core/init/app_initializer.dart';
import 'core/theme/app_theme.dart';

void main() async {
  await AppInitializer.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Zenelok',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: EventTodosScreen(),
    );
  }
}
