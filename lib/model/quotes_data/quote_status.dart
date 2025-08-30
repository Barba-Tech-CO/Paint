enum QuoteStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed'),
  error('error'); // Adicionando status de erro

  const QuoteStatus(this.value);
  final String value;
}
