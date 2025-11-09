// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:spoton_app/screens/login_page.dart';

// class PasswordConfirmedScreen extends StatelessWidget {
//   const PasswordConfirmedScreen({super.key});

//   // Colors
//   static const Color primaryColor = Color(0xFF8D1113);
//   static const Color backgroundColor = Color(0xFFDFDFDF);
//   static const Color cardColor = Colors.white;
//   static const Color toggleBackgroundColor = Color(0xFFC4C4C4);
//   static const Color textPrimaryColor = Colors.black;
//   static const Color textSecondaryColor = Colors.white;
//   static const Color shadowColor = Color.fromRGBO(0, 0, 0, 0.25);

//   @override
//   Widget build(BuildContext context) {
//     //bywdeny 3la el LoginPage b3d 3 seconds
//     Future.delayed(const Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//     });

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 223, 223, 223),
//       body: SizedBox(
//         child: Column(
//           children: [
//             // Top white section m3 ellogo
//             Container(
//               decoration: BoxDecoration(
//                 color: cardColor,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               width: double.infinity,
//               padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
//               child: Column(
//                 children: [
//                   // Spot toggle
//                   Container(
//                     margin: const EdgeInsets.only(top: 0),
//                     padding: const EdgeInsets.all(4),
//                     width: 165,
//                     decoration: BoxDecoration(
//                       color: toggleBackgroundColor,
//                       borderRadius: BorderRadius.circular(100),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 48,
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: textPrimaryColor,
//                             borderRadius: BorderRadius.circular(103),
//                           ),
//                           child: Center(
//                             child: Text(
//                               "OFF",
//                               style: GoogleFonts.righteous(
//                                 fontSize: 20,
//                                 color: textSecondaryColor,
//                                 letterSpacing: 0.1,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 7),
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 0),
//                             child: Text(
//                               "Spot",
//                               style: GoogleFonts.righteous(
//                                 fontSize: 40,
//                                 color: textSecondaryColor,
//                                 letterSpacing: 0.1,
//                                 height: 0.6,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                 ],
//               ),
//             ),

//             // Main content
//             Padding(
//               padding: const EdgeInsets.fromLTRB(7, 105, 7, 0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Create New Password
//                   Padding(
//                     padding: const EdgeInsets.only(left: 14),
//                     child: Text(
//                       "Create New Password",
//                       style: GoogleFonts.saira(
//                         fontSize: 48,
//                         fontWeight: FontWeight.w500,
//                         height: 1.2,
//                         letterSpacing: 0.1,
//                         color: textPrimaryColor,
//                       ),
//                       semanticsLabel: "Create New Password heading",
//                     ),
//                   ),

//                   // Confirmation box m3 Hero Animation
//                   Hero(
//                     tag: "signInToStay", // nfs tag ForgotPasswordScreen
//                     child: Material(
//                       color: Colors.transparent,
//                       child: Container(
//                         margin: const EdgeInsets.only(top: 40),
//                         padding: const EdgeInsets.symmetric(vertical: 50),
//                         decoration: BoxDecoration(
//                           color: primaryColor,
//                           borderRadius: BorderRadius.circular(25),
//                           boxShadow: const [
//                             BoxShadow(
//                               color: shadowColor,
//                               blurRadius: 4,
//                               offset: Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: SizedBox(
//                           height: 365, // 7agm el red rectangle
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               // Confirmation text
//                               Positioned(
//                                 top:
//                                     90, // mkan eltext bta3 new password confirmed gowa elrectangle
//                                 child: Text(
//                                   "New\nPassword\nConfirmed",
//                                   textAlign: TextAlign.center,
//                                   style: GoogleFonts.saira(
//                                     fontSize: 40,
//                                     fontWeight: FontWeight.w500,
//                                     height: 1.05,
//                                     letterSpacing: 0.1,
//                                     color: textSecondaryColor,
//                                   ),
//                                   semanticsLabel:
//                                       "New Password Confirmed message",
//                                 ),
//                               ),

//                               // Checkmark
//                               Positioned(
//                                 top: 260, // vertical position
//                                 child: Container(
//                                   width: 36,
//                                   height: 36,
//                                   decoration: const BoxDecoration(
//                                     color: textSecondaryColor,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.check,
//                                     color: textPrimaryColor,
//                                     size: 24,
//                                     semanticLabel: "Confirmation checkmark",
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
