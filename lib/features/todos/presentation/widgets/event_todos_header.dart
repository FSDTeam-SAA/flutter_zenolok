import 'package:flutter/material.dart';
import 'package:flutter_zenolok/features/home/presentation/screens/setting_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../core/common/constants/app_images.dart';


class EventTodosHeader extends StatelessWidget {
  const EventTodosHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Todos',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              letterSpacing: 0.2,
            ),
          ),
        ),

        _HeaderIconButton(
          asset: AppImages.iconsearch,
          onPressed: () {
            // Get.to(() => const SearchScreen());
          },
        ),
        const SizedBox(width: 2),

        _HeaderIconButton(
          asset: AppImages.iconnotification,
          onPressed: () {
            // Get.to(() => const NotificationsScreen());
          },
        ),
        const SizedBox(width: 2),

        _HeaderIconButton(
          asset: AppImages.iconsetting,
          onPressed: () {
            Get.to(() => const SettingsScreen());
          },
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final String asset;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.asset,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      // padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Image.asset(
        asset,
        width: 28,
        height: 28,
        fit: BoxFit.contain,
      ),
    );
  }
}
