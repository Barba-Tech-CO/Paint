import 'home_stats.dart';
import 'user_greeting.dart';

enum HomeViewState {
  loading,
  loaded,
  error,
}

class HomeState {
  final HomeViewState viewState;
  final UserGreeting? userGreeting;
  final HomeStats? stats;
  final bool hasProjects;
  final String? errorMessage;

  const HomeState({
    required this.viewState,
    this.userGreeting,
    this.stats,
    this.hasProjects = false,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeViewState? viewState,
    UserGreeting? userGreeting,
    HomeStats? stats,
    bool? hasProjects,
    String? errorMessage,
  }) {
    return HomeState(
      viewState: viewState ?? this.viewState,
      userGreeting: userGreeting ?? this.userGreeting,
      stats: stats ?? this.stats,
      hasProjects: hasProjects ?? this.hasProjects,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}