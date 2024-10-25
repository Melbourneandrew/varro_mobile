String stripFormatting(String input) {
  return input
      .replaceAll('\\n', '')
      .replaceAll('"', '')
      .replaceAll("'", '')
      .replaceAll('/', '')
      .replaceAll('\\', '')
      .replaceAll('*', '');
}
