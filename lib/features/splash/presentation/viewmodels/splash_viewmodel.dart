import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../domain/entities/splash_state.dart';
import '../../domain/usecases/initialize_app_usecase.dart';

class SplashViewmodel extends ChangeNotifier {
  SplashState _state = SplashState.initializing;
  final InitializeAppUsecase _initializeAppUsecase;

  SplashViewmodel({
    InitializeAppUsecase? initializeAppUsecase,
  }) : _initializeAppUsecase = initializeAppUsecase ?? InitializeAppUsecase();

  SplashState get state => _state;

  void _updateState(SplashState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> initializeApp(BuildContext context) async {
    try {
      _updateState(SplashState.animating);
      await _initializeAppUsecase.execute(context);
      _updateState(SplashState.navigating);
    } catch (e) {
      _updateState(SplashState.error);
      rethrow;
    }
  }
}