import 'package:flutter/material.dart';
import 'package:paintpro/view/widgets/app_bar_paint_widget.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPaintWidget(title: 'Dashboard'),
      body: const Center(
        child: Text('Welcome to the Dashboard!'),
      ),
    );
  }
}
