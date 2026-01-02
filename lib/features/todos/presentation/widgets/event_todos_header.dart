import 'package:flutter/material.dart';

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

        _HeaderIconButton(asset: AppImages.iconsearch),
        const SizedBox(width: 2),

        _HeaderIconButton(asset: AppImages.iconnotification),
        const SizedBox(width: 2),

        _HeaderIconButton(asset: AppImages.iconsetting),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final String asset;

  const _HeaderIconButton({required this.asset});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      // padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Image.asset(
        asset,
        width: 28,
        height: 28   ,
        fit: BoxFit.contain,
      ),
    );
  }
}
