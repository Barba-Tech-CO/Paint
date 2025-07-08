import 'package:flutter/material.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';

class SelectColorsView extends StatelessWidget {
  const SelectColorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(title: 'Select Colors'),
    );
  }
}
