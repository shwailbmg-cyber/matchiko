/// Normalises a local Algerian mobile number ("0555 12 34 56",
/// "+213 661 00 00 00" or "770000000") to E.164 (+213555123456).
/// Returns null when it isn't a mobile number. Same rule as the
/// `profiles.phone` check constraint.
String? algerianMobileE164(String input) {
  var d = input.replaceAll(RegExp(r'\D'), '');
  if (d.startsWith('213')) d = d.substring(3);
  if (d.startsWith('0')) d = d.substring(1);
  return RegExp(r'^[567]\d{8}$').hasMatch(d) ? '+213$d' : null;
}
