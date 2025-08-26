Map<String, String> splitFullName(String fullName) {
  final trimmedName = fullName.trim();
  if (trimmedName.isEmpty) {
    return {'firstName': '', 'lastName': ''};
  }

  final parts = trimmedName.split(' ');
  if (parts.length == 1) {
    return {'firstName': parts[0], 'lastName': ''};
  }

  final firstName = parts.first;
  final lastName = parts.skip(1).join(' ');
  return {'firstName': firstName, 'lastName': lastName};
}
