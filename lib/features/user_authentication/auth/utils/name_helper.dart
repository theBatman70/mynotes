String? extractLastName(String displayName) {
  final pieces = displayName.split(' ');
  return pieces.lastOrNull;
}

String extractFirstName(String displayName) {
  final pieces = displayName.split(' ');
  return pieces.first;
}