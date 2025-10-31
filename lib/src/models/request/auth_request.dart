class LoginAuthRequest {
  final String email;
  final String password;
  const LoginAuthRequest({required this.password, required this.email});

  Map<String, dynamic> toJson() {
    return {"email": email, "password": password};
  }
}

class SignupAuthRequest {
  final String name;
  final String email;
  // final String organization; // Changed from organisation
  final String phone;
  final String password;
  final String confirmPassword;
  final int country;
  final int state;
  final int city;
  final int pincode;

  const SignupAuthRequest({
    required this.confirmPassword,
    required this.password,
    required this.name,
    required this.email,
    // required this.organization, // Changed from organisation
    required this.phone,
    required this.country,
    required this.state,
    required this.city,
    required this.pincode,
  });

 
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "country": country,
      "state": state,
      "city": city,
      "pincode": pincode,
      // "organisation": organization,
      "password": password,
      "confirm_password": password,
    };
  }

  
}
