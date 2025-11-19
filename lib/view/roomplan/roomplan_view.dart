import 'dart:async';

import 'package:flutter/material.dart';
import 'package:roomplan_flutter/roomplan_flutter.dart';

import '../../config/dependency_injection.dart';
import '../../viewmodel/roomplan/roomplan_viewmodel.dart';

class RoomPlanView extends StatefulWidget {
  final List<String> capturedPhotos;
  final Map<String, dynamic>? projectData;

  const RoomPlanView({
    super.key,
    required this.capturedPhotos,
    this.projectData,
  });

  @override
  State<RoomPlanView> createState() => _RoomPlanViewState();
}

class _RoomPlanViewState extends State<RoomPlanView> {
  late RoomPlanViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<RoomPlanViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    _initializeRoomPlan();
  }

  Future<void> _initializeRoomPlan() async {
    await _viewModel.checkSupport();

    // If supported, start scanning automatically
    if (_viewModel.isSupported) {
      _startRoomPlan();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startRoomPlan() async {
    try {
      await _viewModel.startScanning();

      // Wait for scan completion
      while (_viewModel.isScanning) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final result = _viewModel.scanResult;
      if (result != null) {
        final roomData = _viewModel.processScanResult(
          result,
          widget.capturedPhotos,
          widget.projectData,
        );
        _viewModel.navigateToProcessing(
          context,
          roomData,
          widget.capturedPhotos,
          widget.projectData,
        );
      } else {}
    } on RoomPlanPermissionsException {
      _viewModel.showErrorDialog(
        context,
        'Camera permission denied. Please grant camera access in Settings.',
      );
    } on ScanCancelledException {
    } catch (e) {
      // Handle specific world tracking failure
      if (e.toString().contains('World tracking failure') ||
          e.toString().contains('native_error')) {
        _viewModel.showWorldTrackingErrorDialog(context, () {
          _viewModel.navigateToProcessingWithPhotosOnly(
            context,
            widget.capturedPhotos,
            widget.projectData,
          );
        });
      } else {
        _viewModel.showErrorDialog(context, 'RoomPlan failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se não é suportado, mostra apenas o dialog de incompatibilidade
    if (!_viewModel.isSupported) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Se está escaneando, mostra loading
    if (_viewModel.isScanning) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Se não está escaneando, mostra tela vazia
    // O scanner nativo do iOS será exibido automaticamente quando startScanning() for chamado
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'RoomPlan Scanner',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
