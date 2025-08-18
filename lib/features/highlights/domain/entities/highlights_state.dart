import 'highlight.dart';

enum HighlightsViewState {
  loading,
  loaded,
  empty,
  error,
}

class HighlightsState {
  final HighlightsViewState viewState;
  final List<Highlight> highlights;
  final String? errorMessage;

  const HighlightsState({
    required this.viewState,
    this.highlights = const [],
    this.errorMessage,
  });

  HighlightsState copyWith({
    HighlightsViewState? viewState,
    List<Highlight>? highlights,
    String? errorMessage,
  }) {
    return HighlightsState(
      viewState: viewState ?? this.viewState,
      highlights: highlights ?? this.highlights,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}