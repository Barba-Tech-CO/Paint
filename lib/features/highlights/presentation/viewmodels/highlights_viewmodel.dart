import 'package:flutter/foundation.dart';
import '../../domain/entities/highlights_state.dart';
import '../../domain/usecases/load_highlights_usecase.dart';

class HighlightsViewmodel extends ChangeNotifier {
  HighlightsState _state = const HighlightsState(viewState: HighlightsViewState.loading);
  final LoadHighlightsUsecase _loadHighlightsUsecase;

  HighlightsViewmodel({
    LoadHighlightsUsecase? loadHighlightsUsecase,
  }) : _loadHighlightsUsecase = loadHighlightsUsecase ?? LoadHighlightsUsecase();

  HighlightsState get state => _state;

  void _updateState(HighlightsState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadHighlights() async {
    try {
      _updateState(_state.copyWith(viewState: HighlightsViewState.loading));

      final highlights = await _loadHighlightsUsecase.execute();

      if (highlights.isEmpty) {
        _updateState(_state.copyWith(
          viewState: HighlightsViewState.empty,
          highlights: highlights,
        ));
      } else {
        _updateState(_state.copyWith(
          viewState: HighlightsViewState.loaded,
          highlights: highlights,
        ));
      }
    } catch (e) {
      _updateState(_state.copyWith(
        viewState: HighlightsViewState.error,
        errorMessage: 'Failed to load highlights: ${e.toString()}',
      ));
    }
  }

  Future<void> refresh() async {
    await loadHighlights();
  }
}