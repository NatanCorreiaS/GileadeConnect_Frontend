import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GileadeButton extends StatelessWidget {
  const GileadeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutline = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isOutline;

  @override
  Widget build(BuildContext context) {
    final background = isOutline ? AppColors.white : AppColors.primary;
    final borderColor = isOutline ? AppColors.primary : Colors.transparent;
    final textStyle = isOutline ? AppTextStyles.buttonOutline : AppTextStyles.button;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: AppColors.white,
          elevation: isOutline ? 0 : 8,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: borderColor, width: 1.6),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: textStyle),
      ),
    );
  }
}
