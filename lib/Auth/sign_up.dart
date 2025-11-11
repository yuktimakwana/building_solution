import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  final Color greenColor = ColorConstant.greenColor;
  final Color errorColor = ColorConstant.errorColor; // Dark Red

  Future<void> _signUp() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
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
        Text(
          error,
          softWrap: true,
          style: TextStyle(
            color: errorColor,
            overflow: TextOverflow.visible,
            fontSize: 13,
            fontWeight: FontWeight.w500,
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

// ✅ TextFormField Widget
Widget textForms({
  required TextEditingController textEditingController,
  required TextInputAction textInputAction,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.emailAddress,
  Widget icon = const SizedBox(),
  String? Function(String?)? validator,
  required String hintText,
}) {
  return TextFormField(
    controller: textEditingController,
    obscureText: obscureText,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    decoration: InputDecoration(
      hintText: hintText,
      fillColor: Colors.white,
      hintStyle: TextStyle(color: ColorConstant.lightGreyColor),
      filled: true,
      border: const OutlineInputBorder(),
      suffixIcon: icon,
    ),
    validator: validator,
  );
}

Widget texts({required String titleText}) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      titleText,
      style: const TextStyle(color: Colors.white, fontSize: 16),
    ),
  );
}
