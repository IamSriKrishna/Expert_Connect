import 'package:dio/dio.dart';
import 'package:expert_connect/src/app/app_url.dart';
import 'package:expert_connect/src/auth/bloc/auth_bloc.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/settings/bloc/setting_bloc.dart';
import 'package:expert_connect/src/settings/widget/profile_success.dart';
import 'package:expert_connect/src/widgets/common_builder/drop_down_builder.dart';
import 'package:expert_connect/src/widgets/common_builder/searchable_dropdown_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _dialogShown = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phNumberController;
  late TextEditingController _pincodeController;

  // Selected values for dropdowns and language chips
  String? _selectedCountryId;
  String? _selectedStateId;
  String? _selectedCityId;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    // Load initial data
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load countries and categories when screen initializes
    BlocProvider.of<AuthBloc>(context).add(CountryFetched());

    // Load dependent data if user has existing selections
    final user = authStateManager.user;
    if (user != null) {
      if (user.country != 0) {
        BlocProvider.of<AuthBloc>(context).add(StateFetched(user.country));
      }
      if (user.state != 0) {
        BlocProvider.of<AuthBloc>(context).add(CityFetched(user.state));
      }
    }
  }

  void _initializeControllers() {
    final user = authStateManager.user;

    _nameController = TextEditingController(text: user?.name ?? '');
    _phNumberController = TextEditingController(text: user?.phone ?? '');
    _pincodeController = TextEditingController(
      text: user?.pincode.toString() ?? '',
    );

    // Set initial dropdown values
    _selectedCountryId = user?.country != 0 ? user?.country.toString() : null;
    _selectedStateId = user?.state != 0 ? user?.state.toString() : null;
    _selectedCityId = user?.city != 0 ? user?.city.toString() : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phNumberController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: Color(0xFF6C5CE7)),
              ),
              title: const Text('Take Photo'),
              onTap: () => _getImage(ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF6C5CE7),
                ),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () => _getImage(ImageSource.gallery),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    Navigator.pop(context);

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (image != null) {
        final String extension = image.path.toLowerCase().split('.').last;
        if (extension == 'png' || extension == 'jpg' || extension == 'jpeg') {
          setState(() {
            _profileImage = File(image.path);
          });
        } else {
          _showErrorDialog('Please select only PNG or JPG images.');
        }
      }
    } catch (e) {
      _showErrorDialog('Error selecting image. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF6C5CE7))),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final user = authStateManager.user;
    final userImg = user?.img;

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF6C5CE7).withOpacity(0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: _profileImage != null
                ? Image.file(_profileImage!, fit: BoxFit.cover)
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6C5CE7).withOpacity(0.1),
                          const Color(0xFF74B9FF).withOpacity(0.1),
                        ],
                      ),
                      image: (userImg != null && userImg.isNotEmpty)
                          ? DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                "${AppUrl.imageUrl}/$userImg",
                              ),
                              onError: (exception, stackTrace) {
                                debugPrint(
                                  'Error loading profile image: $exception',
                                );
                              },
                            )
                          : null,
                    ),
                    child: (userImg == null || userImg.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF6C5CE7),
                          )
                        : null,
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + (isRequired ? ' *' : ''),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                : null,
            decoration: InputDecoration(
              hintText: hintText ?? 'Enter $label',
              prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDropdowns(AuthState authState) {
    return Column(
      children: [
        // Country Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchableDropdownField<String>(
              name: 'Country',
              validationTypes: [ValidationType.required],
              initialValue: _selectedCountryId,
              items: authState.country
                  .map(
                    (e) => SearchableDropdownOption(
                      value: e.id.toString(),
                      label: e.name,
                      icon: Icon(
                        Icons.flag_outlined,
                        color: Colors.green.shade400,
                        size: 18.sp,
                      ),
                    ),
                  )
                  .toList(),
              prefixIcon: Icon(
                Icons.public,
                color: Colors.green.shade400,
                size: 20.sp,
              ),
              hintText: "Search and select country",
              emptyMessage: "No countries found",
              onChanged: (value) {
                setState(() {
                  _selectedCountryId = value;
                  _selectedStateId = null;
                  _selectedCityId = null;
                });

                if (value != null) {
                  final selectedCountryId = int.tryParse(value);
                  if (selectedCountryId != null) {
                    BlocProvider.of<AuthBloc>(
                      context,
                    ).add(StateFetched(selectedCountryId));
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),

        // State Dropdown
        if (_selectedCountryId != null && authState.state.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchableDropdownField<String>(
                    name: 'State',
                    validationTypes: [ValidationType.required],
                    initialValue: _selectedStateId,
                    items: authState.state
                        .map(
                          (e) => SearchableDropdownOption(
                            value: e.id.toString(),
                            label: e.name,
                            icon: Icon(
                              Icons.map_outlined,
                              color: Colors.purple.shade400,
                              size: 18.sp,
                            ),
                          ),
                        )
                        .toList(),
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: Colors.purple.shade400,
                      size: 20.sp,
                    ),
                    hintText: "Search and select state",
                    emptyMessage: "No states found",
                    onChanged: (value) {
                      setState(() {
                        _selectedStateId = value;
                        _selectedCityId = null;
                      });

                      if (value != null) {
                        final selectedStateId = int.tryParse(value);
                        if (selectedStateId != null) {
                          BlocProvider.of<AuthBloc>(
                            context,
                          ).add(CityFetched(selectedStateId));
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

        // City Dropdown
        if (_selectedStateId != null && authState.city.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchableDropdownField<String>(
                    name: 'City',
                    validationTypes: [ValidationType.required],
                    initialValue: _selectedCityId,
                    items: authState.city
                        .map(
                          (e) => SearchableDropdownOption(
                            value: e.id.toString(),
                            label: e.name,
                            icon: Icon(
                              Icons.location_city_outlined,
                              color: Colors.teal.shade400,
                              size: 18.sp,
                            ),
                          ),
                        )
                        .toList(),
                    prefixIcon: Icon(
                      Icons.place_outlined,
                      color: Colors.teal.shade400,
                      size: 20.sp,
                    ),
                    hintText: "Search and select city",
                    emptyMessage: "No cities found",
                    onChanged: (value) {
                      setState(() {
                        _selectedCityId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _updateProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCountryId == null ||
          _selectedStateId == null ||
          _selectedCityId == null) {
        _showErrorDialog('Please select country, state, and city');
        return;
      }

      setState(() {
        _dialogShown = false;
      });

      try {
        MultipartFile? multipartFile;
        if (_profileImage != null) {
          multipartFile = MultipartFile.fromFileSync(_profileImage!.path);
        }

        context.read<SettingBloc>().add(
          UpdateUserProfile(
            name: _nameController.text.trim(),
            phNumber: _phNumberController.text.trim(),
            country: int.parse(_selectedCountryId!),
            state: int.parse(_selectedStateId!),
            city: int.parse(_selectedCityId!),
            pincode: _pincodeController.text.trim(),
            profileImage: multipartFile,
          ),
        );
      } catch (e) {
        _showErrorDialog('Error updating profile. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingBloc, SettingState>(
      listener: (context, settingState) {
        if (settingState.userProfileUpdateStatus ==
                UserProfileUpdateStatus.success &&
            !_dialogShown) {
          _dialogShown = true;

          final imageUrl = settingState.userProfile.img;
          final imageUrlString = imageUrl.isNotEmpty
              ? "${AppUrl.imageUrl}/$imageUrl"
              : null;

          context.showModernSuccessDialog(
            message: "Profile updated successfully!",
            imageUrl: imageUrlString,
            onClose: () {
              setState(() {
                _profileImage = null;
                _dialogShown = false;
              });

              // Reset the profile update flag if such event exists
              // context.read<SettingBloc>().add(ResetVendorProfileUpdateFlag());
            },
          );
        } else if (settingState.userProfileUpdateStatus ==
                UserProfileUpdateStatus.failed &&
            !_dialogShown) {
          _dialogShown = true;
          _showErrorDialog(settingState.message);

          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _dialogShown = false;
              });
            }
          });
        }
      },
      builder: (context, settingState) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: const Color(0xFF1A1A1A),
                title: const Text(
                  'Update Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                centerTitle: true,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: const Icon(Icons.arrow_back_ios, size: 16),
                  ),
                ),
              ),
              body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image Section
                      Center(
                        child: Column(
                          children: [
                            _buildProfileImage(),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to change profile picture',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Basic Information
                      Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        hintText: 'Enter your full name',
                        isRequired: true,
                      ),
                       _buildTextField(
                        controller: _phNumberController,
                        label: 'Phone Number',
                        icon: Icons.numbers,
                        hintText: 'Enter your Phone Number',
                        isRequired: true,
                        keyboardType: TextInputType.number
                      ),

                      // Location Information
                      Text(
                        'Location Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildLocationDropdowns(authState),

                      _buildTextField(
                        controller: _pincodeController,
                        label: 'Pincode',
                        icon: Icons.pin_drop_outlined,
                        hintText: 'Enter pincode',
                        keyboardType: TextInputType.number,
                        isRequired: true,
                      ),

                      const SizedBox(height: 40),

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              settingState.userProfileUpdateStatus ==
                                  UserProfileUpdateStatus.loading
                              ? null
                              : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C5CE7),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child:
                              settingState.userProfileUpdateStatus ==
                                  UserProfileUpdateStatus.loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Update Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
