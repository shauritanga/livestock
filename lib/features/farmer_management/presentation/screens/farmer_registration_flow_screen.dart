import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_registration_state_provider.dart';
import 'package:livestock/features/farmer_management/presentation/screens/registration_steps/personal_info_step_screen.dart';
import 'package:livestock/features/farmer_management/presentation/screens/registration_steps/location_step_screen.dart';
import 'package:livestock/features/farmer_management/presentation/screens/registration_steps/cattle_info_step_screen.dart';
import 'package:livestock/features/farmer_management/presentation/screens/registration_steps/app_access_step_screen.dart';
import 'package:livestock/features/farmer_management/presentation/screens/registration_steps/review_step_screen.dart';

/// Main farmer registration flow coordinator
class FarmerRegistrationFlowScreen extends ConsumerStatefulWidget {
  const FarmerRegistrationFlowScreen({super.key});

  @override
  ConsumerState<FarmerRegistrationFlowScreen> createState() =>
      _FarmerRegistrationFlowScreenState();
}

class _FarmerRegistrationFlowScreenState
    extends ConsumerState<FarmerRegistrationFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Form data
  final Map<String, dynamic> _formData = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep(Map<String, dynamic> stepData) {
    _formData.addAll(stepData);
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitRegistration() async {
    final user = ref.read(currentAuthUserProvider);

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
      }
      return;
    }

    // Create farmer entity from collected data
    // Extract first name and surname from name field for backward compatibility
    final fullName = _formData['name'] ?? '';
    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : fullName;
    final surname = nameParts.length > 1 ? nameParts.last : fullName;
    
    final farmer = Farmer(
      id: '',
      name: fullName,
      phoneNumber: _formData['phoneNumber'] ?? '',
      email: _formData['email'],
      nationalId: _formData['nationalId'] ?? '',
      location: _formData['location'] ?? '',
      cooperativeId: user.cooperativeId ?? '',
      hasAppAccess: _formData['hasAppAccess'] ?? false,
      creditScore: 50.0,
      totalCattle: _formData['totalCattle'] ?? 0,
      lactatingCattle: _formData['lactatingCattle'] ?? 0,
      registeredAt: DateTime.now(),
      firstName: firstName,
      surname: surname,
    );

    await ref
        .read(farmerRegistrationProvider.notifier)
        .registerFarmer(farmer);

    final state = ref.read(farmerRegistrationProvider);

    if (state.registeredFarmer != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Farmer registered successfully! ID: ${state.registeredFarmer!.id}',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(state.registeredFarmer);
    } else if (state.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Farmer'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Step Indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / _totalSteps,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          // Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                PersonalInfoStepScreen(
                  onNext: _nextStep,
                  onBack: _previousStep,
                  initialData: _formData,
                ),
                LocationStepScreen(
                  onNext: _nextStep,
                  onBack: _previousStep,
                  initialData: _formData,
                ),
                CattleInfoStepScreen(
                  onNext: _nextStep,
                  onBack: _previousStep,
                  initialData: _formData,
                ),
                AppAccessStepScreen(
                  onNext: _nextStep,
                  onBack: _previousStep,
                  initialData: _formData,
                ),
                ReviewStepScreen(
                  formData: _formData,
                  onBack: _previousStep,
                  onSubmit: _submitRegistration,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
