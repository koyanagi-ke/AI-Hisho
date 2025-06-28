import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../constants/colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.topBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/characters/normal.png',
                width: 160,
                height: 160,
              ),
              const SizedBox(height: 16),
              Text(
                'ミライフ',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '準備って、もっとスマートでいい。',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: CustomButton(
                  text: '始める',
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/tutorial'),
                  themeColor: 'orange',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
