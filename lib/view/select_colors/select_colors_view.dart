import 'package:flutter/material.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';

class SelectColorsView extends StatefulWidget {
  const SelectColorsView({super.key});

  @override
  State<SelectColorsView> createState() => _SelectColorsViewState();
}

class _SelectColorsViewState extends State<SelectColorsView> {
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(
        title: 'Select Colors',
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
