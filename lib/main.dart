import 'package:flutter/material.dart';
import 'package:flutter_zenolok/features/auth/presentation/screens/splash_screen.dart';
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
      home: const SplashScreen(),
    );
  }
}
// //
// // //------------------------------------------


// import 'package:flutter/material.dart';
// import 'package:flutter_zenolok/features/auth/presentation/screens/login_screen.dart';

// void main() => runApp(const CalendarApp());

// class CalendarApp extends StatelessWidget {
//   const CalendarApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final scheme = ColorScheme.fromSeed(
//       seedColor: const Color(0xFF3AA1FF),
//       brightness: Brightness.light,
//     ).copyWith(
//       surface: Colors.white,
//       background: Colors.white,
//       onSurface: Colors.black,
//       onBackground: Colors.black,
//     );

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Calendar',
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: scheme,
//         scaffoldBackgroundColor: Colors.white,
//         dialogBackgroundColor: Colors.white,
//         cardColor: Colors.white,
//         canvasColor: Colors.white,
//       ),
//       home:  LoginScreen(),
//     );
//   }
// }

