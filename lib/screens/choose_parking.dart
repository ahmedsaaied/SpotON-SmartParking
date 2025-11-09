// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_local_variable, unused_field, depend_on_referenced_packages
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spoton_app/screens/booking_comp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ChooseParkingScreen extends StatefulWidget {
  const ChooseParkingScreen({super.key});

  @override
  State<ChooseParkingScreen> createState() => _ChooseParkingScreenState();
}

class _ChooseParkingScreenState extends State<ChooseParkingScreen> {
  static const Color background = Color(0xFF838383);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color primary = Color(0xFF8D1113);
  static const Color grey = Color(0xFFC4C4C4);
  static const Color darkGrey = Color(0xFF6A6A6A);
  static const Color blue = Color(0xFF003579);
  static const Color green = Color(0xFF3ED034);
  static const Color red = Color(0xFFFF0004);
  static const Color yellow = Color(0xFFF7B801);

  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  TextStyle sairaRegular(double size, {Color? color}) => GoogleFonts.saira(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color ?? Colors.white);
  TextStyle sairaBold(double size, {Color? color}) => GoogleFonts.saira(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color ?? Colors.white);
  TextStyle sairaSemiBold(double size, {Color? color}) => GoogleFonts.saira(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color ?? Colors.white);
  TextStyle righteousRegular(double size, {Color? color}) =>
      GoogleFonts.righteous(
          fontSize: size,
          fontWeight: FontWeight.w400,
          color: color ?? Colors.white);
  TextStyle poppinsBold(double size,
          {Color? color, double letterSpacing = 1.0}) =>
      GoogleFonts.poppins(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: color ?? Colors.white,
          letterSpacing: letterSpacing);

