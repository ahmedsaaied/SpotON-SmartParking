import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCard extends StatefulWidget {
  const AddCard({super.key});

  @override
  State<AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  bool _saveCardForFuture = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final expiryDateFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
    final text = newValue.text;
    if (text.length == 2 && !text.contains('/')) {
      return TextEditingValue(
        text: '$text/',
        selection: TextSelection.collapsed(offset: 3),
      );
    }
    return newValue;
  });

  final cardNumberFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if ((i + 1) % 4 == 0 && i != digits.length - 1) buffer.write(' ');
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  });

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_saveCardForFuture) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final rawNumber = _cardNumberController.text.replaceAll(' ', '');
    final last4 = rawNumber.substring(rawNumber.length - 4);
    final maskedNumber = '•••• $last4';

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Cards')
        .add({
      'cardNumber': maskedNumber,
      'createdAt': Timestamp.now(),
      'isDefault': false,
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 131, 131, 131),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // header
                  Container(
                    padding: const EdgeInsets.fromLTRB(200, 40, 200, 60),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      color: Colors.white,
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/images/back.png', width: 40),
                    ),
                  ),

                  // Card over header
                  Positioned(
                    top: 90,
                    left: 23,
                    right: 23,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(9, 5, 9, 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color.fromRGBO(102, 0, 170, 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/images/qnb.png',
                              color: Colors.white, width: 120),
                          const SizedBox(height: 10),
                          Image.asset('assets/images/chip.png', width: 55),
                          const SizedBox(height: 8),
                          Text(
                            _cardNumberController.text.length >= 4
                                ? '**** **** **** ${_cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.replaceAll(' ', '').length - 4)}'
                                : '**** **** **** 1234',
                            style: GoogleFonts.alexandria(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('VALID THRU',
                                      style: GoogleFonts.alexandria(
                                          fontSize: 7, color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text(
                                    _nameController.text.isEmpty
                                        ? 'Name on Card'
                                        : _nameController.text,
                                    style: GoogleFonts.slabo13px(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Exp. Date',
                                      style: GoogleFonts.alexandria(
                                          fontSize: 10, color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text(
                                    _expiryDateController.text.isEmpty
                                        ? 'MM/YY'
                                        : _expiryDateController.text,
                                    style: GoogleFonts.alexandria(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ],
                              ),
                              Image.asset('assets/images/visa.png',
                                  width: 50, color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 250), // mkan elcard 3la elscreen

              // form el add card
              Container(
                padding: const EdgeInsets.fromLTRB(23, 19, 23, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Card Number'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          cardNumberFormatter,
                        ],
                        validator: (value) {
                          final clean = value?.replaceAll(' ', '');
                          if (clean == null || clean.length != 16) {
                            return 'Card number must be 16 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryDateController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9/]')),
                                expiryDateFormatter,
                              ],
                              decoration: const InputDecoration(
                                  labelText: 'Expiry Date'),
                              validator: (value) {
                                if (value == null ||
                                    !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                                  return 'Use format MM/YY';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              obscureText: true,
                              obscuringCharacter: '*',
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              decoration: const InputDecoration(
                                  labelText: 'CVV', counterText: ''),
                              validator: (value) {
                                if (value == null || value.length != 3) {
                                  return '3-digit CVV';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(labelText: 'Name on Card'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter cardholder name'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        value: _saveCardForFuture,
                        title: Text(
                          'Securely save card for future payments',
                          style: GoogleFonts.saira(fontSize: 12),
                        ),
                        onChanged: (val) =>
                            setState(() => _saveCardForFuture = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/images/visa.png', width: 60),
                          Image.asset('assets/images/mastercard.png',
                              width: 60),
                          Image.asset('assets/images/meeza.png', width: 80),
                          Image.asset('assets/images/instapay.png', width: 65),
                        ],
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: _saveCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(0, 53, 121, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          padding: const EdgeInsets.fromLTRB(70, 17, 70, 11),
                          minimumSize: const Size(269, 0),
                        ),
                        child: Text(
                          'Add Card',
                          style: GoogleFonts.alexandria(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: 0.1,
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
      ),
    );
  }
}
