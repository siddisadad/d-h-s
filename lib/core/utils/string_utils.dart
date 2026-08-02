double parseCurrency(String value) {
  // Remove currency symbol and commas
  final cleanValue = value.replaceAll('₹', '').replaceAll(',', '').trim();
  return double.tryParse(cleanValue) ?? 0.0;
}
