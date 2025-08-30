enum QuoteUploadStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed'),
  error('error'); // Adicionando status de erro

  const QuoteUploadStatus(this.value);
  final String value;
}
