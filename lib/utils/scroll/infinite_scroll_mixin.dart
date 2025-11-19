import 'package:flutter/material.dart';

/// Mixin para facilitar o scroll infinito em listas
mixin InfiniteScrollMixin<T extends StatefulWidget> on State<T> {
  late ScrollController scrollController;

  /// Callback chamado quando o usuário chega próximo ao final da lista
  void onNearEnd();

  /// Distância do final da lista para ativar o callback (padrão: 200px)
  double get nearEndThreshold => 200.0;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - nearEndThreshold) {
      onNearEnd();
    }
  }
}
