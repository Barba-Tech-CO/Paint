import 'package:flutter/material.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';

class SelectMaterialView extends StatefulWidget {
  const SelectMaterialView({super.key});

  @override
  State<SelectMaterialView> createState() => _SelectMaterialViewState();
}

class _SelectMaterialViewState extends State<SelectMaterialView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(title: 'Select Materials'),
    );
  }
}
