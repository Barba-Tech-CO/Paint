import 'package:flutter/material.dart';
import 'package:paintpro/config/routes.dart';
import 'package:paintpro/config/theme.dart';

void main() {
  runApp(const PaintProApp());
}

class PaintProApp extends StatelessWidget {
  const PaintProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PaintPro',
      routerConfig: router,
      theme: AppTheme.themeData,
    );
  }
}
