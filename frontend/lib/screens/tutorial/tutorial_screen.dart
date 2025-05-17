import 'package:app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/preferences_provider.dart';
import '../../widgets/step_progress_bar.dart';
import 'tutorial_steps/features_step.dart';
import 'tutorial_steps/character_step.dart';
import 'tutorial_steps/color_step.dart';
import 'tutorial_steps/complete_step.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentStep = 1;
  final int _totalSteps = 5;
  String _selectedCharacter = 'normal';
  String _selectedColor = 'orange';

  void _handleNext() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _setCharacter(String character) {
    setState(() {
      _selectedCharacter = character;
    });
  }

  void _setColor(String color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _completeTutorial() {
    final provider = Provider.of<PreferencesProvider>(context, listen: false);
    provider.savePreferences(provider.preferences.copyWith(
      assistantCharacter: _selectedCharacter,
      themeColor: _selectedColor,
      tutorialCompleted: true,
    ));

    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeLightColors[_selectedColor],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StepProgressBar(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                themeColor: _selectedColor,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildCurrentStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return FeaturesStep(
          onNext: _handleNext,
          onBack: _handleBack,
          themeColor: _selectedColor,
        );
      case 2:
        return CharacterStep(
          onNext: _handleNext,
          onBack: _handleBack,
          selectedCharacter: _selectedCharacter,
          setCharacter: _setCharacter,
          themeColor: _selectedColor,
        );
      case 3:
        return ColorStep(
          onNext: _handleNext,
          onBack: _handleBack,
          selectedColor: _selectedColor,
          setColor: _setColor,
        );
      case 4:
        return CompleteStep(
          onComplete: _completeTutorial,
          selectedCharacter: _selectedCharacter,
          selectedColor: _selectedColor,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
