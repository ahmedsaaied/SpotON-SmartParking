// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spoton_app/screens/login_page.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  static final _firstNameController = TextEditingController();
  static final _lastNameController = TextEditingController();
  static final _emailController = TextEditingController();
  static final _passwordController = TextEditingController();
  static final _confirmPasswordController = TextEditingController();

  void _validateAndSignUp(BuildContext context) async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar("Error", "All fields are required");
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showSnackBar("Error", "Please enter a valid email address");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Error", "Passwords do not match");
      return;
    }

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.sendEmailVerification();

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(credential.user!.uid)
          .set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'createdAt': Timestamp.now(),
        'emailVerified': false,
      });

      await FirebaseAuth.instance.signOut();

      _showSnackBar(
        "Success",
        "Verification email sent. Please log in after verifying.",
        success: true,
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    } on FirebaseAuthException catch (e) {
      _showSnackBar("Error", e.message ?? "Sign up failed");
    } catch (e) {
      _showSnackBar("Error", "Unexpected error occurred");
    }
  }

  void _showSnackBar(String title, String message, {bool success = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: success ? Colors.green : const Color(0xFF8D1113),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context)
                          .cardColor // or #2B2B2B for stronger dark
                      : Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Hero(
                        tag: "spotLogo",
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 280),
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color.fromARGB(255, 25, 25, 25)
                                  : const Color(0xFFC4C4C4),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 81,
                                  height: 81,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white : Colors.black,
                                    borderRadius: BorderRadius.circular(103),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      "OFF",
                                      style: GoogleFonts.righteous(
                                        fontSize: 32,
                                        color: isDark
                                            ? Colors.black
                                            : Colors.white,
                                        height: 1,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 17),
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      "Spot",
                                      style: GoogleFonts.righteous(
                                        fontSize: 64,
                                        color: Colors.white,
                                        height: 0,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.only(top: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 17),
                      margin: const EdgeInsets.only(bottom: 0),
                      child: Text(
                        'Create Your \nAccount',
                        style: GoogleFonts.saira(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                          letterSpacing: 0.1,
                        ),
                        semanticsLabel: 'Create Your Account heading',
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(
                                255, 64, 8, 9) // or try 0xFF1F1F1F
                            : const Color(0xFF003579),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildField("First Name", "ex: Ahmed",
                                    _firstNameController),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildField("Last Name", "ex: Saaied",
                                    _lastNameController),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _buildField(
                            "E-mail or ID",
                            "example@gmail.com or 211014219",
                            _emailController,
                          ),
                          const SizedBox(height: 20),
                          _buildPasswordField("Password", _passwordController),
                          const SizedBox(height: 13),
                          _buildPasswordField(
                              "Confirm Password", _confirmPasswordController),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: GestureDetector(
                                onTap: () => _validateAndSignUp(context),
                                child: Text(
                                  'Sign up',
                                  style: GoogleFonts.saira(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.saira(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.saira(
                color: const Color.fromARGB(170, 255, 255, 255),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            ),
            style: GoogleFonts.saira(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.saira(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 2,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 7),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "********",
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: GoogleFonts.saira(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(170, 112, 112, 112),
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}
