import 'package:flutter/material.dart';
import 'package:paintpro/view/widgets/appbars/app_bar_widget.dart';
import 'package:paintpro/view/widgets/cards/greeting_card_widget.dart';
import 'package:paintpro/view/widgets/cards/stats_card_widget.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'Dashboard'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 32,
        children: [
          SizedBox(
            height: 8,
          ),
          GreetingCardWidget(
            greeting: "Good morning!",
            name: "John",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatsCardWidget(
                        title: "2",
                        description: "active projects",
                      ),
                      StatsCardWidget(
                        title: "\$30,050",
                        description: "this month",
                        backgroundColor: Color(0xFF2D2D2D),
                        titleColor: Color(0xFF4CAF50),
                        descriptionColor: Colors.white70,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatsCardWidget(
                        title: "6",
                        description: "completed",
                      ),
                      StatsCardWidget(
                        title: "85%",
                        description: "conversion",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
