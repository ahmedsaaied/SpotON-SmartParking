// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spoton_app/screens/add_car.dart';
import 'package:spoton_app/screens/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spoton_app/screens/map_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spoton_app/screens/guest_booking.dart';
import 'package:spoton_app/screens/choose_parking.dart';

class Car {
  final String id;
  final String make;
  final String model;
  final String color;
  final String plateLetters;
  final String plateNumbers;

  Car({
    required this.id,
    required this.make,
    required this.model,
    required this.color,
    required this.plateLetters,
    required this.plateNumbers,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _blueRectangleBottom = -350;
  double _greyRectangleBottom = -550;
  double _whiteRectangleBottom = -780;

  List<Car> userCars = [];
  String? defaultCarId;

  String? distanceToGarage;
  String? etaToGarage;

  int currentOccupancy = 0;
  final int totalCapacity = 50;
  Timer? capacityTimer;

  @override
  void initState() {
    super.initState();
    _loadUserCars();
    _getCurrentOccupancy();
    _calculateDistanceToGarage();
    capacityTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _getCurrentOccupancy();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _blueRectangleBottom = 0);
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _greyRectangleBottom = 0);
      });

      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _whiteRectangleBottom = 0);
      });
    });
  }

  Future<void> _calculateDistanceToGarage() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final userLat = position.latitude;
    final userLng = position.longitude;

    const garageLat = 30.095571;
    const garageLng = 31.374697;

    const apiKey = "YOUR_API_KEY_HERE"; // placeholder

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/distancematrix/json"
      "?units=metric"
      "&origins=$userLat,$userLng"
      "&destinations=$garageLat,$garageLng"
      "&key=$apiKey",
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    final rows = data['rows'] as List<dynamic>?;
    if (rows == null || rows.isEmpty) {
      return;
    }

    final elements = rows[0]['elements'] as List<dynamic>?;
    if (elements == null || elements.isEmpty) {
      return;
    }

    final element = elements[0];
    if (element['status'] != 'OK') {
      return;
    }

    final distanceText = element['distance']['text'];
    final durationText = element['duration']['text'];

    if (mounted) {
      setState(() {
        distanceToGarage = distanceText;
        etaToGarage = durationText;
      });
    }

    print("✅ Distance to garage: $distanceText");
  }

  Future<void> _getCurrentOccupancy() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('status', whereIn: ['reserved', 'in_progress']).get();

    if (mounted) {
      setState(() {
        currentOccupancy = snapshot.docs.length;
      });
    }
  }

  Future<void> _loadUserCars() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final usersRef = FirebaseFirestore.instance.collection('Users');
    final userQuery =
        await usersRef.where('userId', isEqualTo: uid).limit(1).get();

    if (userQuery.docs.isEmpty) {
      return;
    }

    final userDocRef = userQuery.docs.first.reference;
    final userData = userQuery.docs.first.data();
    defaultCarId = userData['defaultCarId'] as String?;

    final carSnap = await userDocRef.collection('cars').get();
    final cars = carSnap.docs.map((doc) {
      final d = doc.data();
      return Car(
        id: doc.id,
        make: d['brand'] ?? '',
        model: d['model'] ?? '',
        color: d['color'] ?? '',
        plateLetters: d['plateLetters'] ?? '',
        plateNumbers: d['plateNumbers'] ?? '',
      );
    }).toList();

    if (mounted) {
      setState(() {
        userCars = cars;
      });
    }
  }

  Future<void> _setDefaultCar(String carId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

    await userDoc.update({'defaultCarId': carId});

    if (mounted) {
      setState(() {
        defaultCarId = carId;
      });
    }
  }

  @override
  void dispose() {
    capacityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit the app?'),
            backgroundColor: Theme.of(context).cardColor,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 150),
                        ],
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        bottom: _whiteRectangleBottom,
                        left: 0,
                        right: 0,
                        child: _buildBookingCard(context),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        bottom: _greyRectangleBottom,
                        left: 0,
                        right: 0,
                        child: _buildVehiclesSection(context),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        bottom: _blueRectangleBottom,
                        left: 0,
                        right: 0,
                        child: _buildGuestBookingSection(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 20, 13, 35),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Hero(
            tag: 'spotLogo',
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.brightness ==
                          Brightness.dark
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
                        color: Theme.of(context).colorScheme.brightness ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'OFF',
                        style: GoogleFonts.righteous(
                          color: Theme.of(context).colorScheme.brightness ==
                                  Brightness.dark
                              ? Colors.black
                              : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Spot',
                        style: GoogleFonts.righteous(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (mounted) {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const SettingsPage()),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.brightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  width: 1,
                ),
              ),
              child: Text(
                'AS',
                style: GoogleFonts.roboto(
                  color: Theme.of(context).colorScheme.brightness ==
                          Brightness.dark
                      ? Colors.white
                      : const Color(0xFF003579),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context) {
    final capacityPercentage =
        ((currentOccupancy / totalCapacity) * 100).clamp(0, 100).toInt();
    final progressValue = (currentOccupancy / totalCapacity).clamp(0.0, 1.0);
    final isHigh = progressValue >= 0.8;
    final capacityColor = isHigh
        ? Colors.red
        : Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 0, 122, 255)
            : const Color(0xFF003579);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 490),
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 50),
      constraints: const BoxConstraints(maxWidth: 370),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 20,
            offset: Offset(0, 3),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Bookings Near You',
                    style: GoogleFonts.saira(
                      color: Theme.of(context).colorScheme.brightness ==
                              Brightness.dark
                          ? const Color.fromARGB(220, 255, 255, 255)
                          : Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 15),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'AASTMT',
                          style: GoogleFonts.saira(
                            color: Theme.of(context).colorScheme.brightness ==
                                    Brightness.dark
                                ? const Color.fromARGB(255, 0, 75, 175)
                                : const Color(0xFF003579),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: ' - ',
                          style: GoogleFonts.saira(
                            color: Theme.of(context).colorScheme.brightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: 'Sheraton',
                          style: GoogleFonts.saira(
                            color: Theme.of(context).colorScheme.brightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapRouteScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 55),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 160, 160, 160)
                        : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    distanceToGarage != null && etaToGarage != null
                        ? '$distanceToGarage • $etaToGarage'
                        : '...',
                    style: GoogleFonts.russoOne(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: progressValue,
                  ),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 3,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isHigh ? Colors.red : capacityColor,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  '$capacityPercentage% Capacity',
                  style: GoogleFonts.saira(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(180, 255, 255, 255)
                        : const Color.fromARGB(199, 61, 61, 61),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (_) => const ChooseParkingScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.brightness == Brightness.dark
                      ? const Color.fromARGB(255, 90, 13, 13)
                      : const Color(0xFF8D1113),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
              minimumSize: const Size(double.infinity, 0),
            ),
            child: Text(
              'Book Now',
              style: GoogleFonts.saira(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 255),
      padding: const EdgeInsets.fromLTRB(19, 20, 19, 30),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2B2B2B)
            : const Color(0xFFDADADA),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Vehicles',
            style: GoogleFonts.saira(
              color: Theme.of(context).colorScheme.brightness == Brightness.dark
                  ? const Color.fromARGB(220, 255, 255, 255)
                  : const Color(0xFF003579),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 180),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...userCars.map((car) => Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: _buildVehicleCard(
                          id: car.id,
                          make: car.make,
                          model: car.model,
                          color: car.color,
                          plateNumbers: car.plateNumbers,
                          plateLetters: car.plateLetters,
                        ),
                      )),
                  _buildAddVehicleButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddVehicleButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const AddCarScreen()),
          );
          await _loadUserCars();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            children: [
              Container(
                width: 30,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.brightness ==
                            Brightness.dark
                        ? Colors.white
                        : const Color(0xFF003579),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '+',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Add a Car',
                style: GoogleFonts.saira(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.brightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard({
    required String id,
    required String make,
    required String model,
    required String color,
    required String plateLetters,
    required String plateNumbers,
  }) {
    final isDefault = defaultCarId == id;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(15, 10, 130, 10),
          decoration: BoxDecoration(
            color: isDefault
                ? Theme.of(context).colorScheme.brightness == Brightness.dark
                    ? const Color.fromARGB(255, 120, 120, 120)
                    : Colors.lightGreen[100]
                : Theme.of(context).colorScheme.brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  make.isNotEmpty ? make[0].toUpperCase() : '?',
                  style: GoogleFonts.saira(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text('$make - $model',
                  style: GoogleFonts.saira(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.brightness ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black)),
              Text(color,
                  style: GoogleFonts.saira(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.brightness ==
                              Brightness.dark
                          ? const Color.fromARGB(120, 255, 255, 255)
                          : const Color.fromARGB(200, 88, 88, 88))),
              const SizedBox(height: 12),
              _buildLicensePlate(plateNumbers, plateLetters),
            ],
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => _setDefaultCar(id),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.brightness == Brightness.dark
                        ? Colors.transparent
                        : Colors.white,
                border: Border.all(
                  color: isDefault
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.star,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLicensePlate(String numbers, String letters) {
    return Container(
      width: 95,
      decoration: BoxDecoration(
        color: const Color(0xFFDADADA),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('EGYPT',
                    style:
                        GoogleFonts.saira(color: Colors.white, fontSize: 13)),
                Text('مصر',
                    style:
                        GoogleFonts.saira(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      numbers,
                      style: GoogleFonts.saira(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.black,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      letters,
                      style: GoogleFonts.saira(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
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

  Widget _buildGuestBookingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(11, 20, 11, 15),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 0, 31, 73)
            : const Color(0xFF003579),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guest Booking',
            style: GoogleFonts.saira(
              color: Theme.of(context).colorScheme.brightness == Brightness.dark
                  ? const Color.fromARGB(220, 255, 255, 255)
                  : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(80, 0, 0, 0),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1,
                    size: 40,
                    color: Theme.of(context).colorScheme.brightness ==
                            Brightness.dark
                        ? const Color.fromARGB(180, 255, 255, 255)
                        : const Color(0xFF003579)),
                const SizedBox(height: 10),
                Text(
                  'Book a Spot for a Guest',
                  style: GoogleFonts.saira(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.brightness ==
                            Brightness.dark
                        ? const Color.fromARGB(180, 255, 255, 255)
                        : const Color(0xFF003579),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (_) => const AddVisitorCarScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.brightness ==
                            Brightness.dark
                        ? const Color.fromARGB(255, 90, 13, 13)
                        : const Color(0xFF8D1113),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 40),
                  ),
                  child: Text(
                    'Book Now',
                    style: GoogleFonts.saira(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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
}
