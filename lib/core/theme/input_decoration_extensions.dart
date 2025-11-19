import 'package:flutter/material.dart';
import 'package:flutx_core/flutx_core.dart';

import 'app_colors.dart';

extension InputDecorationExtensions on BuildContext {
  InputDecoration get primaryInputDecoration => InputDecoration(
    filled: true,
    suffixIconColor: AppColors.textFieldTextiHint,
    fillColor: AppColors.textFieldBackground,
    contentPadding: AppSizes.paddingMd.all,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.paddingSm.size),
      borderSide: BorderSide(color: AppColors.textFieldBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.paddingSm.size),
      borderSide: BorderSide(color: AppColors.textFieldBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.paddingSm.size),
      borderSide: BorderSide(color: AppColors.textFieldBorder, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.paddingSm.size),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.paddingSm.size),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    hintStyle: TextStyle(
      color: AppColors.textFieldTextiHint,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: TextStyle(
      color: AppColors.buttonText,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    errorStyle: const TextStyle(
      color: AppColors.error,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  );
}
