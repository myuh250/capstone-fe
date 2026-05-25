abstract class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Invalid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? Function(String?) minLength(int min) {
    return (value) {
      if (value == null || value.length < min) {
        return 'Minimum $min characters';
      }
      return null;
    };
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'This field is required';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    if (value.length != 6) return 'OTP must be 6 digits';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'OTP must contain only digits';
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (value.trim().length > 50) return 'Name must not exceed 50 characters';
    return null;
  }
}
