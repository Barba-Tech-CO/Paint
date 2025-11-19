import 'package:flutter/material.dart';

import '../../viewmodel/zones/zones_list_viewmodel.dart';

class ZonesLoadingWidget extends StatelessWidget {
  final ZonesListViewModel listViewModel;

  const ZonesLoadingWidget({
    super.key,
    required this.listViewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (listViewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (listViewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${listViewModel.errorMessage}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => listViewModel.refresh(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
