import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPoppinsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final IconData? icon;
  final Color buttonColor;
  final Color iconColor;
  final Color buttonTextColor;

  const CustomPoppinsButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.icon,
    this.buttonColor = const Color(0xFF170A1C),
    this.buttonTextColor = const Color(0xFFFFFFFF),
    this.iconColor = const Color(0xFFFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            buttonText,
            style: GoogleFonts.poppins(
                color: buttonTextColor, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 20,),
          if (icon != null) ...[
            Icon(icon, color: iconColor),
          ],
        ],
      ),
    );
  }
}
