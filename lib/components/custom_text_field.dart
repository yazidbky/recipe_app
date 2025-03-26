import 'package:flutter/material.dart';
import 'package:recipe_app/constants/colors.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon; // Made optional with a nullable type
  final bool obscureText;
  final TextEditingController? controller;
  final int? maxLines;
  final double borderRadius;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode; // Add FocusNode parameter

  const CustomTextField(
      {super.key,
      this.hintText, // Default empty string
      this.prefixIcon,
      this.suffixIcon, // Optional, defaults to null
      this.obscureText = false,
      this.controller,
      this.maxLines = 1,
      this.borderRadius = 32,
      this.onSubmitted, // Default to false
      this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        focusNode: focusNode,
        maxLines: maxLines,
        controller: controller,
        onSubmitted: onSubmitted,
        obscureText: obscureText,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: primaryColor, style: BorderStyle.solid, width: 2),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
                color: primaryColor, style: BorderStyle.solid, width: 2),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          prefixIcon: prefixIcon, // Uses provided prefixIcon
          suffixIcon: suffixIcon, // Conditionally add suffixIcon
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
