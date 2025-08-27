Map<String, String> splitFullName(String fullName) {
  final trimmedName = fullName.trim();
  if (trimmedName.isEmpty) {
    return {'name': ''};
  }

  return {'name': trimmedName};
}
