class Vendor {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final int categoryId;
  final int subCategoryId;
  final String? dob;
  final int? age;
  final String? gender;
  final String? fathername;
  final String? nation;
  final String? religion;
  final String? maritalStatus;
  final String? aadhar;
  final String? bloodGroup;
  final String? caste;
  final String phone;
  final String? phone2;
  final String availabilityStatus;
  final String? presentAddress;
  final String address;
  final String cityName;
  final String countryName;
  final String stateName;
  final int country;
  final int state;
  final int city;
  final int pincode;
  final String? permanentAddress;
  final String bio;
  final String? pfDetails;
  final int exp;
  final String? apdate;
  final int role;
  final int? designation;
  final String? department;
  final String? jobType;
  final String? shift;
  final String? pan;
  final String? pfac;
  final String? esiac;
  final String? dlno;
  final String? passport;
  final String? bankacno;
  final String? bankifsc;
  final String? micr;
  final String lang;
  final String? bankname;
  final String? bankbranch;
  final String? empid;
  final String? img;
  final String? googleId;
  final String userType;
  final String? userOrg;
  final int? emailOtp;
  final int isEmailVerified;
  final int status;
  final String? lat;
  final String? long;
  final int branchId;
  final int isFeatured;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? deletedAt;
  final int activeStatus;
  final String avatar;
  final int darkMode;
  final String? messengerColor;
  final String? ratingsAvgRating;

  const Vendor({
    this.id = 0,
    this.name = "no-name",
    this.email = "no-email",
    this.ratingsAvgRating = "no-ratingsAvgRating",
    this.emailVerifiedAt,
    this.categoryId = 0,
    this.subCategoryId = 0,
    this.dob,
    this.age,
    this.gender,
    this.fathername,
    this.nation,
    this.religion,
    this.availabilityStatus  = "online",
    this.maritalStatus,
    this.aadhar,
    this.bloodGroup,
    this.caste,
    this.phone = "no-phone",
    this.cityName = "no-city",
    this.countryName = "no-country",
    this.stateName = "no-state",
    this.phone2,
    this.presentAddress,
    this.address = "no-address",
    this.country = 0,
    this.state = 0,
    this.city = 0,
    this.pincode = 0,
    this.permanentAddress,
    this.bio = "no-bio",
    this.pfDetails,
    this.exp = 0,
    this.apdate,
    this.role = 0,
    this.designation,
    this.department,
    this.jobType,
    this.shift,
    this.pan,
    this.pfac,
    this.esiac,
    this.dlno,
    this.passport,
    this.bankacno,
    this.bankifsc,
    this.micr,
    this.lang = "no-lang",
    this.bankname,
    this.bankbranch,
    this.empid,
    this.img,
    this.googleId,
    this.userType = "no-user-type",
    this.userOrg,
    this.emailOtp,
    this.isEmailVerified = 0,
    this.status = 0,
    this.lat,
    this.long,
    this.branchId = 0,
    this.isFeatured = 0,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.activeStatus = 0,
    this.avatar = "no-avatar",
    this.darkMode = 0,
    this.messengerColor,
  });

