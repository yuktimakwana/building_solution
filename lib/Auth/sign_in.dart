import 'package:duplicate_building_solution/Auth/sign_up.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;
  String? validation;

  final Color greenColor = const Color.fromRGBO(154, 190, 70, 1);

  // ====================== SIGN IN FUNCTION ======================
  void _signIn() async {
    setState(() {
      validation = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (!mounted) return;

      // Save session locally
      final sp = await SharedPreferences.getInstance();
      sp.setString('email', email);
      sp.setString('UID', FirebaseAuth.instance.currentUser?.uid ?? '');

      // Navigate to next screen
      Navigator.pushReplacementNamed(context, '/party');
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'invalid-credential':
            validation = TextConstant.emailPwdError;
            break;
          case 'too-many-requests':
            validation = TextConstant.tooManyReqError;
            break;
          default:
            validation = TextConstant.somethingWrong;
        }
      });
    } catch (e) {
      setState(() {
        validation = TextConstant.unexpectedError;
      });
    }
  }

  // ====================== VALIDATORS ======================
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return TextConstant.emailNotEmptyError;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
    if (!emailRegex.hasMatch(value)) return TextConstant.enterValidEmailError;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return TextConstant.pwdNotEmptyError;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (pop,_){
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: greenColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Center(
                      child: Text(
                        TextConstant.signInBtn,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // ====================== EMAIL FIELD ======================
                    texts(titleText: TextConstant.emailId),
                    const SizedBox(height: 5),
                    textForms(
                      textEditingController: _emailController,
                      hintText: TextConstant.emailHint,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    // ====================== PASSWORD FIELD ======================
                    const SizedBox(height: 15),
                    texts(titleText: TextConstant.pwd),
                    const SizedBox(height: 5),
                    textForms(
                      textEditingController: _passwordController,
                      obscureText: !_passwordVisible,
                      hintText: TextConstant.pwdHint,
                      textInputAction: TextInputAction.done,
                      icon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: greenColor,
                        ),
                        onPressed: () {
                          setState(() => _passwordVisible = !_passwordVisible);
                        },
                      ),
                      validator: _validatePassword,
                    ),

                    //======================= VALIDATION =======================
                    validation != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  validation ?? '',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                  softWrap: true,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(height: 15),

                    // ====================== SIGN IN BUTTON ======================
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: greenColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 110,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _signIn,
                        child:  Text(
                          TextConstant.signInBtn,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // ====================== SIGN UP NAVIGATION ======================
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signUp');
                        },
                        child:  Text(
                          TextConstant.newUser,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
