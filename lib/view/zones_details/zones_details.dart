import 'package:flutter/material.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';

class ZonesDetails extends StatelessWidget {
  const ZonesDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(
        title: 'teste',
      ),
    );
  }
}
