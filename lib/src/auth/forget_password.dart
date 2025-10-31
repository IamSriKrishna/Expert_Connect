import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ForgotPasswordStep { email, otp, newPassword, success }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'user@gmail.com');
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  ForgotPasswordStep _currentStep = ForgotPasswordStep.email;

  int _otpTimer = 60;
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  void _restartAnimations() {
    _slideController.reset();
    Future.delayed(Duration(milliseconds: 100), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase and number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    // Dispatch the event
    context.read<AuthBloc>().add(
      AuthForgetPasswordRequested(_emailController.text.trim()),
    );
  }

  // Replace your _resetPassword method with this:
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    // Dispatch the event
    context.read<AuthBloc>().add(
      AuthResetPasswordRequested(
        email: _emailController.text.trim(),
        otp: _otpController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      ),
    );
  }

  Future<void> _verifyOtp(AuthState state) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isLoading = false;
      _currentStep = ForgotPasswordStep.newPassword;
    });

    _restartAnimations();
  }

  void _startOtpTimer() {
    setState(() {
      _otpTimer = 60;
      _canResendOtp = false;
    });

    Future.delayed(Duration(seconds: 1), () {
      if (_otpTimer > 0) {
        setState(() {
          _otpTimer--;
        });
        _startOtpTimer();
      } else {
        setState(() {
          _canResendOtp = true;
        });
      }
    });
  }

  void _resendOtp(AuthState state) {
    _sendOtp();
  }

  void _goBack() {
    if (_currentStep == ForgotPasswordStep.email) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        switch (_currentStep) {
          case ForgotPasswordStep.otp:
            _currentStep = ForgotPasswordStep.email;
            break;
          case ForgotPasswordStep.newPassword:
            _currentStep = ForgotPasswordStep.otp;
            break;
          case ForgotPasswordStep.success:
            Navigator.of(context).pop();
            break;
          default:
            break;
        }
      });
      _restartAnimations();
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return 'Forgot Password?';
      case ForgotPasswordStep.otp:
        return 'Verify OTP';
      case ForgotPasswordStep.newPassword:
        return 'Set New Password';
      case ForgotPasswordStep.success:
        return 'Success!';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return 'Don\'t worry! It happens. Please enter the email address associated with your account.';
      case ForgotPasswordStep.otp:
        return 'We have sent a 6-digit verification code to ${_emailController.text}';
      case ForgotPasswordStep.newPassword:
        return 'Your new password must be different from previously used passwords.';
      case ForgotPasswordStep.success:
        return 'Your password has been successfully reset!';
    }
  }

  IconData _getStepIcon() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return Icons.lock_reset_rounded;
      case ForgotPasswordStep.otp:
        return Icons.verified_user_outlined;
      case ForgotPasswordStep.newPassword:
        return Icons.security_rounded;
      case ForgotPasswordStep.success:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle state changes here
        if (state.status == AuthStatus.passwordResetInitiated) {
          setState(() {
            _isLoading = false;
            _currentStep = ForgotPasswordStep.otp;
          });
          _restartAnimations();
          _startOtpTimer();
        } else if (state.status == AuthStatus.passwordResetComplete) {
          setState(() {
            _isLoading = false;
            _currentStep = ForgotPasswordStep.success;
          });
          _scaleController.forward();
          HapticFeedback.mediumImpact();
        } else if (state.status == AuthStatus.failed ||
            state.status == AuthStatus.unauthenticated) {
          setState(() {
            _isLoading = false;
          });
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Operation failed'),
              backgroundColor: AppColor.errorColor,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColor.backgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Container(
                  height: size.height - MediaQuery.of(context).padding.top,
                  child: Stack(
                    children: [
                      // Background gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColor.backgroundColor, Colors.white],
                          ),
                        ),
                      ),

                      // Main content
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),

                            // Back button
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: GestureDetector(
                                onTap: _goBack,
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    color: AppColor.textPrimary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 40),

                            // Header
                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColor.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        _getStepIcon(),
                                        color: AppColor.primaryColor,
                                        size: 32,
                                      ),
                                    ),

                                    SizedBox(height: 24),

                                    Text(
                                      _getStepTitle(),
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),

                                    SizedBox(height: 8),

                                    Text(
                                      _getStepSubtitle(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColor.textSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 40),

                            // Content based on current step
                            Expanded(child: _buildCurrentStepContent(state)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStepContent(AuthState state) {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return _buildEmailStep(state);
      case ForgotPasswordStep.otp:
        return _buildOtpStep(state);
      case ForgotPasswordStep.newPassword:
        return _buildNewPasswordStep(state);
      case ForgotPasswordStep.success:
        return _buildSuccessStep();
    }
  }

  Widget _buildEmailStep(AuthState state) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),

              SizedBox(height: 32),

              _buildPrimaryButton(
                text: 'Send OTP',
                onPressed: _isLoading ? null : () => _sendOtp(),
                isLoading: _isLoading,
              ),

              SizedBox(height: 24),

              _buildBackToLoginButton(),

              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpStep(AuthState state) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                controller: _otpController,
                label: 'Enter OTP',
                icon: Icons.security,
                keyboardType: TextInputType.number,
                validator: _validateOtp,
                maxLength: 6,
              ),

              SizedBox(height: 16),

              // Timer and resend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _canResendOtp
                        ? 'Didn\'t receive OTP?'
                        : 'Resend in ${_otpTimer}s',
                    style: TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  if (_canResendOtp)
                    TextButton(
                      onPressed: () => _resendOtp(state),
                      child: Text(
                        'Resend',
                        style: TextStyle(
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 32),

              _buildPrimaryButton(
                text: 'Verify OTP',
                onPressed: _isLoading ? null : () => _verifyOtp(state),
                isLoading: _isLoading,
              ),

              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewPasswordStep(AuthState state) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                controller: _passwordController,
                label: 'New Password',
                icon: Icons.lock_outline,
                obscureText: !_isPasswordVisible,
                validator: _validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColor.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),

              SizedBox(height: 24),

              _buildInputField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                icon: Icons.lock_outline,
                obscureText: !_isConfirmPasswordVisible,
                validator: _validateConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColor.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),

              SizedBox(height: 16),

              // Password requirements
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password must contain:',
                      style: TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildPasswordRequirement('At least 8 characters'),
                    _buildPasswordRequirement('One uppercase letter'),
                    _buildPasswordRequirement('One lowercase letter'),
                    _buildPasswordRequirement('One number'),
                  ],
                ),
              ),

              SizedBox(height: 32),

              _buildPrimaryButton(
                text: 'Reset Password',
                onPressed: _isLoading ? null : () => _resetPassword(),
                isLoading: _isLoading,
              ),

              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessStep() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColor.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: AppColor.successColor,
              size: 64,
            ),
          ),

          SizedBox(height: 32),

          Text(
            'Password Reset Successfully!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary,
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Your password has been changed successfully.\nYou can now sign in with your new password.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColor.textSecondary,
              height: 1.5,
            ),
          ),

          SizedBox(height: 40),

          _buildPrimaryButton(
            text: 'Back to Login',
            onPressed: () => Navigator.of(context).pop(),
            isLoading: false,
          ),

          Spacer(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        maxLength: maxLength,
        style: TextStyle(
          fontSize: 16,
          color: AppColor.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColor.textSecondary, fontSize: 14),
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColor.primaryColor, size: 20),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColor.errorColor, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColor.errorColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor,
            AppColor.primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return Center(
      child: TextButton(
        onPressed: _goBack,
        child: RichText(
          text: TextSpan(
            text: 'Remember your password? ',
            style: TextStyle(color: AppColor.textSecondary, fontSize: 14),
            children: [
              TextSpan(
                text: 'Sign in',
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 4, color: AppColor.textSecondary),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: AppColor.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
