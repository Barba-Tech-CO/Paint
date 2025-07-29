import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/widgets.dart';

class ZonesDetails extends StatelessWidget {
  const ZonesDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaintProAppBar(
        title: 'teste',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Room',
                    textAlign: TextAlign.left,
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
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Seção Surface Areas usando SurfaceAreasWidget
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Surface Areas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSurfaceRow('Walls', '485 sq ft'),
                    const SizedBox(height: 12),
                    _buildSurfaceRow('Ceiling', '224 sq ft'),
                    const SizedBox(height: 12),
                    _buildSurfaceRow('Trim', '60 linear ft'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Total Paintable',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          '631 sq ft',
                          style: TextStyle(
                            color: Color(0xFF1A73E8),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurfaceRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
