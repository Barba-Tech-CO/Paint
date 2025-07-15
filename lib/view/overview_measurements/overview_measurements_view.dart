import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/view/widgets/widgets.dart';

class OverviewMeasurementsView extends StatelessWidget {
  const OverviewMeasurementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(
        title: 'Measurements',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Project Summary Card
              ProjectSummaryCardWidget(
                title: 'Project Summary',
                children: const [
                  SummaryInfoRowWidget(
                    label: 'Total Area',
                    value: '631 sq ft',
                  ),
                  SummaryInfoRowWidget(
                    label: 'Rooms',
                    value: 'Living Room',
                  ),
                  SummaryInfoRowWidget(
                    label: 'Paint Type',
                    value: 'Interior Eggshell',
                  ),
                ],
              ),

              // Materials Card
              ProjectSummaryCardWidget(
                title: 'Materials',
                children: const [
                  MaterialItemRowWidget(
                    title: 'Walls',
                    subtitle: '2.1 gallons x \$52.99',
                    price: '\$111.28',
                  ),
                  MaterialItemRowWidget(
                    title: 'Primer',
                    subtitle: '1.2 gallons x \$38.99',
                    price: '\$46.79',
                  ),
                  MaterialItemRowWidget(
                    title: 'Supplies',
                    subtitle: 'Brushes, rollers, drop cloths',
                    price: '\$45.00',
                  ),
                  SummaryTotalRowWidget(
                    label: 'Materials Total:',
                    value: '\$203.07',
                  ),
                ],
              ),

              ProjectSummaryCardWidget(
                title: 'Labor',
                children: const [
                  MaterialItemRowWidget(
                    title: 'Prep Work',
                    subtitle: 'Painting',
                    price: '\$180.00',
                  ),
                  MaterialItemRowWidget(
                    title: 'Painting',
                    subtitle: '8 hours x \$45/hr',
                    price: '\$360.00',
                  ),
                  MaterialItemRowWidget(
                    title: 'Cleanup',
                    subtitle: '1 hours x \45/hr',
                    price: '\$45.00',
                  ),
                  SummaryTotalRowWidget(
                    label: 'Materials Total:',
                    value: '\$203.07',
                  ),
                ],
              ),

              // Room Overview Card
              ProjectSummaryCardWidget(
                title: 'Room Overview',
                children: const [
                  RoomOverviewRowWidget(
                    leftTitle: '14 X 16',
                    leftSubtitle: 'Floor Dimensions',
                    rightTitle: '224 sq ft',
                    rightSubtitle: 'Floor Area',
                  ),
                ],
              ),

              // Total Project Cost Card
              ProjectSummaryCardWidget(
                children: const [
                  ProjectCostSummaryWidget(
                    title: 'Total Project Cost',
                    cost: '\$585.00',
                    timeline: 'Timeline: 2-3 days',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Adjust'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.push('/room-configuration'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
