import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/app_colors.dart';
import '../../service/camera_initialization_service.dart';
import '../../widgets/appbars/camera_app_bar.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _useImagePicker = false;
  int _photoCount = 0;
  final List<XFile> _capturedPhotos = [];
  final int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;
  final ImagePicker _imagePicker = ImagePicker();
  bool get _isDoneEnabled => _photoCount >= 3;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      log('CameraView: Using CameraInitializationService...');

      // Check if service is already initialized
      if (!CameraInitializationService.isInitialized) {
        log('CameraView: Camera service not initialized, initializing now...');
        await CameraInitializationService.initialize();
      }

      // Check if we're on simulator or cameras are unavailable
      if (CameraInitializationService.isSimulator ||
          !CameraInitializationService.isCameraAvailable) {
        log('CameraView: Camera not available, using image picker fallback');
        setState(() {
          _useImagePicker = true;
          _isInitialized = true;
        });
        return;
      }

      // Get cameras from the service
      _cameras = CameraInitializationService.cameras;

      if (_cameras != null && _cameras!.isNotEmpty) {
        log('CameraView: Found ${_cameras!.length} cameras from service');
        await _initializeCameraController();
      } else {
        log('CameraView: No cameras available, switching to image picker');
        setState(() {
          _useImagePicker = true;
          _isInitialized = true;
        });
      }
    } catch (e) {
      log(
        'CameraView: Error initializing camera: $e, switching to image picker',
      );
      setState(() {
        _useImagePicker = true;
        _isInitialized = true;
      });
    }
  }

  Future<void> _initializeCameraController() async {
    try {
      if (_cameraController != null) {
        await _cameraController!.dispose();
      }

      if (_cameras == null || _cameras!.isEmpty) {
        log('CameraView: No cameras available for controller initialization');
        _showCameraUnavailableDialog();
        return;
      }

      _cameraController = CameraController(
        _cameras![_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        log('CameraView: Camera controller initialized successfully');
      }
    } catch (e) {
      log('CameraView: Error initializing camera controller: $e');
      if (mounted) {
        _showCameraUnavailableDialog();
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      setState(() {
        _flashMode = _flashMode == FlashMode.off
            ? FlashMode.auto
            : FlashMode.off;
      });
      await _cameraController!.setFlashMode(_flashMode);
    }
  }

  Future<void> _takePhoto() async {
    if (_useImagePicker) {
      await _takePhotoFromImagePicker();
    } else if (_cameraController != null &&
        _cameraController!.value.isInitialized) {
      try {
        final XFile photo = await _cameraController!.takePicture();
        setState(() {
          _capturedPhotos.add(photo);
          _photoCount++;
        });
      } catch (e) {
        log('Error taking photo: $e');
        // Fallback to image picker if camera fails
        await _takePhotoFromImagePicker();
      }
    } else {
      await _takePhotoFromImagePicker();
    }
  }

  Future<void> _takePhotoFromImagePicker() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _capturedPhotos.add(photo);
          _photoCount++;
        });
      }
    } catch (e) {
      log('Error taking photo with image picker: $e');
      // Try gallery as final fallback
      try {
        final XFile? photo = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (photo != null) {
          setState(() {
            _capturedPhotos.add(photo);
            _photoCount++;
          });
        }
      } catch (galleryError) {
        log('Error picking from gallery: $galleryError');
      }
    }
  }

  void _onBackPressed() {
    context.pop();
  }

  void _onDonePressed() {
    if (_isDoneEnabled) {
      // Navigate to next screen or process photos
      // TODO: Pass captured photos to next screen
      context.pop();
    }
  }

  void _showCameraUnavailableDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Camera Unavailable'),
        content: const Text(
          'Camera is not available on this device or simulator. Using photo picker instead.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _useImagePicker = true;
                _isInitialized = true;
              });
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: CameraAppBar(
          onBackPressed: _onBackPressed,
          onDonePressed: _onDonePressed,
          instructionText: _useImagePicker
              ? 'Select between 3 - 9 photos'
              : 'Take between 3 - 9 photos',
          isDoneEnabled: _isDoneEnabled,
        ),
        body: Stack(
          children: [
            // Camera Preview or Image Picker Interface
            if (_useImagePicker)
              Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 80,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tap the button below to select photos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (_isInitialized && _cameraController != null)
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              )
            else
              Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),

            // Focus Field Overlay - Center of screen (only for camera mode)
            if (!_useImagePicker)
              Center(
                child: Image.asset(
                  'assets/camera/focus_field.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),

            // Bottom Camera Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Left side button (Zoom for camera, empty for image picker)
                    if (!_useImagePicker)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withValues(alpha: 0.75),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '2x',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 48), // Placeholder
                    // Shutter/Select Button
                    GestureDetector(
                      onTap: _takePhoto,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: Container(
                          width: 52,
                          height: 52,
                          margin: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: _useImagePicker
                              ? const Icon(
                                  Icons.photo_library,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : null,
                        ),
                      ),
                    ),

                    // Right side button (Flash for camera, empty for image picker)
                    if (!_useImagePicker)
                      GestureDetector(
                        onTap: _toggleFlash,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _flashMode == FlashMode.off
                                ? AppColors.textPrimary.withValues(alpha: 0.8)
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              _flashMode == FlashMode.off
                                  ? Icons.flash_off
                                  : Icons.flash_on,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 48), // Placeholder
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
