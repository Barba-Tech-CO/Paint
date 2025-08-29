enum PdfUploadStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed'),
  error('error'); // Adicionando status de erro

  const PdfUploadStatus(this.value);
  final String value;
}
