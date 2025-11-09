// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class CarSaved extends StatefulWidget {
//   // final String brand;
//   // final String model;
//   // final String color;
//   // final String plateLetters;
//   // final String plateNumbers;

//   const CarSaved({
//     super.key,
//     // required this.brand,
//     // required this.model,
//     // required this.color,
//     // required this.plateLetters,
//     // required this.plateNumbers,
//   });

//   @override
//   State<CarSaved> createState() => _CarSavedState();
// }

// class _CarSavedState extends State<CarSaved> with TickerProviderStateMixin {
//   late AnimationController _checkmarkController;
//   late Animation<double> _checkmarkAnimation;

//   late AnimationController _redBannerController;
//   late Animation<Offset> _redBannerOffset;

//   @override
//   void initState() {
//     super.initState();

//     _checkmarkController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );
//     _checkmarkAnimation = CurvedAnimation(
//       parent: _checkmarkController,
//       curve: Curves.easeOutBack,
//     );

//     _redBannerController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     );
//     _redBannerOffset = Tween<Offset>(
//       begin: const Offset(0, -1.5),
//       end: const Offset(0, 0),
//     ).animate(CurvedAnimation(
//       parent: _redBannerController,
//       curve: Curves.easeOut,
//     ));

//     _checkmarkController.forward();
//     _redBannerController.forward();
//   }

//   @override
//   void dispose() {
//     _checkmarkController.dispose();
//     _redBannerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 131, 131, 131),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 _buildTopBar(),
//                 Expanded(
//                   child: Stack(
//                     children: [
//                       SlideTransition(
//                         position: _redBannerOffset,
//                         child: _buildRedBanner(),
//                       ),
//                       _buildConfirmationCard(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             _buildCarImage(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTopBar() {
//     return Container(
//       alignment: Alignment.centerLeft,
//       padding: const EdgeInsets.fromLTRB(40, 30, 180, 30),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
//         boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
//       ),
//       child: GestureDetector(
//         onTap: () => Navigator.pop(context),
//         child:
//             const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
//       ),
//     );
//   }

//   Widget _buildCarImage() {
//     return Positioned(
//       top: 390,
//       left: 0,
//       right: 0,
//       child: Center(
//         child: Hero(
//           tag: 'car-image',
//           child: Image.asset(
//             'assets/images/bmw.png',
//             width: 311,
//             height: 311 / 1.8,
//             fit: BoxFit.contain,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRedBanner() {
//     return Align(
//       alignment: Alignment.topCenter,
//       child: Container(
//         margin: const EdgeInsets.only(top: 0),
//         padding: const EdgeInsets.fromLTRB(25, 90, 25, 0),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(25),
//           color: const Color(0xFF8D1113),
//           boxShadow: const [
//             BoxShadow(
//               color: Color.fromRGBO(0, 0, 0, 0.25),
//               blurRadius: 20,
//               offset: Offset(0, 3),
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Text(
//               'Car Saved Successfully',
//               textAlign: TextAlign.center,
//               style: GoogleFonts.alexandria(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 17),
//             ScaleTransition(
//               scale: _checkmarkAnimation,
//               child: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.check, color: Colors.green, size: 24),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildConfirmationCard() {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Container(
//         margin: const EdgeInsets.only(top: 195),
//         padding: const EdgeInsets.fromLTRB(35, 60, 35, 15),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             RichText(
//               text: TextSpan(
//                 style: GoogleFonts.saira(
//                   fontSize: 19,
//                   fontWeight: FontWeight.w700,
//                   color: const Color(0xFF8D1113),
//                 ),
//                 children: [
//                   // TextSpan(
//                   //   text: widget.brand,
//                   //   style: const TextStyle(fontSize: 24),
//                   // ),
//                   const TextSpan(
//                     text: ' - ',
//                     style: TextStyle(color: Colors.black),
//                   ),
//                   // TextSpan(
//                   //   text: widget.model,
//                   //   style: const TextStyle(fontSize: 15, color: Colors.black),
//                   // ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text('Color', style: _labelStyle()),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Container(
//                   width: 14,
//                   height: 14,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     // color: _getColorFromName(widget.color),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 // Text(widget.color, style: _valueStyle()),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Text('Plates', style: _labelStyle()),
//             const SizedBox(height: 8),
//             // _buildPlatePreviewCustom(widget.plateNumbers, widget.plateLetters),
//             // const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF003579),
//                   foregroundColor: Colors.white,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 70, vertical: 18),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25)),
//                 ),
//                 child: Text(
//                   'Use as primary',
//                   style: GoogleFonts.alexandria(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlatePreviewCustom(String numbers, String letters) {
//     return Container(
//       width: 100,
//       decoration: BoxDecoration(
//         color: const Color(0xFFDADADA),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(2),
//             decoration: BoxDecoration(
//               color: const Color(0xFF0055C4),
//               borderRadius: BorderRadius.circular(2),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('EGYPT',
//                     style:
//                         GoogleFonts.saira(color: Colors.white, fontSize: 13)),
//                 Text('مصر',
//                     style:
//                         GoogleFonts.saira(color: Colors.white, fontSize: 13)),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: FittedBox(
//                     fit: BoxFit.scaleDown,
//                     alignment: Alignment.center,
//                     child: Text(
//                       numbers,
//                       style: GoogleFonts.saira(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: 1,
//                   height: 30,
//                   color: Colors.black,
//                   margin: const EdgeInsets.symmetric(horizontal: 6),
//                 ),
//                 Expanded(
//                   child: FittedBox(
//                     fit: BoxFit.scaleDown,
//                     alignment: Alignment.center,
//                     child: Text(
//                       letters,
//                       style: GoogleFonts.saira(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   TextStyle _labelStyle() => GoogleFonts.saira(
//         fontSize: 15,
//         fontWeight: FontWeight.w700,
//         color: const Color(0xFF003579),
//       );

//   TextStyle _valueStyle() => GoogleFonts.saira(
//         fontSize: 14,
//         fontWeight: FontWeight.w500,
//         color: const Color(0xFF4D4D4D),
//       );

//   Color _getColorFromName(String name) {
//     switch (name.toLowerCase()) {
//       case 'black':
//         return Colors.black;
//       case 'white':
//         return Colors.white;
//       case 'red':
//         return Colors.red;
//       case 'blue':
//         return Colors.blue;
//       case 'green':
//         return Colors.green;
//       case 'silver':
//         return const Color(0xFFC0C0C0);
//       case 'gray':
//         return Colors.grey;
//       case 'yellow':
//         return Colors.yellow;
//       case 'gold':
//         return const Color(0xFFFFD700);
//       case 'orange':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }
// }
