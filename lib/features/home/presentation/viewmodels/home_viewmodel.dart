import 'package:flutter/foundation.dart';
import '../../domain/entities/home_state.dart';
import '../../domain/entities/home_stats.dart';
import '../../domain/entities/user_greeting.dart';
import '../../domain/usecases/load_home_data_usecase.dart';

class HomeViewmodel extends ChangeNotifier {
  HomeState _state = const HomeState(viewState: HomeViewState.loading);
  final LoadHomeDataUsecase _loadHomeDataUsecase;

  HomeViewmodel({
    LoadHomeDataUsecase? loadHomeDataUsecase,
  }) : _loadHomeDataUsecase = loadHomeDataUsecase ?? LoadHomeDataUsecase();

  HomeState get state => _state;

  void _updateState(HomeState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadHomeData() async {
    try {
      _updateState(_state.copyWith(viewState: HomeViewState.loading));

      // Load all data concurrently
      final results = await Future.wait([
        _loadHomeDataUsecase.loadUserGreeting(),
        _loadHomeDataUsecase.loadHomeStats(),
        _loadHomeDataUsecase.hasActiveProjects(),
      ]);

      final userGreeting = results[0] as UserGreeting;
      final stats = results[1] as HomeStats;
      final hasProjects = results[2] as bool;

      _updateState(HomeState(
        viewState: HomeViewState.loaded,
        userGreeting: userGreeting,
        stats: stats,
        hasProjects: hasProjects,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        viewState: HomeViewState.error,
        errorMessage: 'Failed to load home data: ${e.toString()}',
      ));
    }
  }

  Future<void> refresh() async {
    await loadHomeData();
  }
}