  Future<void> _bookParking({
    required BuildContext context,
    required String title,
    required String capacity,
    required String image,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_selectedStartTime == null || _selectedEndTime == null) {
      Get.snackbar("Missing Time", "Please select start and end time",
          backgroundColor: red, colorText: white);
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final selectedStart = DateTime(
      today.year,
      today.month,
      today.day,
      _selectedStartTime!.hour,
      _selectedStartTime!.minute,
    );

    final selectedEnd = DateTime(
      today.year,
      today.month,
      today.day,
      _selectedEndTime!.hour,
      _selectedEndTime!.minute,
    );
    if (selectedEnd.isBefore(selectedStart)) {
      Get.snackbar("Invalid Time", "End time must be after start time.",
          backgroundColor: red, colorText: white);
      return;
    }
    // final earliestAllowed = DateTime(today.year, today.month, today.day, 8, 0);
    // final latestAllowed = DateTime(today.year, today.month, today.day, 20, 0);

    // if (selectedStart.isBefore(earliestAllowed) ||
    //     selectedEnd.isAfter(latestAllowed)) {
    //   Get.snackbar(
    //       "Invalid Time", "Bookings must be between 8:00 AM and 8:00 PM",
    //       backgroundColor: red, colorText: white);
    //   return;
    // }

    final diff = selectedStart.difference(now);

    if (diff.isNegative || diff.inMinutes > 60) {
      Get.snackbar(
          "Invalid Time", "Bookings must be within 1 hour of start time.",
          backgroundColor: red, colorText: white);
      return;
    }

    final formattedDate = DateFormat('EEEE, d/M/y').format(now);

    final usersRef = FirebaseFirestore.instance.collection('Users');
    final query =
        await usersRef.where('userId', isEqualTo: user.uid).limit(1).get();

    if (query.docs.isEmpty) {
      Get.snackbar("Error", "No user data found.",
          backgroundColor: red, colorText: white);
      return;
    }

    final userDoc = query.docs.first.reference;

    try {
      final config = await FirebaseFirestore.instance
          .collection('settings')
          .doc('config')
          .get();

      final allowMultiple = config.data()?['allowMultipleBookings'] ?? true;

      if (!allowMultiple) {
        final existing = await FirebaseFirestore.instance
            .collection('bookings')
            .where('userID', isEqualTo: user.uid)
            .where('status', isEqualTo: 'reserved')
            .get();

        if (existing.docs.isNotEmpty) {
          Get.snackbar("Booking Blocked", "Only one active booking allowed.",
              backgroundColor: red, colorText: white);
          return;
        }
      }

      final userSnap = await userDoc.get();
      if (!userSnap.exists) {
        Get.snackbar("Error", "No user data found.",
            backgroundColor: red, colorText: white);
        return;
      }

      final defaultCarId = userSnap.data()?['defaultCarId'];
      if (defaultCarId == null) {
        Get.snackbar("No Car", "Please set a default car.",
            backgroundColor: red, colorText: white);
        return;
      }

      final carSnap = await userDoc.collection('cars').doc(defaultCarId).get();

      if (!carSnap.exists) {
        Get.snackbar("No Car", "Default car not found.",
            backgroundColor: red, colorText: white);
        return;
      }

      final car = carSnap.data()!;

      final bookingRef =
          FirebaseFirestore.instance.collection('bookings').doc();

      final selectedExpiresAt = DateTime(
        today.year,
        today.month,
        today.day,
        _selectedEndTime!.hour,
        _selectedEndTime!.minute,
      );

      await bookingRef.set({
        'bookingId': bookingRef.id,
        'userID': user.uid,
        'car': car,
        'title': title,
        'capacity': capacity,
        'formattedDate': formattedDate,
        'startTime': Timestamp.fromDate(selectedStart),
        'estimatedEndTime': Timestamp.fromDate(selectedEnd),
        'timestamp': Timestamp.now(),
        'status': 'reserved',
      });

      Get.snackbar("Success", "Booking saved",
          backgroundColor: green, colorText: white);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => BookingComp(
                  selectedTitle: title,
                  selectedCapacity: capacity,
                  selectedImage: image,
                  bookingId: bookingRef.id,
                  car: car,
                  startTime: selectedStart,
                  estimatedEndTime:
                      "${_selectedEndTime!.hour}:${_selectedEndTime!.minute}",
                )),
      );
    } catch (e) {
      Get.snackbar("Error", "Booking failed: $e",
          backgroundColor: red, colorText: white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            _buildParkingOptions(context),
            _buildTimeSelectors(context),
            _buildRecentBookings(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelectors(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedStartTime == null
                    ? "Select Start Time"
                    : "Start: ${_selectedStartTime!.format(context)}",
                style: sairaRegular(14, color: white),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 31, 73),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: const Color.fromARGB(255, 0, 31, 73),
                          scaffoldBackgroundColor: white,
                          timePickerTheme: TimePickerThemeData(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 18, 18, 18),
                            dialHandColor: const Color.fromARGB(255, 0, 31, 73),
                            dialBackgroundColor:
                                const Color.fromARGB(255, 50, 50, 50),
                            hourMinuteTextColor: white,
                            hourMinuteShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            dayPeriodTextColor: white,
                            dayPeriodColor:
                                const Color.fromARGB(255, 120, 13, 13),
                            entryModeIconColor: white,
                            helpTextStyle: TextStyle(color: white),
                          ),
                          colorScheme: ColorScheme.light(
                            primary: const Color.fromARGB(255, 0, 31, 73),
                            onPrimary: white,
                            surface: const Color.fromARGB(255, 50, 50, 50),
                            onSurface: white,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: white,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedStartTime = picked;
                    });
                  }
                },
                child: const Text("Pick Start"),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedEndTime == null
                    ? "Select End Time"
                    : "End: ${_selectedEndTime!.format(context)}",
                style: sairaRegular(14, color: white),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 90, 13, 13),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: const Color.fromARGB(255, 0, 31, 73),
                          scaffoldBackgroundColor: white,
                          timePickerTheme: TimePickerThemeData(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 18, 18, 18),
                            dialHandColor: const Color.fromARGB(255, 0, 31, 73),
                            dialBackgroundColor:
                                const Color.fromARGB(255, 50, 50, 50),
                            hourMinuteTextColor: white,
                            hourMinuteShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            dayPeriodTextColor: white,
                            dayPeriodColor:
                                const Color.fromARGB(255, 120, 13, 13),
                            entryModeIconColor: white,
                            helpTextStyle: TextStyle(color: white),
                          ),
                          colorScheme: ColorScheme.light(
                            primary: const Color.fromARGB(255, 0, 31, 73),
                            onPrimary: white,
                            surface: const Color.fromARGB(255, 50, 50, 50),
                            onSurface: white,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: white,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedEndTime = picked;
                    });
                  }
                },
                child: const Text("Pick End"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(40, 60, 150, 35),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Image.asset(
                'assets/images/back.png',
                width: 17,
                height: 17,
                color: isDark ? Colors.white : null,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color.fromARGB(255, 22, 22, 22)
                  : const Color(0xFFC4C4C4),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : black,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'OFF',
                    style: righteousRegular(13,
                        color: isDark ? Colors.black : white),
                  ),
                ),
                const SizedBox(width: 0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Spot',
                    style: righteousRegular(24, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingOptions(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('settings')
          .doc('parkingAreas')
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return SizedBox(
            height: 230,
            child: Center(
              child: Text("No parking areas found", style: sairaRegular(14)),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final List<Map<String, dynamic>> areas = [];

        data.forEach((areaName, totalSpots) {
          areas.add({'name': areaName, 'totalSpots': totalSpots});
        });

        return Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: areas.map((area) {
              final title = area['name'];
              final total = area['totalSpots'];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('bookings')
                      .where('title', isEqualTo: title)
                      .where('status',
                          whereIn: ['reserved', 'in_progress']).get(),
                  builder: (context, bookingSnapshot) {
                    final imagePath = title.contains('CS')
                        ? 'assets/images/csbranch.png'
                        : 'assets/images/logistics.png';

                    String capacityText = "Loading...";
                    if (bookingSnapshot.hasData) {
                      final used = bookingSnapshot.data!.docs.length;
                      final percent =
                          ((used / total) * 100).clamp(0, 100).round();
                      capacityText = "$percent% Capacity";
                    }

                    return _buildParkingOptionCard(
                      context: context,
                      title: title,
                      capacity: capacityText,
                      imagePath: imagePath,
                      onTap: bookingSnapshot.hasData
                          ? () => _bookParking(
                                context: context,
                                title: title,
                                capacity: capacityText,
                                image: imagePath,
                              )
                          : () {},
                    );
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Widget _buildParkingOptionCard({ dy lessa bgrbhaa
  //   required BuildContext context,
  //   required String title,
  //   required String capacity,
  //   required String imagePath,
  //   required VoidCallback onTap,
  // }) {
  //   final isDark = Theme.of(context).brightness == Brightness.dark;

  //   return TweenAnimationBuilder(
  //     tween: Tween<double>(begin: 0, end: 1),
  //     duration: const Duration(milliseconds: 1500),
  //     curve: Curves.easeInOut,
  //     builder: (context, value, child) {
  //       return Opacity(
  //         opacity: value,
  //         child: Transform.translate(
  //           offset: Offset(0, 450 * (1 - value)),
  //           child: child,
  //         ),
  //       );
  //     },
  //     child: InkWell(
  //       onTap: onTap,
  //       borderRadius: BorderRadius.circular(12),
  //       child: Container(
  //         width: 175,
  //         height: 210,
  //         decoration: BoxDecoration(
  //           color: isDark ? const Color(0xFF1E1E1E) : white,
  //           borderRadius: BorderRadius.circular(12),
  //           boxShadow: [
  //             if (!isDark)
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.25),
  //                 blurRadius: 20,
  //                 offset: const Offset(6, 6),
  //                 spreadRadius: 2,
  //               ),
  //           ],
  //         ),
  //         padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(title,
  //                 style: sairaBold(14, color: isDark ? white : primary)),
  //             Padding(
  //               padding: const EdgeInsets.only(top: 12, left: 12),
  //               child: Text(capacity,
  //                   style: sairaRegular(14,
  //                       color: isDark ? Colors.grey[400] : darkGrey)),
  //             ),
  //             const SizedBox(height: 22),
  //             ClipRRect(
  //               borderRadius: BorderRadius.circular(10),
  //               child: Stack(
  //                 children: [
  //                   Image.asset(
  //                     imagePath,
  //                     width: double.infinity,
  //                     height: 100,
  //                     fit: BoxFit.cover,
  //                   ),
  //                   if (isDark)
  //                     Container(
  //                       width: double.infinity,
  //                       height: 100,
  //                       color: Colors.black.withOpacity(0.3),
  //                     ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildParkingOptionCard({
    required BuildContext context,
    required String title,
    required String capacity,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 175,
        height: 210,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(6, 6),
                spreadRadius: 2,
              ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: sairaBold(14, color: isDark ? white : primary)),
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 12),
              child: Text(capacity,
                  style: sairaRegular(14,
                      color: isDark ? Colors.grey[400] : darkGrey)),
            ),
            const SizedBox(height: 22),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  if (isDark)
                    Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.black.withOpacity(0.3),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookings(BuildContext context, bool isDark) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final bookingsRef = FirebaseFirestore.instance
        .collection('bookings')
        .where('userID', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true);

    return Container(
      margin: const EdgeInsets.only(top: 19.142),
      padding: const EdgeInsets.only(top: 25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Bookings',
                    style: poppinsBold(15,
                        color: isDark ? Colors.white : primary)),
                Text('View All',
                    style: poppinsBold(10,
                        color: isDark ? Colors.grey[300] : black)),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: isDark ? const Color.fromARGB(255, 0, 31, 73) : blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            width: 385,
            height: 260,
            child: StreamBuilder<QuerySnapshot>(
              stream: bookingsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("No bookings yet",
                        style: sairaRegular(14, color: white)),
                  );
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                    itemCount: bookings.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final doc = bookings[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final title = data['title'] ?? 'Unknown';
                      final timestamp = data['timestamp'] as Timestamp?;
                      final startTime =
                          (data['startTime'] as Timestamp?)?.toDate();
                      final expiresAt =
                          (data['expiresAt'] as Timestamp?)?.toDate();

                      String status = data['status'] ?? 'reserved';

                      final date = timestamp?.toDate() ?? DateTime.now();
                      final day = date.day;
                      final month = _getMonthAbbreviation(date.month);

                      final Color statusColor = switch (status) {
                        'expired' => Colors.grey,
                        'completed' =>
                          isDark ? const Color.fromARGB(255, 0, 170, 3) : green,
                        'cancelled' =>
                          isDark ? const Color.fromARGB(255, 170, 0, 3) : red,
                        _ => yellow,
                      };
                      // Add this right before calling _buildBookingItem
                      final rawEndTime = data['estimatedEndTime'];
                      DateTime? estimatedEndTime;

                      if (rawEndTime is Timestamp) {
                        estimatedEndTime = rawEndTime.toDate();
                      } else if (rawEndTime is String) {
                        try {
                          final parts = rawEndTime.split(":");
                          final hour = int.parse(parts[0]);
                          final minute = int.parse(parts[1]);
                          estimatedEndTime = DateTime(
                            startTime!.year,
                            startTime.month,
                            startTime.day,
                            hour,
                            minute,
                          );
                        } catch (_) {
                          estimatedEndTime = null;
                        }
                      } else {
                        estimatedEndTime = null;
                      }

                      return _buildBookingItem(
                        context: context,
                        day: day,
                        month: month,
                        location: '$title\nCar Parking Area',
                        statusLabel: status,
                        statusColor: statusColor,
                        bookingId: doc.id,
                        startTime: startTime,
                        estimatedEndTime: estimatedEndTime,
                        car: data['car'],
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sept',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildBookingItem({
    required BuildContext context,
    required int day,
    required String month,
    required String location,
    required String statusLabel,
    required Color statusColor,
    required String bookingId,
    required DateTime? startTime,
    required DateTime? estimatedEndTime,
    required Map<String, dynamic> car,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$day', style: poppinsBold(27, color: Colors.white)),
              Text(month, style: poppinsBold(7, color: Colors.white)),
            ],
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                location,
                style: poppinsBold(10, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    statusLabel == 'in_progress'
                        ? 'In Progress'
                        : statusLabel[0].toUpperCase() +
                            statusLabel.substring(1),
                    style: poppinsBold(12, color: statusColor),
                  ),
                  const SizedBox(width: 9),
                  GestureDetector(
                    onTap: () async {
                      final now = DateTime.now();
                      String status = statusLabel;

                      final endTime = estimatedEndTime;

                      _showBookingDetailsDialog(
                        context,
                        bookingId: bookingId,
                        status: status,
                        estimatedEndTime: estimatedEndTime,
                        startTime: startTime ?? now,
                        car: car,
                      );
                    },
                    child: Image.asset(
                      'assets/images/info.png',
                      width: 25,
                      height: 25,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDetailsDialog(
    BuildContext context, {
    required String bookingId,
    required String status,
    required DateTime? estimatedEndTime,
    required DateTime startTime,
    required Map<String, dynamic> car,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime? endDateTime = estimatedEndTime;
    if (endDateTime == null) return;

    Duration timeLeft = endDateTime.difference(DateTime.now());

    // If booking already expired, show inactive dialog directly
    if (timeLeft.isNegative) {
      showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Booking Details",
                        style: poppinsBold(18,
                            color: isDark ? Colors.white : blue)),
                    const SizedBox(height: 20),
                    Text(
                      "This booking is no longer active.",
                      style: sairaSemiBold(14,
                          color: isDark ? Colors.grey[400] : Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
      return;
    }

    // Normal active dialog with QR + countdown
    Timer? countdownTimer;
    bool dialogIsOpen = true;

    void cancelTimer() {
      countdownTimer?.cancel();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final showQR = status == 'reserved' || status == 'in_progress';
            final allowCancelAndExtend = status == 'reserved';

            if (showQR && countdownTimer == null) {
              countdownTimer =
                  Timer.periodic(const Duration(seconds: 1), (timer) {
                final remaining = endDateTime!.difference(DateTime.now());
                if (!dialogIsOpen) {
                  timer.cancel();
                  return;
                }
                if (remaining.isNegative) {
                  timer.cancel();
                  if (dialogIsOpen) {
                    dialogIsOpen = false;
                    Navigator.of(context).pop();
                  }
                } else {
                  setState(() {
                    timeLeft = remaining;
                  });
                }
              });
            }

            String formatTime(Duration duration) {
              final minutes = duration.inMinutes;
              final seconds = duration.inSeconds % 60;
              return '$minutes:${seconds.toString().padLeft(2, '0')} mins Left';
            }

            return WillPopScope(
              onWillPop: () async {
                dialogIsOpen = false;
                cancelTimer();
                return true;
              },
              child: Dialog(
                backgroundColor:
                    isDark ? const Color(0xFF1E1E1E) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: showQR ? (allowCancelAndExtend ? 480 : 380) : 200,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text("Booking Details",
                              style: poppinsBold(18,
                                  color: isDark ? Colors.white : blue)),
                          const SizedBox(height: 20),
                          if (showQR) ...[
                            QrImageView(
                              data: jsonEncode({
                                'userId':
                                    FirebaseAuth.instance.currentUser?.uid,
                                'bookingId': bookingId,
                                'car': {
                                  'brand': car['brand'],
                                  'model': car['model'],
                                  'color': car['color'],
                                  'plateLetters': car['plateLetters'],
                                  'plateNumbers': car['plateNumbers'],
                                },
                                'timestamp':
                                    Timestamp.now().toDate().toIso8601String(),
                                'estimatedEndTime': estimatedEndTime
                                    ?.toIso8601String(), // <-- fix here
                              }),
                              size: 220,
                              backgroundColor:
                                  isDark ? Colors.white : Colors.transparent,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/images/clock.png',
                                      width: 24,
                                      height: 24,
                                      color: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(formatTime(timeLeft),
                                      style: sairaSemiBold(14,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          if (allowCancelAndExtend) ...[
                            ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('bookings')
                                    .doc(bookingId)
                                    .update({'status': 'cancelled'});
                                dialogIsOpen = false;
                                cancelTimer();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Cancel Booking"),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              // Inside _showBookingDetailsDialog -> StatefulBuilder -> ElevatedButton
                              onPressed: () async {
                                endDateTime = endDateTime!
                                    .add(const Duration(minutes: 10));

                                // CORRECTED: Update Firestore with a Timestamp, not a String
                                await FirebaseFirestore.instance
                                    .collection('bookings')
                                    .doc(bookingId)
                                    .update({
                                  'estimatedEndTime':
                                      Timestamp.fromDate(endDateTime!),
                                });

                                timeLeft =
                                    endDateTime!.difference(DateTime.now());
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Extend +10 Minutes"),
                            ),
                          ],
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      dialogIsOpen = false;
      cancelTimer();
    });
  }
}
