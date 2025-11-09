// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spoton_app/screens/add_card.dart';
import 'package:spoton_app/screens/payment_complete.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  final List<Color> cardColors = [
    Colors.deepPurple,
    Colors.indigo,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.pink,
    Colors.brown,
    Colors.blueGrey,
  ];

  final Map<String, double> _dragOffsets = {};
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, Animation<double>> _animations = {};
  final Map<String, Timer?> _holdTimers = {};

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    for (var timer in _holdTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  void _animateBack(String cardId) {
    final controller = _animationControllers[cardId];
    if (controller == null) return;

    final currentOffset = _dragOffsets[cardId] ?? 0.0;

    final animation = Tween<double>(
      begin: currentOffset,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    _animations[cardId] = animation;
    controller.reset();
    controller.forward();
  }

  void _startHoldTimer(String cardId, bool isDelete) {
    _holdTimers[cardId]?.cancel();

    _holdTimers[cardId] = Timer(const Duration(milliseconds: 150), () async {
      if (isDelete) {
        HapticFeedback.heavyImpact();
        final controller = _animationControllers[cardId];
        final animation = Tween<double>(
          begin: _dragOffsets[cardId] ?? 0,
          end: -500,
        ).animate(CurvedAnimation(
          parent: controller!,
          curve: Curves.easeIn,
        ));
        _animations[cardId] = animation;
        controller.reset();
        controller.forward().whenComplete(() async {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('Cards')
              .doc(cardId)
              .delete();
        });
      } else {
        HapticFeedback.mediumImpact();
        _animateBack(cardId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentComp(),
          ),
        );
      }
    });
  }

  void _cancelHoldTimer(String cardId) {
    _holdTimers[cardId]?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 131, 131, 131),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.only(top: 90),
                  child: Text(
                    'Add a card',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.saira(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 2,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      padding: const EdgeInsets.only(top: 55),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 350,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('Cards')
                                  .orderBy('createdAt', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                final cards = snapshot.data!.docs;

                                return PageView.builder(
                                  controller: _pageController,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: cards.length,
                                  itemBuilder: (context, index) {
                                    final cardDoc = cards[index];
                                    final card =
                                        cardDoc.data() as Map<String, dynamic>;
                                    final cardId = cardDoc.id;
                                    final cardNumber =
                                        card['cardNumber'] ?? '•••• XXXX';
                                    final color =
                                        cardColors[index % cardColors.length];

                                    _dragOffsets.putIfAbsent(cardId, () => 0.0);
                                    _animationControllers.putIfAbsent(
                                      cardId,
                                      () => AnimationController(
                                        vsync: this,
                                        duration:
                                            const Duration(milliseconds: 300),
                                      )..addListener(() {
                                          setState(() {
                                            _dragOffsets[cardId] =
                                                _animations[cardId]?.value ??
                                                    0.0;
                                          });
                                        }),
                                    );

                                    double scale = 1.0;
                                    if (_pageController
                                        .position.haveDimensions) {
                                      final pageOffset =
                                          _pageController.page ?? 0.0;
                                      final distance =
                                          (pageOffset - index).abs();
                                      scale =
                                          (1 - distance * 0.3).clamp(0.85, 1.0);
                                    }

                                    final dragOffset =
                                        _dragOffsets[cardId] ?? 0.0;

                                    return Center(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          if (dragOffset > 2)
                                            Positioned(
                                              top: 15,
                                              child: Opacity(
                                                opacity: ((dragOffset - 15))
                                                    .clamp(0.0, 1.0),
                                                child: Text(
                                                  'Hold to Pay',
                                                  style: GoogleFonts.saira(
                                                    fontSize: 16,
                                                    color:
                                                        Colors.green.shade700,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (dragOffset < -2)
                                            Positioned(
                                              bottom: 10,
                                              child: Opacity(
                                                opacity: ((-dragOffset - 15))
                                                    .clamp(0.0, 1.0),
                                                child: Text(
                                                  'Hold to Delete',
                                                  style: GoogleFonts.saira(
                                                    fontSize: 16,
                                                    color: Colors.red.shade700,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          GestureDetector(
                                            onVerticalDragUpdate: (details) {
                                              final newOffset = (dragOffset +
                                                      details.delta.dy * 0.15)
                                                  .clamp(-10.0, 10.0);
                                              setState(() {
                                                _dragOffsets[cardId] =
                                                    dragOffset +
                                                        details.delta.dy * 0.25;
                                              });

                                              if (newOffset > 1) {
                                                _startHoldTimer(
                                                    cardId, false); // Pay
                                              } else if (newOffset < -1) {
                                                _startHoldTimer(
                                                    cardId, true); // Delete
                                              } else {
                                                _cancelHoldTimer(
                                                    cardId); // cancel lw m3mlsh hold
                                              }
                                            },
                                            onVerticalDragEnd: (_) {
                                              _cancelHoldTimer(cardId);
                                              _animateBack(cardId);
                                            },
                                            child: Transform.translate(
                                              offset: Offset(0, dragOffset),
                                              child: Transform.scale(
                                                scale: scale,
                                                child: _buildCreditCard(
                                                  context,
                                                  offset: Offset(0, dragOffset),
                                                  scale: scale,
                                                  opacity: 1,
                                                  color: color,
                                                  cardNumber: cardNumber,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 52.07),
                            padding: const EdgeInsets.fromLTRB(23, 40, 23, 20),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              color: Color(0xFF003579),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '50 EGP',
                                      style: GoogleFonts.saira(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Text(
                                        'View Details',
                                        style: GoogleFonts.saira(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white,
                                          height: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PaymentComp(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(17, 1, 17, 1),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(19),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Pay Now',
                                          style: GoogleFonts.alexandria(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            height: 2,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        Image.asset(
                                          'assets/images/right-arrow.png',
                                          width: 16,
                                          height: 16,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 5,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddCard(),
                            ),
                          );
                        },
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.25),
                                blurRadius: 20,
                                offset: Offset(0, 3),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/plus.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCreditCard(
    BuildContext context, {
    required Offset offset,
    required double scale,
    required double opacity,
    required Color color,
    required String cardNumber,
  }) {
    return Transform.translate(
      offset: offset,
      child: Opacity(
        opacity: opacity,
        child: SizedBox(
          width: 320,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.8),
                  color.withOpacity(0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      cardNumber,
                      style: GoogleFonts.robotoMono(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 39.5, 150, 25),
      decoration: const BoxDecoration(
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
          Semantics(
            button: true,
            label: 'Go back',
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.asset(
                  'assets/images/back.png',
                  width: 17,
                  height: 17,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.all(0),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'OFF',
                    style: GoogleFonts.righteous(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 0),
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
        ],
      ),
    );
  }
}
