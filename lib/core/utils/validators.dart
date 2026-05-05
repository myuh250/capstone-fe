abstract class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Không được để trống';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Không được để trống';
    if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Không được để trống';
    if (value.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    return null;
  }

  static String? Function(String?) minLength(int min) {
    return (value) {
      if (value == null || value.length < min) {
        return 'Tối thiểu $min ký tự';
      }
      return null;
    };
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Không được để trống';
    if (value != password) return 'Mật khẩu không khớp';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'Không được để trống';
    if (value.length != 6) return 'OTP phải có 6 chữ số';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'OTP chỉ gồm chữ số';
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Không được để trống';
    if (value.trim().length < 2) return 'Tên phải có ít nhất 2 ký tự';
    if (value.trim().length > 50) return 'Tên không quá 50 ký tự';
    return null;
  }
}
