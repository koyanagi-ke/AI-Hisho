import 'package:flutter/material.dart';
import '../constants/colors.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String themeColor;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        AppColors.themeColors[themeColor] ?? AppColors.themeColors['orange']!;

    return Container(
      width: double.infinity,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: currentStep / (totalSteps - 1),
        child: Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
