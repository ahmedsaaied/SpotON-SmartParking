import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class IDScannerScreen extends StatefulWidget {
  const IDScannerScreen({super.key});

  @override
  State<IDScannerScreen> createState() => _IDScannerScreenState();
}

class _IDScannerScreenState extends State<IDScannerScreen> {
  File? _idImage;
  bool _isProcessing = false;
  String? _extractedID;
  String? _errorMessage;
  final _textRecognizer = TextRecognizer();

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _captureID() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      maxWidth: 1024,
    );

    if (image == null) return;

    setState(() {
      _idImage = File(image.path);
      _isProcessing = true;
      _extractedID = null;
      _errorMessage = null;
    });

    await _processImage(File(image.path));
  }

  Future<void> _processImage(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final idSection = _extractIdSection(recognizedText.text);
      if (idSection == null) {
        throw Exception("Could not find ID section in the image");
      }

      final extracted = _extractStudentID(idSection);
      if (extracted == null || extracted.length != 9) {
        throw Exception("Valid 9-digit ID not found");
      }

      setState(() {
        _isProcessing = false;
        _extractedID = extracted;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage =
            'Could not find Reg.No in the image.\nPlease ensure the ID card is clearly visible.';
      });
    }
  }

  String? _extractIdSection(String fullText) {
    final lines = fullText.split('\n');
    for (var line in lines) {
      if (line.contains(
          RegExp(r'Reg\.No|Registration\s*Number', caseSensitive: false))) {
        return line;
      }
    }
    return null;
  }

  String? _extractStudentID(String text) {
    final regExp = RegExp(
        r'(?:Reg\.No|Registration\s*Number)\s*[:\-]?\s*(\d{9})\b',
        caseSensitive: false);
    final match = regExp.firstMatch(text);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.cardColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8D1113)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "ID Card Scanner",
          style: GoogleFonts.saira(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildImagePreview(),
              const SizedBox(height: 30),
              _buildProcessingOrResult(),
              const Spacer(),
              _buildScanButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: _idImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(_idImage!, fit: BoxFit.cover),
            )
          : Center(
              child: Icon(Icons.image, color: Colors.grey.shade400, size: 60),
            ),
    );
  }

  Widget _buildProcessingOrResult() {
    if (_isProcessing) {
      return Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF8D1113)),
          ),
          const SizedBox(height: 16),
          Text(
            "Processing ID card...",
            style: GoogleFonts.saira(
              fontSize: 16,
              color: const Color(0xFF707070),
            ),
          ),
        ],
      );
    }

    if (_extractedID != null) {
      return Column(
        children: [
          Text(
            "Extracted Registration Number:",
            style: GoogleFonts.saira(
              fontSize: 16,
              color: const Color(0xFF707070),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _extractedID!,
            style: GoogleFonts.saira(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8D1113),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(result: _extractedID),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D1113),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(
              "Use This ID",
              style: GoogleFonts.saira(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: GoogleFonts.saira(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _captureID,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D1113),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(
              "Try Again",
              style: GoogleFonts.saira(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        "Please scan your University ID card",
        style: GoogleFonts.saira(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF707070),
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return ElevatedButton.icon(
      onPressed: _captureID,
      icon: const Icon(Icons.camera_alt, size: 22, color: Colors.white),
      label: Text(
        _idImage == null ? "Scan ID Card" : "Scan Again",
        style: GoogleFonts.saira(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8D1113),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