  factory Vendor.initial() {
    return Vendor();
  }
  factory Vendor.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse int from dynamic value
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Helper function to safely parse DateTime
    DateTime? tryParseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return Vendor(
      id: tryParseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? "no-name",
      availabilityStatus: json['availability_status']?.toString() ?? "online",
      email: json['email']?.toString() ?? "no-email",
      emailVerifiedAt: json['email_verified_at']?.toString(),
      categoryId: tryParseInt(json['category_id']) ?? 0,
      subCategoryId: tryParseInt(json['sub_category_id']) ?? 0,
      dob: json['dob']?.toString(),
      age: tryParseInt(json['age']),
      gender: json['gender']?.toString(),
      fathername: json['fathername']?.toString(),
      ratingsAvgRating: json['ratings_avg_rating']?.toString() ?? "no-ratings",
      nation: json['nation']?.toString(),
      religion: json['religion']?.toString(),
      maritalStatus: json['maritalstatus']?.toString(),
      aadhar: json['aadhar']?.toString(),
      bloodGroup: json['bloodgroup']?.toString(),
      caste: json['caste']?.toString(),
      phone: json['phone']?.toString() ?? "no-phone",
      phone2: json['phone2']?.toString(),
      presentAddress: json['presentaddress']?.toString(),
      address: json['address']?.toString() ?? "no-address",
      cityName: json['city_name']?.toString() ?? "no-city",
      stateName: json['country_name']?.toString() ?? "no-state",
      countryName: json['state_name']?.toString() ?? "no-country",
      country: tryParseInt(json['country']) ?? 0,
      state: tryParseInt(json['state']) ?? 0,
      city: tryParseInt(json['city']) ?? 0,
      pincode: tryParseInt(json['pincode']) ?? 0,
      permanentAddress: json['permanentaddress']?.toString(),
      bio: json['bio']?.toString() ?? "no-bio",
      pfDetails: json['pf_details']?.toString(),
      exp: tryParseInt(json['exp']) ?? 0,
      apdate: json['apdate']?.toString(),
      role: tryParseInt(json['role']) ?? 0,
      designation: tryParseInt(json['designation']),
      department: json['department']?.toString(),
      jobType: json['jobtype']?.toString(),
      shift: json['shift']?.toString(),
      pan: json['pan']?.toString(),
      pfac: json['pfac']?.toString(),
      esiac: json['esiac']?.toString(),
      dlno: json['dlno']?.toString(),
      passport: json['passport']?.toString(),
      bankacno: json['bankacno']?.toString(),
      bankifsc: json['bankifsc']?.toString(),
      micr: json['micr']?.toString(),
      lang: json['lang']?.toString() ?? "no-lang",
      bankname: json['bankname']?.toString(),
      bankbranch: json['bankbranch']?.toString(),
      empid: json['empid']?.toString(),
      img: json['img']?.toString(),
      googleId: json['google_id']?.toString(),
      userType: json['user_type']?.toString() ?? "no-user-type",
      userOrg: json['user_org']?.toString(),
      emailOtp: tryParseInt(json['email_otp']),
      isEmailVerified: tryParseInt(json['is_email_verified']) ?? 0,
      status: tryParseInt(json['status']) ?? 0,
      lat: json['lat']?.toString(),
      long: json['long']?.toString(),
      branchId: tryParseInt(json['branch_id']) ?? 0,
      isFeatured: tryParseInt(json['is_featured']) ?? 0,
      createdAt: tryParseDateTime(json['created_at']),
      updatedAt: tryParseDateTime(json['updated_at']),
      deletedAt: json['deleted_at']?.toString(),
      activeStatus: tryParseInt(json['active_status']) ?? 0,
      avatar: json['avatar']?.toString() ?? "no-avatar",
      darkMode: tryParseInt(json['dark_mode']) ?? 0,
      messengerColor: json['messenger_color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'dob': dob,
      'age': age,
      'gender': gender,
      'fathername': fathername,
      'nation': nation,
      'religion': religion,
      'maritalstatus': maritalStatus,
      'aadhar': aadhar,
      'bloodgroup': bloodGroup,
      'caste': caste,
      'phone': phone,
      'phone2': phone2,
      'presentaddress': presentAddress,
      'address': address,
      'country': country,
      'state': state,
      'city': city,
      'pincode': pincode,
      'permanentaddress': permanentAddress,
      'bio': bio,
      'pf_details': pfDetails,
      'exp': exp,
      'apdate': apdate,
      'role': role,
      'designation': designation,
      'department': department,
      'jobtype': jobType,
      "city_name": cityName,
      "country_name": countryName,
      "state_name": stateName,
      'shift': shift,
      'pan': pan,
      'pfac': pfac,
      'esiac': esiac,
      'dlno': dlno,
      'passport': passport,
      'bankacno': bankacno,
      'bankifsc': bankifsc,
      'micr': micr,
      'lang': lang,
      'bankname': bankname,
      'bankbranch': bankbranch,
      'empid': empid,
      'img': img,
      'google_id': googleId,
      'user_type': userType,
      'user_org': userOrg,
      'email_otp': emailOtp,
      'is_email_verified': isEmailVerified,
      'status': status,
      'lat': lat,
      'long': long,
      'branch_id': branchId,
      'is_featured': isFeatured,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt,
      'active_status': activeStatus,
      'avatar': avatar,
      'dark_mode': darkMode,
      'messenger_color': messengerColor,
    };
  }

