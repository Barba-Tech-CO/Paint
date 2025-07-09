import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'package:paintpro/view/widgets/cards/input_card_widget.dart';
import 'package:paintpro/view/widgets/buttons/primary_button_widget.dart';
import 'widgets/widgets.dart';

class RoomAdjustView extends StatefulWidget {
  const RoomAdjustView({super.key});

  @override
  State<RoomAdjustView> createState() => _RoomAdjustViewState();
}

class _RoomAdjustViewState extends State<RoomAdjustView> {
  late final TextEditingController notesController;

  final Map<String, bool> elements = {
    'Walls': true,
    'Ceiling': true,
    'Trim': true,
    'Doors': false,
    'Windows': false,
  };

  String wallCondition = 'Good';
  bool accentWall = false;

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController();
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(title: 'Room Adjust', toolbarHeight: 80),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              InputCardWidget(
                title: 'Elements to Paint',
                widget: ElementsToPaintWidget(
                  elements: elements,
                  onElementChanged: (key, value) {
                    setState(() {
                      elements[key] = value;
                    });
                  },
                ),
              ),

              InputCardWidget(
                title: 'Wall Condition',
                widget: WallConditionWidget(
                  wallCondition: wallCondition,
                  onConditionChanged: (condition) {
                    setState(() {
                      wallCondition = condition;
                    });
                  },
                ),
              ),

              InputCardWidget(
                title: 'Accent Wall',
                widget: AccentWallWidget(
                  accentWall: accentWall,
                  onAccentWallChanged: (value) {
                    setState(() {
                      accentWall = value;
                    });
                  },
                ),
              ),

              InputCardWidget(
                title: 'Notes',
                controller: notesController,
                hintText: 'Any special requirements or notes...',
                multiline: true,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              PrimaryButtonWidget(
                text: 'Create Project',
                onPressed: () => context.push('/select-colors'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
