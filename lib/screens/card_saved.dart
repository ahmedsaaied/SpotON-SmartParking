import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardSaved extends StatelessWidget {
  const CardSaved({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Payment card saved confirmation',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF838383),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top section with Spot ON branding
            Container(
              padding: const EdgeInsets.only(top: 72, bottom: 21),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with logo and Spot ON
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 71),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/logo.png', // Replace with actual asset path
                              width: 36,
                              height: 36 / 1.12,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 20),
                            Container(
                              padding: const EdgeInsets.only(
                                left: 34,
                                right: 6,
                                top: 6,
                                bottom: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: const Color(0xFF003579),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Semantics(
                                    label: 'Spot',
                                    child: Text(
                                      'Spot',
                                      style: GoogleFonts.righteous(
                                        fontSize: 52,
                                        color: Colors.white,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 67,
                                    height: 67,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(103),
                                      color: Colors.white,
                                    ),
                                    child: Semantics(
                                      label: 'ON',
                                      child: Text(
                                        'ON',
                                        style: GoogleFonts.righteous(
                                          fontSize: 32,
                                          color: Colors.black,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Institution info
                        Padding(
                          padding: const EdgeInsets.only(top: 23),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.saira(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF473232),
                                height: 1,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'AASTMT',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Color(0xFF003579),
                                  ),
                                ),
                                TextSpan(
                                  text: ' -',
                                  style: TextStyle(
                                    color: Color(0xFF003579),
                                  ),
                                ),
                                TextSpan(text: ' '),
                                TextSpan(
                                  text: 'CS, Eng.',
                                  style: TextStyle(
                                    color: Color(0xFF8D1113),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Visitor spot info
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.saira(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF003579),
                                height: 19 / 15,
                              ),
                              children: const [
                                TextSpan(text: 'Visitor spot is now '),
                                TextSpan(
                                  text: 'ON',
                                  style: TextStyle(
                                    color: Color(0xFF8D1113),
                                  ),
                                ),
                                TextSpan(text: '\n'),
                                TextSpan(
                                  text: '1h from 8:00pm',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 16 / 12,
                                    color: Color(0xFF8D1113),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vehicle details section
                  Padding(
                    padding: const EdgeInsets.only(top: 33),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 335),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Car details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.saira(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF8D1113),
                                      height: 1,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: 'BMW',
                                        style: TextStyle(
                                          fontSize: 24,
                                        ),
                                      ),
                                      TextSpan(text: ' '),
                                      TextSpan(
                                        text: '- M4',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 22, left: 14),
                                  child: Text(
                                    'Color',
                                    style: GoogleFonts.saira(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF003579),
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Time left indicator
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFF8D1113),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/clock.png', // Replace with actual asset path
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '59 mins Left',
                                    style: GoogleFonts.saira(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Credit card section
            Container(
              margin: const EdgeInsets.only(top: 38),
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 309),
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF6600AA),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card logo
                  Image.asset(
                    'assets/images/card_logo.png', // Replace with actual asset path
                    width: 104,
                    fit: BoxFit.contain,
                  ),
                  // Chip
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 32),
                    child: Image.asset(
                      'assets/images/chip.png', // Replace with actual asset path
                      width: 53,
                      height: 53 / 1.02,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Card number
                  Semantics(
                    label: 'Card number',
                    child: Text(
                      '1234 5678 9012 3456',
                      style: GoogleFonts.alexandria(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Card details (valid thru, name, etc)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'VALID THRU',
                                  style: GoogleFonts.alexandria(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 13),
                                Text(
                                  'Ahmed Muhamed',
                                  style: GoogleFonts.slabo13px(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 2.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            const SizedBox(width: 23),
                            Text(
                              '03/27',
                              style: GoogleFonts.alexandria(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 2.4,
                                shadows: [
                                  const Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Color.fromRGBO(0, 0, 0, 0.25),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Image.asset(
                            'assets/images/visa.png', // Replace with actual asset path
                            width: 50,
                            height: 50 / 2.27,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Payment complete section
            Container(
              padding: const EdgeInsets.only(top: 93, left: 6, right: 6),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // Payment complete text
                  Text(
                    'Payment Complete',
                    style: GoogleFonts.saira(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF003579),
                      height: 1.2,
                      letterSpacing: 0.1,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Payment method icons
                  Padding(
                    padding: const EdgeInsets.only(top: 37),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 288),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/visa_blue.png', // Replace with actual asset path
                            width: 50,
                            height: 50 / 2.27,
                            fit: BoxFit.contain,
                          ),
                          Image.asset(
                            'assets/images/mastercard.png', // Replace with actual asset path
                            width: 50,
                            height: 50 / 1.67,
                            fit: BoxFit.contain,
                          ),
                          Image.asset(
                            'assets/images/paypal.png', // Replace with actual asset path
                            width: 42,
                            height: 42 / 1.23,
                            fit: BoxFit.contain,
                          ),
                          Image.asset(
                            'assets/images/apple_pay.png', // Replace with actual asset path
                            width: 41,
                            height: 41 / 1.46,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Card saved successfully button
                  Padding(
                    padding: const EdgeInsets.only(top: 51),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(36, 26, 36, 26),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: const Color(0xFF003579),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Card Saved Successfully',
                              style: GoogleFonts.alexandria(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: 0.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: const DecorationImage(
                                image: AssetImage(
                                    'assets/images/check_circle_bg.png'), // Replace with actual asset path
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              height: 33,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Add some bottom padding for better visual appearance
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
