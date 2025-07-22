import 'package:flutter/material.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'package:paintpro/view/widgets/buttons/paint_pro_button.dart';
import 'widgets/color_grid_widget.dart';

class SelectColorsView extends StatefulWidget {
  const SelectColorsView({super.key});

  @override
  State<SelectColorsView> createState() => _SelectColorsViewState();
}

class _SelectColorsViewState extends State<SelectColorsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _brands = [
    'Sherwin-Williams',
    'Benjamin Moore',
    'Behr',
    'PP',
  ];

  // Lista de cores para cada marca
  final List<Map<String, dynamic>> _colors = [
    {
      'name': 'White',
      'code': 'SW6232',
      'price': '\$52.99/Gal',
      'color': Colors.grey[200],
    },
    {
      'name': 'Gray',
      'code': 'SW6233',
      'price': '\$51.99/Gal',
      'color': Colors.grey[500],
    },
    {
      'name': 'White Pink',
      'code': 'SW6235',
      'price': '\$46.99/Gal',
      'color': Colors.pink[100],
    },
    {
      'name': 'Pink',
      'code': 'SW6238',
      'price': '\$48.99/Gal',
      'color': Colors.pink[300],
    },
    {
      'name': 'Green',
      'code': 'SW6232',
      'price': '\$32.99/Gal',
      'color': Colors.lightGreen[300],
    },
    {
      'name': 'Aqua',
      'code': 'SW6232',
      'price': '\$52.99/Gal',
      'color': Colors.cyan[200],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _brands.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(
        title: 'Select Colors',
        tabs: _brands.map((brand) => Tab(text: brand)).toList(),
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        toolbarHeight: 60,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _brands
                    .map(
                      (brand) => ColorGridWidget(
                        brand: brand,
                        colors: _colors,
                        onColorTap: (colorData) {
                          // Cor selecionada
                          print(
                            'Selected color: ${colorData['name']} for brand: $brand',
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            PaintProButton(
              text: 'Generate Estimate',
              onPressed: () {
                // Generate estimate action
              },
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              borderRadius: 16,
            ),
          ],
        ),
      ),
    );
  }
}
