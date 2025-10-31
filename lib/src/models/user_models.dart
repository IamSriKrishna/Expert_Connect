class UserModel {
  final int id;
  final String name;
  final String email;
  final String emailVerifiedAt;
  final int categoryId;
  final int subCategoryId;
  final String dob;
  final int age;
  final String gender;
  final String fathername;
  final String nation;
  final String religion;
  final String maritalStatus;
  final String aadhar;
  final String bloodGroup;
  final String caste;
  final String phone;
  final String phone2;
  final String presentAddress;
  final String address; // New field
  final int country;
  final int state;
  final int city;
  final int pincode;
  final String permanentAddress;
  final String bio; // New field
  final String pfDetails; // New field
  final int exp; // New field
  final String apdate;
  final int role;
  final int designation;
  final String department;
  final String jobType;
  final String shift;
  final String pan;
  final String pfac;
  final String esiac;
  final String dlno;
  final String passport;
  final String bankacno;
  final String bankifsc;
  final String micr;
  final String lang; // New field
  final String bankname;
  final String bankbranch;
  final String empid;
  final String img;
  final String googleId;
  final String userType;
  final String userOrg;
  final int emailOtp;
  final int isEmailVerified;
  final int status;
  final String lat; // New field
  final String long; // New field
  final int branchId;
  final int isFeatured; // New field
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String deletedAt;
  final int activeStatus;
  final String avatar;
  final int darkMode;
  final String messengerColor;

  const UserModel({
    this.id = 0,
    this.name = "no-name",
    this.email = "no-email",
    this.emailVerifiedAt = "no-email-verified-at",
    this.categoryId = 0,
    this.subCategoryId = 0,
    this.dob = "no-dob",
    this.age = 0,
    this.gender = "no-gender",
    this.fathername = "no-fathername",
    this.nation = "no-nation",
    this.religion = "no-religion",
    this.maritalStatus = "no-marital-status",
    this.aadhar = "no-aadhar",
    this.bloodGroup = "no-bloodgroup",
    this.caste = "no-caste",
    this.phone = "no-phone",
    this.phone2 = "no-phone2",
    this.presentAddress = "no-present-address",
    this.address = "no-address", // New field
    this.country = 0,
    this.state = 0,
    this.city = 0,
    this.pincode = 0,
    this.permanentAddress = "no-permanent-address",
    this.bio = "no-bio", // New field
    this.pfDetails = "no-pf-details", // New field
    this.exp = 0, // New field
    this.apdate = "no-apdate",
    this.role = 0,
    this.designation = 0,
    this.department = "no-department",
    this.jobType = "no-jobtype",
    this.shift = "no-shift",
    this.pan = "no-pan",
    this.pfac = "no-pfac",
    this.esiac = "no-esiac",
    this.dlno = "no-dlno",
    this.passport = "no-passport",
    this.bankacno = "no-bankacno",
    this.bankifsc = "no-bankifsc",
    this.micr = "no-micr",
    this.lang = "no-lang", // New field
    this.bankname = "no-bankname",
    this.bankbranch = "no-bankbranch",
    this.empid = "no-empid",
    this.img = "no-img",
    this.googleId = "no-google-id",
    this.userType = "no-user-type",
    this.userOrg = "no-user-org",
    this.emailOtp = 0,
    this.isEmailVerified = 0,
    this.status = 0,
    this.lat = "no-lat", // New field
    this.long = "no-long", // New field
    this.branchId = 0,
    this.isFeatured = 0, // New field
    this.createdAt,
    this.updatedAt,
    this.deletedAt = "no-deleted-at",
    this.activeStatus = 0,
    this.avatar = "no-avatar",
    this.darkMode = 0,
    this.messengerColor = "no-messenger-color",
  });

  factory UserModel.initial() {
    return UserModel();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "no-name",
      email: json['email'] ?? "no-email",
      emailVerifiedAt: json['email_verified_at'] ?? "no-email-verified-at",
      categoryId: json['category_id'] ?? 0,
      subCategoryId: json['sub_category_id'] ?? 0,
      dob: json['dob'] ?? "no-dob",
      age: json['age'] ?? 0,
      gender: json['gender'] ?? "no-gender",
      fathername: json['fathername'] ?? "no-fathername",
      nation: json['nation'] ?? "no-nation",
      religion: json['religion'] ?? "no-religion",
      maritalStatus: json['maritalstatus'] ?? "no-marital-status",
      aadhar: json['aadhar'] ?? "no-aadhar",
      bloodGroup: json['bloodgroup'] ?? "no-bloodgroup",
      caste: json['caste'] ?? "no-caste",
      phone: json['phone'] ?? "no-phone",
      phone2: json['phone2'] ?? "no-phone2",
      presentAddress: json['presentaddress'] ?? "no-present-address",
      address: json['address'] ?? "no-address", // New field
      country: json['country'] ?? 0,
      state: json['state'] ?? 0,
      city: json['city'] ?? 0,
      pincode: json['pincode'] ?? 0,
      permanentAddress: json['permanentaddress'] ?? "no-permanent-address",
      bio: json['bio'] ?? "no-bio", // New field
      pfDetails: json['pf_details'] ?? "no-pf-details", // New field
      exp: json['exp'] ?? 0, // New field
      apdate: json['apdate'] ?? "no-apdate",
      role: json['role'] ?? 0,
      designation: json['designation'] ?? 0,
      department: json['department'] ?? "no-department",
      jobType: json['jobtype'] ?? "no-jobtype",
      shift: json['shift'] ?? "no-shift",
      pan: json['pan'] ?? "no-pan",
      pfac: json['pfac'] ?? "no-pfac",
      esiac: json['esiac'] ?? "no-esiac",
      dlno: json['dlno'] ?? "no-dlno",
      passport: json['passport'] ?? "no-passport",
      bankacno: json['bankacno'] ?? "no-bankacno",
      bankifsc: json['bankifsc'] ?? "no-bankifsc",
      micr: json['micr'] ?? "no-micr",
      lang: json['lang'] ?? "no-lang", // New field
      bankname: json['bankname'] ?? "no-bankname",
      bankbranch: json['bankbranch'] ?? "no-bankbranch",
      empid: json['empid'] ?? "no-empid",
      img: json['img'] ?? "no-img",
      googleId: json['google_id'] ?? "no-google-id",
      userType: json['user_type'] ?? "no-user-type",
      userOrg: json['user_org'] ?? "no-user-org",
      emailOtp: json['email_otp'] ?? 0,
      isEmailVerified: json['is_email_verified'] ?? 0,
      status: json['status'] ?? 0,
      lat: json['lat'] ?? "no-lat", // New field
      long: json['long'] ?? "no-long", // New field
      branchId: json['branch_id'] ?? 0,
      isFeatured: json['is_featured'] ?? 0, // New field
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] ?? "no-deleted-at",
      activeStatus: json['active_status'] ?? 0,
      avatar: json['avatar'] ?? "no-avatar",
      darkMode: json['dark_mode'] ?? 0,
      messengerColor: json['messenger_color'] ?? "no-messenger-color",
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
      'address': address, // New field
      'country': country,
      'state': state,
      'city': city,
      'pincode': pincode,
      'permanentaddress': permanentAddress,
      'bio': bio, // New field
      'pf_details': pfDetails, // New field
      'exp': exp, // New field
      'apdate': apdate,
      'role': role,
      'designation': designation,
      'department': department,
      'jobtype': jobType,
      'shift': shift,
      'pan': pan,
      'pfac': pfac,
      'esiac': esiac,
      'dlno': dlno,
      'passport': passport,
      'bankacno': bankacno,
      'bankifsc': bankifsc,
      'micr': micr,
      'lang': lang, // New field
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
      'lat': lat, // New field
      'long': long, // New field
      'branch_id': branchId,
      'is_featured': isFeatured, // New field
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt,
      'active_status': activeStatus,
      'avatar': avatar,
      'dark_mode': darkMode,
      'messenger_color': messengerColor,
    };
  }

  UserModel copyWith({
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
    String? address, // New field
    int? country,
    int? state,
    int? city,
    int? pincode,
    String? permanentAddress,
    String? bio, // New field
    String? pfDetails, // New field
    int? exp, // New field
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
    String? lang, // New field
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
    String? lat, // New field
    String? long, // New field
    int? branchId,
    int? isFeatured, // New field
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deletedAt,
    int? activeStatus,
    String? avatar,
    int? darkMode,
    String? messengerColor,
  }) {
    return UserModel(
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
      address: address ?? this.address, // New field
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      bio: bio ?? this.bio, // New field
      pfDetails: pfDetails ?? this.pfDetails, // New field
      exp: exp ?? this.exp, // New field
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
      lang: lang ?? this.lang, // New field
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
      lat: lat ?? this.lat, // New field
      long: long ?? this.long, // New field
      branchId: branchId ?? this.branchId,
      isFeatured: isFeatured ?? this.isFeatured, // New field
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