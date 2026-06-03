/// Utility class for input validation
class Validators {
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and special characters
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (cleanedValue.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    
    if (!RegExp(r'^[0-9+]+$').hasMatch(cleanedValue)) {
      return 'Phone number can only contain digits and +';
    }
    
    return null;
  }
  
  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 100) {
      return 'Name must not exceed 100 characters';
    }
    
    return null;
  }
  
  /// Validate number
  static String? validateNumber(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return 'Value must be at least $min';
    }
    
    if (max != null && number > max) {
      return 'Value must not exceed $max';
    }
    
    return null;
  }
  
  /// Validate milk quantity
  static String? validateMilkQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Milk quantity is required';
    }
    
    final quantity = double.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid quantity';
    }
    
    if (quantity < 0.5) {
      return 'Minimum quantity is 0.5 liters';
    }
    
    return null;
  }
  
  /// Validate NIDA (National ID) - must be exactly 20 digits
  static String? validateNIDA(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIDA is required';
    }
    
    // Remove any spaces
    final cleanedValue = value.replaceAll(' ', '');
    
    if (cleanedValue.length != 20) {
      return 'NIDA must be exactly 20 digits';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedValue)) {
      return 'NIDA must contain only digits';
    }
    
    return null;
  }
  
  /// Validate age from date of birth (18-100 years old)
  static String? validateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) {
      return 'Date of birth is required';
    }
    
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    
    // Adjust age if birthday hasn't occurred this year
    final adjustedAge = (now.month < dateOfBirth.month ||
            (now.month == dateOfBirth.month && now.day < dateOfBirth.day))
        ? age - 1
        : age;
    
    if (adjustedAge < 18) {
      return 'Farmer must be at least 18 years old';
    }
    
    if (adjustedAge > 100) {
      return 'Please enter a valid date of birth';
    }
    
    return null;
  }
  
  /// Validate gender
  static String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gender is required';
    }
    
    if (value != 'Male' && value != 'Female') {
      return 'Please select a valid gender';
    }
    
    return null;
  }
  
  /// Validate phone number with Tanzania format (+255XXXXXXXXX)
  static String? validateTanzaniaPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces
    final cleanedValue = value.replaceAll(' ', '');
    
    if (!cleanedValue.startsWith('+255')) {
      return 'Phone number must start with +255';
    }
    
    if (cleanedValue.length != 13) {
      return 'Phone number must be in format +255XXXXXXXXX';
    }
    
    if (!RegExp(r'^\+255[0-9]{9}$').hasMatch(cleanedValue)) {
      return 'Invalid phone number format';
    }
    
    return null;
  }
  
  /// Validate optional email (null or valid format)
  static String? validateOptionalEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }
    
    return validateEmail(value);
  }
  
  /// Validate name with specific length constraints (2-50 characters, letters only)
  static String? validatePersonName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return '$fieldName must not exceed 50 characters';
    }
    
    // Allow letters, spaces, hyphens, and apostrophes
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return '$fieldName can only contain letters';
    }
    
    return null;
  }
  
  /// Validate optional middle name
  static String? validateOptionalMiddleName(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Middle name is optional
    }
    
    return validatePersonName(value, 'Middle name');
  }
  
  // Private constructor to prevent instantiation
  Validators._();
}
