import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentComp extends StatelessWidget {
  const PaymentComp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 131, 131, 131),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header section with logo and toggle
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(27, 50, 75, 23),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(19, 1, 1, 1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color(0xFF003579),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Spot',
                                style: GoogleFonts.righteous(
                                  fontSize: 30,
                                  height: 0.8,
                                  color: Colors.white,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 37,
                                height: 37,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(103),
                                  color: Colors.white,
                                ),
                                child: Text(
                                  'ON',
                                  style: GoogleFonts.righteous(
                                    fontSize: 20,
                                    height: 1.2,
                                    color: Colors.black,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main content
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 70),
                    padding: const EdgeInsets.only(top: 23),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        // mkan elhagz
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.saira(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1,
                              letterSpacing: 0.1,
                              color: const Color(0xFF473232),
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

                        // Visitor spot
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.saira(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 19 / 15,
                                letterSpacing: 0.1,
                                color: const Color(0xFF003579),
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

                        // Vehicle details wel time remaining
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 31),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          constraints: const BoxConstraints(maxWidth: 335 + 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Vehicle details
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.saira(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                        height: 1,
                                        letterSpacing: 0.1,
                                        color: const Color(0xFF8D1113),
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'BMW',
                                          style: TextStyle(
                                            fontSize: 24,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' - ',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'M4',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 22, left: 14),
                                    child: Text(
                                      'Color',
                                      style: GoogleFonts.saira(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        height: 1,
                                        letterSpacing: 0.1,
                                        color: const Color(0xFF003579),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Time
                              Container(
                                padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFF8D1113),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/clock.png',
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.contain,
                                      semanticLabel: 'Clock icon',
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '59 mins Left',
                                      style: GoogleFonts.saira(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Payment complete
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 25),
                          padding: const EdgeInsets.fromLTRB(45, 50, 45, 40),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                            color: const Color(0xFF003579),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Payment Complete',
                                style: GoogleFonts.saira(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  letterSpacing: 0.1,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              Container(
                                width: 36,
                                height: 36,
                                margin: const EdgeInsets.only(top: 20),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/check.png',
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.cover,
                                      semanticLabel:
                                          'Payment success checkmark',
                                    ),
                                    Container(
                                      width: 33,
                                      height: 33,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Card details
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 22),
                                padding:
                                    const EdgeInsets.fromLTRB(18, 15, 18, 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: const Color(0xFF2A2A2A),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'telda',
                                          style: GoogleFonts.alexandria(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            height: 1.2,
                                            letterSpacing: 0.1,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Image.asset(
                                          'assets/images/wifipay.png',
                                          width: 20,
                                          height: 20 / 0.37,
                                          fit: BoxFit.contain,
                                          semanticLabel: 'Card icon',
                                        ),
                                      ],
                                    ),
                                    Image.asset(
                                      'assets/images/telda.png',
                                      width: 200,
                                      height: 200,
                                      semanticLabel: 'Card number',
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                margin: const EdgeInsets.only(top: 30),
                                child: Text(
                                  'Card Used',
                                  style: GoogleFonts.saira(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                    letterSpacing: 0.1,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
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
            );
          },
        ),
      ),
    );
  }
}
