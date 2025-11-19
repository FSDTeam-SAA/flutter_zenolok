import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DifferentLoginApproach extends StatelessWidget {
  const DifferentLoginApproach({
    super.key, required this.text, required this.image,
  });

  final String text;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.googleBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              width: 24,
              height: 24,
              image: AssetImage(image),
            ),
            SizedBox(width: 12,),
            Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.white, fontSize: 16),)
          ],
        ),
      ),
    );
  }
}