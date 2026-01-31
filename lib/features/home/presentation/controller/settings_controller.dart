import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final RxBool is24HourFormat = false.obs;
  final RxBool isDarkMode = false.obs;
  final RxString weekStartDay = 'Monday'.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize with current theme mode
    isDarkMode.value = Get.isDarkMode;
    // TODO: Load saved week start day from local storage
  }
  
  void toggle24HourFormat(bool value) {
    is24HourFormat.value = value;
    // TODO: Save to local storage
  }
  
  void toggleThemeMode(bool value) {
    isDarkMode.value = value;
    if (value) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
    // TODO: Save to local storage
  }
  
  void setWeekStartDay(String day) {
    weekStartDay.value = day;
    // TODO: Save to local storage
  }
}
