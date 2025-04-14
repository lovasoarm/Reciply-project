import 'package:flutter/material.dart';
import 'routes.dart';
import '../core/constants/app_colors.dart';

class ReciplyApp extends StatelessWidget {
  const ReciplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reciply',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
