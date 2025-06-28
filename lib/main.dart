import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/config/routes.dart';
import 'package:paintpro/config/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PaintPro',
      routerConfig: router,
      theme: AppTheme.themeData,
    );
  }
}
