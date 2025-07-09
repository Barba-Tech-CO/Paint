import 'package:flutter/material.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'widgets/widgets.dart';

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
        unselectedLabelColor: Colors.white.withOpacity(0.7),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _brands
                    .map((brand) => _buildColorGrid(brand))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Generate estimate action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Generate Estimate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorGrid(String brand) {
    final List<Map<String, dynamic>> colors = [
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

    return ColorGridWidget(
      brand: brand,
      colors: colors,
      onColorTap: (colorData) {
        // Handle color selection
        print('Selected color: ${colorData['name']} for brand: $brand');
      },
    );
  }
}
