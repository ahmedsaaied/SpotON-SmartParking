// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:flutter/material.dart';

// class ThemeController extends GetxController {
//   final RxBool isDarkMode = false.obs;
//   final _box = GetStorage();

//   @override
//   void onInit() {
//     super.onInit();
//     isDarkMode.value = _box.read('isDarkMode') ?? false;
//     // Immediately apply the stored theme
//     Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
//   }

//   void toggleTheme() {
//     isDarkMode.value = !isDarkMode.value;
//     _applyTheme();
//   }

//   void setTheme(bool isDark) {
//     isDarkMode.value = isDark;
//     _applyTheme();
//   }

//   void _applyTheme() {
//     final mode = isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
//     Get.changeThemeMode(mode);
//     _box.write('isDarkMode', isDarkMode.value);
//   }
// }
