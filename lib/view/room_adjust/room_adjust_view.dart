import 'package:flutter/material.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'package:paintpro/view/widgets/cards/input_card_widget.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(title: 'Room Configuration'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              InputCardWidget(
                title: 'Elements to Paint',
                widget: Column(
                  children: elements.keys
                      .map(
                        (key) => StatefulBuilder(
                          builder: (context, setState) => CheckboxListTile(
                            value: elements[key],
                            onChanged: (val) {
                              setState(() {
                                elements[key] = val ?? false;
                              });
                            },
                            title: Text(key),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            activeColor: Colors.blue,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              InputCardWidget(
                title: 'Wall Condition',
                widget: StatefulBuilder(
                  builder: (context, setState) => Column(
                    children: [
                      RadioListTile<String>(
                        value: 'Excellent',
                        contentPadding: EdgeInsets.zero,
                        groupValue: wallCondition,
                        onChanged: (val) {
                          setState(() => wallCondition = val!);
                        },
                        title: const Text('Excellent'),
                      ),
                      RadioListTile<String>(
                        value: 'Good',
                        contentPadding: EdgeInsets.zero,
                        groupValue: wallCondition,
                        onChanged: (val) {
                          setState(() => wallCondition = val!);
                        },
                        title: const Text('Good'),
                      ),
                      RadioListTile<String>(
                        value: 'Fair',
                        contentPadding: EdgeInsets.zero,
                        groupValue: wallCondition,
                        onChanged: (val) {
                          setState(() => wallCondition = val!);
                        },
                        title: const Text('Fair'),
                      ),
                      RadioListTile<String>(
                        value: 'Poor',
                        contentPadding: EdgeInsets.zero,
                        groupValue: wallCondition,
                        onChanged: (val) {
                          setState(() => wallCondition = val!);
                        },
                        title: const Text('Poor'),
                      ),
                    ],
                  ),
                ),
              ),

              InputCardWidget(
                title: 'Accent Wall',
                widget: StatefulBuilder(
                  builder: (context, setState) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Include accent wall'),
                      Switch(
                        value: accentWall,
                        onChanged: (val) {
                          setState(() => accentWall = val);
                        },
                      ),
                    ],
                  ),
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

              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Futura tela
                    // context.push('/camera');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Project',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
