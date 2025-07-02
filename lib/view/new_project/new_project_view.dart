import 'package:flutter/material.dart';
import 'package:paintpro/view/widgets/appbars/app_bar_widget.dart';

class NewProjectView extends StatelessWidget {
  const NewProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'New Project'),
      body: Column(
        children: [],
      ),
    );
  }
}
