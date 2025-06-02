import 'package:agri_connect/core/constants/pallete.dart';
import 'package:flutter/material.dart';

class AuthGradient extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const AuthGradient({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppPalette.deepForest,
            AppPalette.primaryGreen,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: Size(MediaQuery.of(context).size.width, 55),
          backgroundColor: AppPalette.transparent,
          shadowColor: AppPalette.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppPalette.neutralDark,
          ),
        ),
      ),
    );
  }
}
