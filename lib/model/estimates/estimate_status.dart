enum EstimateStatus {
  draft,
  inProgress,
  completed,
  sent,
  cancelled;

  String get displayName {
    switch (this) {
      case EstimateStatus.draft:
        return 'Rascunho';
      case EstimateStatus.inProgress:
        return 'Em Andamento';
      case EstimateStatus.completed:
        return 'Concluído';
      case EstimateStatus.sent:
        return 'Enviado';
      case EstimateStatus.cancelled:
        return 'Cancelado';
    }
  }
}
