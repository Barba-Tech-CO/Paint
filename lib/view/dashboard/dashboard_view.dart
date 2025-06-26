import 'package:flutter/material.dart';
import 'package:paintpro/view/widgets/appbars/app_bar_widget.dart';
import 'package:paintpro/view/widgets/cards/greeting_card_widget.dart';

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
            height: 32,
          ),
          GreetingCardWidget(
            greeting: "Good morning!",
            name: "John",
          ),
        ],
      ),
    );
  }
}
