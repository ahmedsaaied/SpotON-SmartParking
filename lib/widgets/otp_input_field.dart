import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final int index;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'OTP digit ${index + 1}',
      textField: true,
      obscured: true,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.61),
          borderRadius: BorderRadius.circular(73),
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
          ),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          onChanged: onChanged,
          // Accessibility properties
          obscureText: true, // Since it's a password/OTP
          obscuringCharacter: '•',
          enableSuggestions: false,
          autocorrect: false,
        ),
      ),
    );
  }
}
