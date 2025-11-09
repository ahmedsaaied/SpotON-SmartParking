// ignore_for_file: use_build_context_synchronously, unused_field
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AddVisitorCarScreen extends StatefulWidget {
  const AddVisitorCarScreen({super.key});

  @override
  State<AddVisitorCarScreen> createState() => _AddVisitorCarScreenState();
}

class _AddVisitorCarScreenState extends State<AddVisitorCarScreen> {
  final _formKey = GlobalKey<FormState>();

  final _visitorNameController = TextEditingController();
  final _plateLetter1Controller = TextEditingController();
  final _plateLetter2Controller = TextEditingController();
  final _plateLetter3Controller = TextEditingController();
  final _plateNumbersController = TextEditingController();
  final _colorController = TextEditingController();

  final _plateLetter1Focus = FocusNode();
  final _plateLetter2Focus = FocusNode();
  final _plateLetter3Focus = FocusNode();

  bool _isSaving = false;
  String? selectedBrand;
  String? selectedModel;

  final Map<String, List<String>> carData = {
    'Alfa Romeo': ['4C', 'Giulia', 'Stelvio'],
    'Audi': ['A3', 'A4', 'Q5'],
    'BMW': ['M3', 'M4', 'X5', 'i8'],
    'Chevrolet': ['Equinox', 'Impala', 'Malibu'],
    'Citroen': ['C3', 'C4', 'C5'],
    'Dodge': ['Challenger', 'Charger', 'Dart', 'Durango', 'Ram'],
    'Fiat': ['500', 'Panda', 'Tipo'],
    'Ford': ['Explorer', 'F-150', 'Focus'],
    'Honda': ['Accord', 'CR-V', 'Civic'],
    'Hyundai': ['Elantra', 'Sonata', 'Tucson'],
    'Infiniti': ['Q50', 'Q60', 'QX50'],
    'Jaguar': ['F-PACE', 'XE', 'XF'],
    'Kia': ['Cerato', 'Seltos', 'Sportage'],
    'Land Rover': ['Defender', 'Discovery', 'Range Rover'],
    'Mazda': ['CX-5', 'Mazda3', 'Mazda6'],
    'Mercedes': ['C200', 'E300', 'GLA', 'GLC', 'S500'],
    'Mitsubishi': ['Eclipse', 'Lancer', 'Outlander'],
    'Nissan': ['Altima', 'Maxima', 'Rogue'],
    'Opel': ['Astra', 'Insignia', 'Mokka'],
    'Peugeot': ['208', '3008', '308'],
    'Porsche': ['911', 'Cayenne', 'Macan'],
    'Renault': ['Captur', 'Clio', 'Megane'],
    'Seat': ['Ateca', 'Ibiza', 'Leon'],
    'Skoda': ['Fabia', 'Kodiaq', 'Octavia'],
    'Subaru': ['Forester', 'Impreza', 'Outback'],
    'Tesla': ['Model 3', 'Model S', 'Model X'],
    'Toyota': ['Camry', 'Corolla', 'Rav4'],
    'Volkswagen': ['Golf', 'Passat', 'Tiguan'],
    'Volvo': ['S60', 'V60', 'XC60'],
  };
  @override
  void dispose() {
    _visitorNameController.dispose();
    _plateLetter1Controller.dispose();
    _plateLetter2Controller.dispose();
    _plateLetter3Controller.dispose();
    _plateNumbersController.dispose();
    _colorController.dispose();
    _plateLetter1Focus.dispose();
    _plateLetter2Focus.dispose();
    _plateLetter3Focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> brands = carData.keys.toList()..sort();
    List<String> models = selectedBrand != null
        ? (List<String>.from(carData[selectedBrand] ?? [])..sort())
        : [];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 131, 131, 131),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 20),
              // Image.asset(
              //   'assets/images/visitor_icon.png', // Replace with your own visitor-themed image
              //   width: 100,
              //   height: 100,
              // ),
              const SizedBox(height: 10),
              _buildForm(brands, models),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(40, 30, 180, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Image.asset('assets/images/back.png', width: 20, height: 20),
      ),
    );
  }

  Widget _buildForm(List<String> brands, List<String> models) {
    return Container(
      padding: const EdgeInsets.fromLTRB(35, 30, 35, 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Visitor Name', _visitorNameController),
            const SizedBox(height: 20),
            _buildDropdown('Car Brand', brands, selectedBrand, (val) {
              setState(() {
                selectedBrand = val;
                selectedModel = null;
              });
            }),
            const SizedBox(height: 20),
            _buildDropdown('Car Model', models, selectedModel, (val) {
              setState(() => selectedModel = val);
            }),
            const SizedBox(height: 20),
            _buildPlateSection(),
            const SizedBox(height: 20),
            _buildColorField(),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelTextStyle()),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          decoration: _inputDecoration('Enter $label'),
          style: _inputTextStyle(),
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelTextStyle()),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                  value: e, child: Text(e, style: _inputTextStyle())))
              .toList(),
          onChanged: onChanged,
          decoration: _inputDecoration('Select $label'),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildPlateSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plate Numbers', style: _labelTextStyle()),
              const SizedBox(height: 10),
              TextFormField(
                controller: _plateNumbersController,
                decoration: _inputDecoration('Ex: ٤ ٧ ٩'),
                style: _inputTextStyle(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[\u0660-\u0669\s]')),
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 60),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plate Letters', style: _labelTextStyle()),
            const SizedBox(height: 10),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                _buildPlateLetterField(_plateLetter3Controller,
                    _plateLetter3Focus, _plateLetter2Focus),
                const SizedBox(width: 8),
                _buildPlateLetterField(_plateLetter2Controller,
                    _plateLetter2Focus, _plateLetter1Focus),
                const SizedBox(width: 8),
                _buildPlateLetterField(
                    _plateLetter1Controller, _plateLetter1Focus, null),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlateLetterField(
      TextEditingController controller, FocusNode focusNode, FocusNode? next) {
    return SizedBox(
      width: 40,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: _inputTextStyle(),
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\u0621-\u064A]')),
        ],
        decoration: _inputDecoration(''),
        onChanged: (val) {
          if (val.length == 1 && next != null) {
            FocusScope.of(context).requestFocus(next);
          }
          setState(() {});
        },
      ),
    );
  }

  Widget _buildColorField() {
    final colorOptions = {
      'Black': Colors.black,
      'White': Colors.white,
      'Red': Colors.red,
      'Blue': Colors.blue,
      'Green': Colors.green,
      'Silver': const Color(0xFFC0C0C0),
      'Gray': Colors.grey,
      'Yellow': Colors.yellow,
      'Gold': const Color(0xFFFFD700),
      'Orange': Colors.orange,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color', style: _labelTextStyle()),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _colorController.text.isEmpty ? null : _colorController.text,
          items: colorOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: entry.value,
                    ),
                  ),
                  Text(entry.key, style: _inputTextStyle()),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _colorController.text = val!;
            });
          },
          decoration: _inputDecoration('Select Color'),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  _saveVisitorCarToFirestore();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF003579),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 0,
        ),
        child: Text(
          _isSaving ? 'Saving...' : 'Save Visitor Car',
          style: GoogleFonts.alexandria(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _saveVisitorCarToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final plateLettersList = [
      _plateLetter1Controller.text.trim(),
      _plateLetter2Controller.text.trim(),
      _plateLetter3Controller.text.trim(),
    ];

    final filteredLetters =
        plateLettersList.where((l) => l.isNotEmpty).toList();
    final plateValid = filteredLetters.length >= 2 &&
        filteredLetters.every((l) => RegExp(r'^[\u0621-\u064A]$').hasMatch(l));
    final formattedLetters = filteredLetters.reversed.join(' ');

    final numbersValid = RegExp(r'^[\u0660-\u0669 ]{1,7}$')
            .hasMatch(_plateNumbersController.text.trim()) &&
        _plateNumbersController.text.trim().replaceAll(' ', '').length <= 4;

    if (!plateValid || !numbersValid) {
      Get.snackbar("Missing Input", "Please enter valid plate details.",
          backgroundColor: const Color(0xFF8D1113), colorText: Colors.white);
      return;
    }

    if (selectedBrand == null ||
        selectedModel == null ||
        _colorController.text.trim().isEmpty ||
        _visitorNameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please fill all required fields",
          backgroundColor: const Color(0xFF8D1113), colorText: Colors.white);
      return;
    }

    if (mounted) setState(() => _isSaving = true);

    try {
      final doc = FirebaseFirestore.instance.collection('Users').doc(user.uid);
      final snap = await doc.get();
      if (!snap.exists) {
        await doc.set({
          'uid': user.uid,
          'email': user.email,
          'createdAt': Timestamp.now(),
        });
      }

      await doc.collection('VisitorCars').add({
        'visitorName': _visitorNameController.text.trim(),
        'brand': selectedBrand,
        'model': selectedModel,
        'plateLetters': formattedLetters,
        'plateNumbers': _plateNumbersController.text.trim(),
        'color': _colorController.text.trim(),
        'addedAt': Timestamp.now(),
        'isVisitor': true,
      });

      if (mounted) {
        setState(() => _isSaving = false);
        Get.snackbar("Success", "Visitor car added",
            backgroundColor: Colors.green, colorText: Colors.white);
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        Get.snackbar("Error", "Failed to save visitor car",
            backgroundColor: const Color(0xFF8D1113), colorText: Colors.white);
      }
    }
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle:
          GoogleFonts.saira(fontSize: 14, color: const Color(0xFF003579)),
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF838383)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF003579)),
      ),
    );
  }

  TextStyle _inputTextStyle() =>
      GoogleFonts.saira(fontSize: 14, color: const Color(0xFF003579));

  TextStyle _labelTextStyle() => GoogleFonts.saira(
      fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black);
}
