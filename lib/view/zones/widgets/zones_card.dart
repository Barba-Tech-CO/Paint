import 'package:flutter/material.dart';

class ZonesCard extends StatelessWidget {
  final String title;

  // TODO(gabriel): verificar sobre a imagem
  final String image;

  final String valueDimension;
  final String valueArea;
  final String valuePaintable;

  const ZonesCard({
    super.key,
    required this.title,
    required this.image,
    required this.valueDimension,
    required this.valueArea,
    required this.valuePaintable,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
