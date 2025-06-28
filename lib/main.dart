import 'package:flutter/material.dart';
import 'package:paintpro/config/routes.dart';
import 'package:paintpro/config/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
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
