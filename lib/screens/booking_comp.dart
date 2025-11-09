// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingComp extends StatefulWidget {
  final String selectedTitle;
  final String selectedCapacity;
  final String selectedImage;
  final String bookingId;
  final Map<String, dynamic> car;
  final DateTime startTime;
  final String estimatedEndTime;

  const BookingComp({
    super.key,
    required this.selectedTitle,
    required this.selectedCapacity,
    required this.selectedImage,
    required this.bookingId,
    required this.car,
    required this.startTime,
    required this.estimatedEndTime,
  });

  @override
  State<BookingComp> createState() => _BookingCompState();
}

class _BookingCompState extends State<BookingComp> {
  Timer? countdownTimer;
  DateTime? _endTime;
  Duration timeLeft = Duration.zero;
  String qrData = '';

  @override
  void initState() {
    super.initState();
    _parseEndTime();
    startTimer();
  }

  void _parseEndTime() {
    try {
      final parts = widget.estimatedEndTime.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      _endTime = DateTime(
        widget.startTime.year,
        widget.startTime.month,
        widget.startTime.day,
        hour,
        minute,
      );

      if (_endTime!.isBefore(widget.startTime)) {
        _endTime = _endTime!.add(const Duration(days: 1));
      }

      timeLeft = _endTime!.difference(DateTime.now());
      updateQrCode();
    } catch (_) {
      _endTime = null;
    }
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted || _endTime == null) return;

      final now = DateTime.now();
      final remaining = _endTime!.difference(now);

      if (remaining.isNegative) {
        timer.cancel();
        await _expireBookingIfNeeded();
        if (mounted) setState(() => timeLeft = Duration.zero);
      } else {
        setState(() => timeLeft = remaining);
        if (remaining.inMinutes % 1 == 0) updateQrCode();
      }
    });
  }

  Future<void> _expireBookingIfNeeded() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final bookingRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Bookings')
        .doc(widget.bookingId);

    final doc = await bookingRef.get();
    if (doc.exists && doc['status'] == 'in_progress') {
      await bookingRef.update({'status': 'expired'});
    }
  }

  void updateQrCode() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _endTime == null) return;

    final qrPayload = {
      "userId": user.uid,
      "bookingId": widget.bookingId,
      "car": {
        "brand": widget.car["brand"] ?? '',
        "model": widget.car["model"] ?? '',
        "color": widget.car["color"] ?? '',
        "plateLetters": widget.car["plateLetters"] ?? '',
        "plateNumbers": widget.car["plateNumbers"] ?? '',
      },
      "timestamp": DateTime.now().toIso8601String(),
      "estimatedEndTime": widget.estimatedEndTime
    };

    setState(() {
      qrData = jsonEncode(qrPayload);
    });
  }

  String get timerText {
    final minutes = timeLeft.inMinutes;
    final seconds = timeLeft.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')} mins Left';
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Color _getColor(String? name) {
    switch (name?.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gray':
        return Colors.grey;
      case 'yellow':
        return Colors.yellow;
      case 'gold':
        return const Color(0xFFFFD700);
      case 'orange':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFF838383);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(cardColor),
          _buildQrAndCard(cardColor, isDark),
          _buildBottomSection(cardColor, isDark, textColor),
        ],
      ),
    );
  }

  Widget _buildHeader(Color cardColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(27, 50, 27, 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 3, 3, 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: const Color(0xFF003579),
            ),
            child: Row(
              children: [
                Text(
                  'Spot',
                  style: GoogleFonts.righteous(
                    fontSize: 40,
                    color: Colors.white,
                    height: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 45,
                  height: 45,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white,
                  ),
                  child: Text(
                    'ON',
                    style: GoogleFonts.righteous(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrAndCard(Color cardColor, bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, 165),
          child: Container(
            width: 160,
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: cardColor,
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 145,
              backgroundColor: Colors.transparent,
              foregroundColor:
                  isDark ? const Color(0xDCFFFFFF) : const Color(0xFF001F49),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -8),
          child: Container(
            width: 245,
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: cardColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedTitle,
                  style: GoogleFonts.saira(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey[100] : const Color(0xFF8D1113),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    widget.selectedCapacity,
                    style: GoogleFonts.saira(
                      fontSize: 14,
                      color:
                          isDark ? Colors.grey[500] : const Color(0xFF6A6A6A),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    widget.selectedImage,
                    width: double.infinity,
                    height: 130,
                    fit: BoxFit.cover,
                    colorBlendMode: isDark ? BlendMode.darken : null,
                    color: isDark ? Colors.black.withOpacity(0.3) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(Color cardColor, bool isDark, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(top: 155),
      padding: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.saira(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.grey[300] : const Color(0xFF003579),
              ),
              children: const [
                TextSpan(text: 'Your Spot is now '),
                TextSpan(
                  text: 'ON',
                  style: TextStyle(color: Color(0xFF8B1214)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color.fromARGB(255, 90, 13, 13),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/clock.png',
                    width: 24, height: 24, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  timerText,
                  style: GoogleFonts.saira(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildCarDetails(isDark, textColor),
          const SizedBox(height: 20),
          _buildBookingCompleteBanner(isDark),
        ],
      ),
    );
  }

  Widget _buildCarDetails(bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Car Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.saira(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8D1113),
                  ),
                  children: [
                    TextSpan(
                      text: (widget.car['brand'] ?? '').toUpperCase(),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const TextSpan(
                      text: ' - ',
                      style: TextStyle(fontSize: 19, color: Colors.black),
                    ),
                    TextSpan(
                      text: widget.car['model'] ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text('Color',
                      style: GoogleFonts.saira(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white
                            : const Color.fromARGB(255, 0, 31, 73),
                      )),
                  const SizedBox(width: 7),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getColor(widget.car['color']),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Plate
          _buildPlateWidget(isDark, textColor),
        ],
      ),
    );
  }

  Widget _buildPlateWidget(bool isDark, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color.fromARGB(255, 60, 60, 60)
            : const Color(0xFFDADADA),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color.fromARGB(255, 0, 52, 120)
                  : const Color(0xFF0055C4),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Text('EGYPT',
                    style: GoogleFonts.alexandria(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    )),
                const SizedBox(width: 8),
                Text('مصر',
                    style: GoogleFonts.alexandria(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    )),
              ],
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(widget.car['plateNumbers'] ?? '',
                    style: GoogleFonts.alexandria(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    )),
              ),
              Container(
                width: 1,
                height: 33,
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(widget.car['plateLetters'] ?? '',
                    style: GoogleFonts.alexandria(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCompleteBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 110.6, vertical: 46.07),
      decoration: BoxDecoration(
        color: isDark
            ? const Color.fromARGB(255, 0, 31, 73)
            : const Color(0xFF003579),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child:
                  Image.asset('assets/images/check.png', width: 20, height: 20),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            'Booking Complete',
            style: GoogleFonts.saira(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
