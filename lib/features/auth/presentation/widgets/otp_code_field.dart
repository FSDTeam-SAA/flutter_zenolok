import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinCode extends StatelessWidget {
  const PinCode({super.key, required this.otpController});

  final TextEditingController otpController;

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      controller: otpController,
      length: 4,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      animationType: AnimationType.fade,
      keyboardType: TextInputType.number,
      autoFocus: false,

      obscureText: true,
      textStyle: const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),

      cursorColor: Colors.black,
      enableActiveFill: true,

      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(6),
        fieldHeight: 56,
        fieldWidth: 54,
        // 🔽 reduce the spacing here
         // default ~16, reduce to make boxes closer

        inactiveColor: Colors.transparent,
        activeColor: Colors.transparent,
        selectedColor: Colors.transparent,

        inactiveFillColor: const Color(0xFF2E2E2E),
        activeFillColor: const Color(0xFF2E2E2E),
        selectedFillColor: const Color(0xFF2E2E2E),
      ),
    );
  }
}
