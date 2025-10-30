import 'package:shared_preferences/shared_preferences.dart';

class PhoneNumberManager {
  static const _phoneKey = 'user_phone_number';

  /// Save a phone number
  static Future<void> savePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phoneNumber);
    print('✅ Phone number saved: $phoneNumber');
  }

  /// Get the saved phone number
  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  /// Remove the saved phone number
  static Future<void> removePhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneKey);
    print('🗑️ Phone number removed');
  }
}
