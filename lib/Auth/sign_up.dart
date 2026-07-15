import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final _userNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _userNameError;
  String? _mobileError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  final Color greenColor = ColorConstant.greenColor;
  final Color errorColor = ColorConstant.errorColor; // Dark Red

  Future<void> _signUp() async {
    setState(() {
      _userNameError = null;
      _mobileError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Re-initialize FirebaseRef with new user UID
        FirebaseRef.init();

        // Update display name
        await userCredential.user?.updateDisplayName(_userNameController.text.trim());

        // Save profile data to Firestore
        await FirebaseRef.userProfileDoc.set({
          'displayName': _userNameController.text.trim(),
          'mobile': '+91${_mobileController.text.trim()}',
          'email': _emailController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/signin');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          setState(() {
            _emailError = 'Email already exists';
          });
        } else {
          setState(() {
            _emailError = e.message;
          });
        }
      }
    }
  }

  Widget _buildErrorText(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.error, color: ColorConstant.errorColor, size: 16),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            error,
            softWrap: true,
            style: TextStyle(
              color: errorColor,
              overflow: TextOverflow.visible,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            decoration: BoxDecoration(
              color: greenColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TextConstant.signUpBtn,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // User Name Field
                  texts(titleText: TextConstant.userName),
                  const SizedBox(height: 6),
                  textForms(
                    textEditingController: _userNameController,
                    hintText: TextConstant.userNameHint,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return TextConstant.userNameError;
                      }
                      return null;
                    },
                  ),
                  _buildErrorText(_userNameError),
                  const SizedBox(height: 15),

                  // Mobile Number Field
                  texts(titleText: TextConstant.mobileNumber),
                  const SizedBox(height: 6),
                  textForms(
                    textEditingController: _mobileController,
                    hintText: TextConstant.mobileNumberHint,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    prefix: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return TextConstant.mobileNumberError;
                      }
                      if (value.length < 10) {
                        return TextConstant.mobileNumberError;
                      }
                      return null;
                    },
                  ),
                  _buildErrorText(_mobileError),
                  const SizedBox(height: 15),

                  // Email Field
                  texts(titleText: TextConstant.emailId),
                  const SizedBox(height: 6),
                  textForms(
                    textEditingController: _emailController,
                    hintText: TextConstant.emailHint,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return TextConstant.emailNotEmptyError;
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return TextConstant.enterValidEmailError;
                      }
                      return null;
                    },
                  ),
                  _buildErrorText(_emailError),
                  const SizedBox(height: 15),

                  // Password Field
                  texts(titleText: TextConstant.pwd),
                  const SizedBox(height: 6),
                  textForms(
                    textEditingController: _passwordController,
                    obscureText: !_isPasswordVisible,
                    hintText: TextConstant.pwdHint,
                    textInputAction: TextInputAction.next,
                    icon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: greenColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return TextConstant.pwdNotEmptyError;
                      }
                      if (value.length < 6) {
                        return TextConstant.pwdLengthError;
                      }
                      final alphanumeric = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)');
                      if (!alphanumeric.hasMatch(value)) {
                        return TextConstant.pwdAlphaNumError;
                      }
                      return null;
                    },
                  ),
                  _buildErrorText(_passwordError),
                  const SizedBox(height: 15),

                  // Confirm Password Field
                  texts(titleText: TextConstant.confirmPwd),
                  const SizedBox(height: 6),
                  textForms(
                    textEditingController: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    textInputAction: TextInputAction.done,
                    hintText: TextConstant.confirmPwdHint,
                    icon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: greenColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return TextConstant.pwdNotEmptyError;
                      }
                      if (value.length < 6) {
                        return TextConstant.pwdLengthError;
                      }
                      final alphanumeric = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)');
                      if (!alphanumeric.hasMatch(value)) {
                        return TextConstant.pwdAlphaNumError;
                      }
                      if (value != _passwordController.text) {
                        return TextConstant.pwdCPwdMatch;
                      }
                      return null;
                    },
                  ),
                  _buildErrorText(_confirmPasswordError),
                  const SizedBox(height: 25),

                  // Sign Up Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 100,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _signUp,
                    child: Text(
                      TextConstant.signUpBtn,
                      style: TextStyle(
                        color: greenColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sign In Text
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/signin');
                    },
                    child: Text(
                      TextConstant.alreadyUser,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
