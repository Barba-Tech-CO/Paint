import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/widgets.dart';

class ZonesDetails extends StatelessWidget {
  const ZonesDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final photoUrls = [
      "https://i0.wp.com/4uprojetos.com.br/wp-content/uploads/2022/08/rolo.png?fit=747%2C747&ssl=1",
      "https://i0.wp.com/4uprojetos.com.br/wp-content/uploads/2022/08/rolo.png?fit=747%2C747&ssl=1",
      "https://i0.wp.com/4uprojetos.com.br/wp-content/uploads/2022/08/rolo.png?fit=747%2C747&ssl=1",
      "https://i0.wp.com/4uprojetos.com.br/wp-content/uploads/2022/08/rolo.png?fit=747%2C747&ssl=1",
      "https://i0.wp.com/4uprojetos.com.br/wp-content/uploads/2022/08/rolo.png?fit=747%2C747&ssl=1",
      "https://i0.wp.com/4uprojetos.com.br/wp-content/uploads/2022/08/rolo.png?fit=747%2C747&ssl=1",
      "https://i0.wp.com/4uprojetos.com.br/wp-content/uploads/2022/08/rolo.png?fit=747%2C747&ssl=1",
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaintProAppBar(
        title: 'Kitchen',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Seção Room
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Room',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RoomOverviewRowWidget(
                    leftTitle: '14 X 16',
                    leftSubtitle: 'Floor Dimensions',
                    rightTitle: '224 sq ft',
                    rightSubtitle: 'Floor Area',
                    titleColor: const Color(0xFF1A73E8),
                    subtitleColor: Colors.black54,
                    titleFontSize: 20,
                    subtitleFontSize: 13,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Seção Surface Areas usando o widget genérico
              SurfaceAreasWidget(
                surfaceData: const {
                  'Walls': '485 sq ft',
                  'Ceiling': '224 sq ft',
                  'Trim': '60 linear ft',
                },
                totalPaintableLabel: 'Total Paintable',
                totalPaintableValue: '631 sq ft',
              ),

              const SizedBox(height: 24),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Photos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      for (final url in photoUrls)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
