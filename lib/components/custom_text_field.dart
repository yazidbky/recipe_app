import 'package:flutter/material.dart';
import 'package:recipe_app/constants/colors.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final int? maxLines;
  final double borderRadius;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;

  const CustomTextField(
      {super.key,
      this.hintText,
      this.prefixIcon,
      this.suffixIcon,
      this.obscureText = false,
      this.controller,
      this.maxLines = 1,
      this.borderRadius = 32,
      this.onSubmitted,
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
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
