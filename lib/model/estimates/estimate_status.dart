enum EstimateStatus {
  draft,
  pending,
  photosUploaded,
  elementsSelected,
  completed,
  sent,
  cancelled;

  String get displayName {
    switch (this) {
      case EstimateStatus.draft:
        return 'Draft';
      case EstimateStatus.pending:
        return 'Pending';
      case EstimateStatus.photosUploaded:
        return 'Photos Uploaded';
      case EstimateStatus.elementsSelected:
        return 'Elements Selected';
      case EstimateStatus.completed:
        return 'Completed';
      case EstimateStatus.sent:
        return 'Sent';
      case EstimateStatus.cancelled:
        return 'Cancelled';
    }
  }
}