  Vendor copyWith({
    int? id,
    String? name,
    String? email,
    String? emailVerifiedAt,
    int? categoryId,
    int? subCategoryId,
    String? dob,
    int? age,
    String? gender,
    String? fathername,
    String? nation,
    String? religion,
    String? maritalStatus,
    String? aadhar,
    String? bloodGroup,
    String? caste,
    String? phone,
    String? phone2,
    String? presentAddress,
    String? address,
    String? cityName,
    String? stateName,
    String? countryName,
    int? country,
    int? state,
    int? city,
    int? pincode,
    String? permanentAddress,
    String? bio,
    String? pfDetails,
    int? exp,
    String? apdate,
    int? role,
    int? designation,
    String? department,
    String? jobType,
    String? shift,
    String? pan,
    String? pfac,
    String? esiac,
    String? dlno,
    String? passport,
    String? bankacno,
    String? bankifsc,
    String? micr,
    String? lang,
    String? bankname,
    String? bankbranch,
    String? empid,
    String? img,
    String? googleId,
    String? userType,
    String? userOrg,
    int? emailOtp,
    int? isEmailVerified,
    int? status,
    String? lat,
    String? long,
    int? branchId,
    int? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deletedAt,
    int? activeStatus,
    String? avatar,
    int? darkMode,
    String? messengerColor,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      fathername: fathername ?? this.fathername,
      nation: nation ?? this.nation,
      religion: religion ?? this.religion,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      aadhar: aadhar ?? this.aadhar,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      caste: caste ?? this.caste,
      phone: phone ?? this.phone,
      phone2: phone2 ?? this.phone2,
      presentAddress: presentAddress ?? this.presentAddress,
      address: address ?? this.address,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      stateName: stateName ?? this.stateName,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      bio: bio ?? this.bio,
      pfDetails: pfDetails ?? this.pfDetails,
      exp: exp ?? this.exp,
      apdate: apdate ?? this.apdate,
      role: role ?? this.role,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      jobType: jobType ?? this.jobType,
      shift: shift ?? this.shift,
      pan: pan ?? this.pan,
      pfac: pfac ?? this.pfac,
      esiac: esiac ?? this.esiac,
      dlno: dlno ?? this.dlno,
      passport: passport ?? this.passport,
      bankacno: bankacno ?? this.bankacno,
      bankifsc: bankifsc ?? this.bankifsc,
      micr: micr ?? this.micr,
      lang: lang ?? this.lang,
      bankname: bankname ?? this.bankname,
      bankbranch: bankbranch ?? this.bankbranch,
      empid: empid ?? this.empid,
      img: img ?? this.img,
      googleId: googleId ?? this.googleId,
      userType: userType ?? this.userType,
      userOrg: userOrg ?? this.userOrg,
      emailOtp: emailOtp ?? this.emailOtp,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      status: status ?? this.status,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      branchId: branchId ?? this.branchId,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      activeStatus: activeStatus ?? this.activeStatus,
      avatar: avatar ?? this.avatar,
      darkMode: darkMode ?? this.darkMode,
      messengerColor: messengerColor ?? this.messengerColor,
    );
  }
}
