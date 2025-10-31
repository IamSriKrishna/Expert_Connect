class AppConstant {
  static String getCategoryNameById(int categoryId) {
    switch (categoryId) {
      case 2:
        return 'Doctor';
      case 3:
        return 'HR';
      case 4:
        return 'Finance';
      case 5:
        return 'Business';
      case 9:
        return 'Lawyer';
      default:
        return 'Unknown Category';
    }
  }

  static String getSubCategoryNameById(int subCategoryId) {
    switch (subCategoryId) {
      // Medical subcategories
      case 2:
        return 'Cardiologist';
      case 3:
        return 'Gastroenterology';
      case 4:
        return 'Dermatology';

      // HR subcategories
      case 11:
        return 'Employee Relations';
      case 12:
        return 'Onboarding & Offboarding';

      // Finance subcategories
      case 9:
        return 'Financial Planning';
      case 10:
        return 'Investment Management';

      // Business subcategories
      case 7:
        return 'Business Development';
      case 8:
        return 'IT & Support Services';

      // Lawyer subcategories
      case 5:
        return 'Family Lawyer';
      case 6:
        return 'Criminal Lawyer';

      default:
        return 'Unknown Subcategory';
    }
  }

  
  static List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static List<String> weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
}
