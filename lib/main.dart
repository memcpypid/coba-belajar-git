import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    GetMaterialApp(
      title: "Todo List - GetX",
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}

ThemeData _darkTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF0F0F1A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6C63FF),
      secondary: Color(0xFF48C6EF),
      surface: Color(0xFF1A1A2E),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1A1A2E),
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

ThemeData _lightTheme() {
  return ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFF2F2FF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6C63FF),
      secondary: Color(0xFF48C6EF),
      surface: Color(0xFFFFFFFF),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFFFFFFFF),
      contentTextStyle: const TextStyle(color: Color(0xFF1A1A2E)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
