// // ignore_for_file: deprecated_member_use, use_build_context_synchronously
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:spoton_app/screens/password_confirmed.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   @override
//   void dispose() {
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Center(
//             child: Container(
//               constraints: const BoxConstraints(maxWidth: 480),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(0),
//                 color: const Color(0xFFDFDFDF),
//               ),
//               width: double.infinity,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Main content
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 195, 20, 20),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Title
//                           Semantics(
//                             label: 'Create New Password heading',
//                             child: Text(
//                               'Create New Password',
//                               style: GoogleFonts.saira(
//                                 fontSize: 48,
//                                 fontWeight: FontWeight.w500,
//                                 height: 58 / 48,
//                                 letterSpacing: 0.1,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 36),

//                           // Error message
//                           SizedBox(
//                             width: 280,
//                             child: Semantics(
//                               label: 'Password requirement message',
//                               child: Text(
//                                 'Your password must be different from the previous used password.',
//                                 style: GoogleFonts.saira(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w600,
//                                   height: 24 / 13,
//                                   letterSpacing: 0.1,
//                                   color: const Color(0xFF8D1113),
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 45),

//                           // New Password label
//                           Text(
//                             'New Password',
//                             style: GoogleFonts.saira(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               height: 2,
//                               letterSpacing: 0.1,
//                               color: const Color(0xFF707070),
//                             ),
//                           ),

//                           const SizedBox(height: 11),

//                           // New Password field
//                           TextFormField(
//                             controller: _newPasswordController,
//                             obscureText: _obscurePassword,
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.white,
//                               contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 15,
//                                 horizontal: 22,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide.none,
//                               ),
//                               hintText: '*********',
//                               hintStyle: GoogleFonts.saira(
//                                 fontSize: 16,
//                                 color: const Color(0xFF707070),
//                               ),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _obscurePassword
//                                       ? Icons.visibility_off
//                                       : Icons.visibility,
//                                   color: const Color(0xFF707070),
//                                   semanticLabel: _obscurePassword
//                                       ? 'Show password'
//                                       : 'Hide password',
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _obscurePassword = !_obscurePassword;
//                                   });
//                                 },
//                               ),
//                             ),
//                             style: GoogleFonts.saira(
//                               fontSize: 16,
//                               color: const Color(0xFF707070),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter a password';
//                               }
//                               return null;
//                             },
//                             autovalidateMode:
//                                 AutovalidateMode.onUserInteraction,
//                           ),

//                           const SizedBox(height: 20),

//                           // Confirm Password label
//                           Text(
//                             'Confirm Password',
//                             style: GoogleFonts.saira(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               height: 2,
//                               letterSpacing: 0.1,
//                               color: const Color(0xFF707070),
//                             ),
//                           ),

//                           const SizedBox(height: 10),

//                           // Confirm Password field
//                           TextFormField(
//                             controller: _confirmPasswordController,
//                             obscureText: _obscureConfirmPassword,
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.white,
//                               contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 15,
//                                 horizontal: 22,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide.none,
//                               ),
//                               hintText: '*********',
//                               hintStyle: GoogleFonts.saira(
//                                 fontSize: 16,
//                                 color: const Color(0xFF707070),
//                               ),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _obscureConfirmPassword
//                                       ? Icons.visibility_off
//                                       : Icons.visibility,
//                                   color: const Color(0xFF707070),
//                                   semanticLabel: _obscureConfirmPassword
//                                       ? 'Show password'
//                                       : 'Hide password',
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _obscureConfirmPassword =
//                                         !_obscureConfirmPassword;
//                                   });
//                                 },
//                               ),
//                             ),
//                             style: GoogleFonts.saira(
//                               fontSize: 16,
//                               color: const Color(0xFF707070),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please confirm your password';
//                               }
//                               if (value != _newPasswordController.text) {
//                                 return 'Passwords do not match';
//                               }
//                               return null;
//                             },
//                             autovalidateMode:
//                                 AutovalidateMode.onUserInteraction,
//                           ),

//                           const SizedBox(height: 70),

//                           // Reset Password button m3ah Hero Animation
//                           SizedBox(
//                             width: double.infinity,
//                             child: Hero(
//                               tag:
//                                   "signInToStay", // nfs eltag ely fel EnterOtpScreen
//                               child: Material(
//                                 color: Colors.transparent,
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     if (_formKey.currentState!.validate()) {
//                                       // Show processing message
//                                       // ScaffoldMessenger.of(context)
//                                       //     .showSnackBar(
//                                       //   const SnackBar(
//                                       //     content: Text(
//                                       //         'Processing password reset...'),
//                                       //   ),
//                                       // );

//                                       // Navigate to PasswordConfirmedScreen b3d 2 seconds
//                                       Future.delayed(const Duration(seconds: 2),
//                                           () {
//                                         Navigator.pushReplacement(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 const PasswordConfirmedScreen(),
//                                           ),
//                                         );
//                                       });
//                                     }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color(0xFF003579),
//                                     foregroundColor: Colors.white,
//                                     elevation: 4,
//                                     shadowColor: Colors.black.withOpacity(0.25),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(25),
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 27,
//                                       horizontal: 0,
//                                     ),
//                                   ),
//                                   child: Text(
//                                     'Reset Password',
//                                     style: GoogleFonts.saira(
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.w500,
//                                       height: 24 / 24,
//                                       letterSpacing: 0.1,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
