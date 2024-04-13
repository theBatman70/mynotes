import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final IconData? icon;
  final Color buttonColor;
  final TextStyle textStyle;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.icon,
    this.buttonColor = Colors.amberAccent,
    this.textStyle = const TextStyle(color: Colors.black, fontSize: 18),
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
          if (icon != null) ...[
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 20),
          ],
          Text(
            buttonText,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
