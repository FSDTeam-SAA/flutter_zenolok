import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      Text('Eshita', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.white),),
          ElevatedButton(onPressed: (){
            Get.find<AuthController>().logout();
          }, child: Text('Log out'))
        ],
      ),
    ));
  }
}
