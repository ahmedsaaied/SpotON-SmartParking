// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spoton_app/screens/home_page.dart';
import 'package:spoton_app/screens/sign_up.dart';
import 'package:spoton_app/screens/id_scanner.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController()..addListener(_validateInput);
    _passwordController = TextEditingController()..addListener(_validateInput);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  void _validateInput() {
    final emailFilled = _emailController.text.trim().isNotEmpty;
    final passwordFilled = _passwordController.text.trim().isNotEmpty;
    _isButtonEnabled.value = emailFilled && passwordFilled;
  }

  Future<void> _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _isButtonEnabled.dispose();
    super.dispose();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        await _ensureUserDocument(user);
      }

      return userCredential;
    } catch (e) {
      print("Google sign-in error: $e");
      return null;
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password cannot be empty.")),
      );
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please verify your email before logging in."),
            backgroundColor: Color(0xFF8D1113),
          ),
        );
        return;
      }

      await _ensureUserDocument(user!);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'invalid-email' => 'Invalid email address.',
        'user-disabled' => 'User disabled.',
        'user-not-found' => 'No user found for that email.',
        'wrong-password' => 'Wrong password provided.',
        _ => 'An error occurred. Please try again.',
      };

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred.")),
      );
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email address first.")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent!")),
      );
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'invalid-email' => 'Invalid email address.',
        'user-not-found' => 'No user found for that email.',
        _ => 'An error occurred. Please try again.',
      };

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred.")),
      );
    }
  }

  Future<void> _ensureUserDocument(User user) async {
    final usersRef = FirebaseFirestore.instance.collection('Users');
    final userDoc = usersRef.doc(user.uid);

    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'userId': user.uid,
        'email': user.email,
        'firstName': '',
        'lastName': '',
        'isAdmin': false,
        'isBlocked': false,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(isDark),
                    _buildBody(isDark),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: "getHelpButton",
            child: Material(
              color: Colors.transparent,
              child: _buildHelpButton(),
            ),
          ),
          Hero(
            tag: "englishText",
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Text(
                      "English",
                      style: GoogleFonts.saira(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Color(0xFF8D1113),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Image.asset(
                      "assets/images/internet.png",
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Theme.of(context).colorScheme.brightness == Brightness.dark
                ? const Color.fromARGB(255, 90, 13, 13)
                : const Color(0xFF8D1113),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(31),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/customer-service.png",
            width: 16,
            height: 16,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 5),
          Text(
            "Get help",
            style: GoogleFonts.saira(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              height: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
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
                              color: isDark ? Colors.black : Colors.white,
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
          const SizedBox(height: 30),
          Text("Get access by",
              style: GoogleFonts.saira(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              )),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildSocialButton(
                  icon: "assets/images/google.png",
                  label: "Google",
                  onPressed: () async {
                    final user = await signInWithGoogle();
                    if (user != null && mounted) {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const HomePage()));
                    }
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildSocialButton(
                  icon: "assets/images/facebook.png",
                  label: "Facebook",
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildAppleButton(),
          const SizedBox(height: 35),
          Text("Or enter your Email or ID",
              style: GoogleFonts.saira(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 2,
              )),
          _buildTextField(
            _emailController,
            "example@gmail.com",
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner,
                  size: 25, color: Color(0xFF8D1113)),
              onPressed: () async {
                final scannedID = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IDScannerScreen()),
                );
                if (scannedID != null) {
                  setState(() {
                    _emailController.text = scannedID;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildTextField(_passwordController, "********", obscure: true),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _resetPassword,
              child: Text("Forgot password?",
                  style: GoogleFonts.saira(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8D1113))),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ValueListenableBuilder<bool>(
              valueListenable: _isButtonEnabled,
              builder: (_, enabled, __) {
                return ElevatedButton(
                  onPressed: enabled ? _signInWithEmailAndPassword : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: enabled
                        ? const Color(0xFF003579)
                        : const Color(0xFF003579).withOpacity(0.5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 10),
                    minimumSize: const Size(236, 0),
                    elevation: 4,
                  ),
                  child: Text("Sign in",
                      style: GoogleFonts.saira(
                          fontSize: 20, fontWeight: FontWeight.w500)),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ",
                    style: GoogleFonts.saira(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    )),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()));
                  },
                  child: Text("Register Now!",
                      style: GoogleFonts.saira(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8D1113))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
      {required String icon,
      required String label,
      required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(icon, width: 24, height: 24),
          const SizedBox(width: 6),
          Text(label,
              style:
                  GoogleFonts.saira(fontSize: 13, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildAppleButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 97.89, vertical: 18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/apple.png", width: 20, height: 20),
          const SizedBox(width: 5),
          Text("Sign in with Apple",
              style:
                  GoogleFonts.saira(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool obscure = false, Widget? suffixIcon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.saira(
                color: Theme.of(context).hintColor, fontSize: 14),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: suffixIcon,
                    ),
                  )
                : null,
          ),
          style: GoogleFonts.saira(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}
