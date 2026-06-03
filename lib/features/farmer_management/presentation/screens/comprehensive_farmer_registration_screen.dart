import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/domain/entities/location.dart';
import 'package:livestock/features/farmer_management/domain/entities/farm_assets.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_registration_state_provider.dart';
import 'package:livestock/features/farmer_management/presentation/providers/geo_data_provider.dart';
import 'package:livestock/features/farmer_management/presentation/widgets/personal_info_step_widget.dart';
import 'package:livestock/features/farmer_management/presentation/widgets/location_step_widget.dart';
import 'package:livestock/features/farmer_management/presentation/widgets/farm_assets_step_widget.dart';
import 'package:livestock/features/farmer_management/presentation/widgets/farmer_access_step.dart';

/// Comprehensive farmer registration screen with 4 steps
class ComprehensiveFarmerRegistrationScreen extends ConsumerStatefulWidget {
  const ComprehensiveFarmerRegistrationScreen({super.key});

  @override
  ConsumerState<ComprehensiveFarmerRegistrationScreen> createState() =>
      _ComprehensiveFarmerRegistrationScreenState();
}

class _ComprehensiveFarmerRegistrationScreenState
    extends ConsumerState<ComprehensiveFarmerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Personal Information controllers
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _nidaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;

  // Location selection
  String? _selectedRegionId;
  String? _selectedDistrictId;
  String? _selectedWardId;
  String? _selectedVillageId;

  // Farm Assets controllers
  final _avocadoTotalController = TextEditingController(text: '0');
  final _avocadoFruitingController = TextEditingController(text: '0');
  final _femaleChickensController = TextEditingController(text: '0');
  final _roostersController = TextEditingController(text: '0');
  final _maleCattleController = TextEditingController(text: '0');
  final _femaleCattleController = TextEditingController(text: '0');
  final _largeBeehivesController = TextEditingController(text: '0');
  final _smallBeehivesController = TextEditingController(text: '0');
  final _bananaPlantsController = TextEditingController(text: '0');
  final _passionSeedlingsController = TextEditingController(text: '0');
  final _potatoHectaresController = TextEditingController(text: '0');
  DateTime? _potatoPlantingDate;

  // App Access
  bool _hasAppAccess = false;

  @override
  void initState() {
    super.initState();
    // Load geographic data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(geoDataProvider.notifier).loadGeoData();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _surnameController.dispose();
    _nidaController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _avocadoTotalController.dispose();
    _avocadoFruitingController.dispose();
    _femaleChickensController.dispose();
    _roostersController.dispose();
    _maleCattleController.dispose();
    _femaleCattleController.dispose();
    _largeBeehivesController.dispose();
    _smallBeehivesController.dispose();
    _bananaPlantsController.dispose();
    _passionSeedlingsController.dispose();
    _potatoHectaresController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = ref.read(currentAuthUserProvider);

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
      }
      return;
    }

    // Get location details from GeoDataService
    final geoNotifier = ref.read(geoDataProvider.notifier);
    final regions = geoNotifier.getRegions();
    final districts = _selectedRegionId != null
        ? geoNotifier.getDistrictsByRegion(_selectedRegionId!)
        : [];
    final wards = _selectedDistrictId != null
        ? geoNotifier.getWardsByDistrict(_selectedDistrictId!)
        : [];
    final villages =
        _selectedWardId != null ? geoNotifier.getVillagesByWard(_selectedWardId!) : [];

    final region = regions.firstWhere((r) => r.id == _selectedRegionId);
    final district = districts.firstWhere((d) => d.id == _selectedDistrictId);
    final ward = wards.firstWhere((w) => w.id == _selectedWardId);
    final village = villages.firstWhere((v) => v.id == _selectedVillageId);

    // Create Location entity
    final locationDetails = Location(
      regionId: region.id,
      regionName: region.name,
      districtId: district.id,
      districtName: district.name,
      wardId: ward.id,
      wardName: ward.name,
      villageId: village.id,
      villageName: village.name,
      isUrban: village.isUrban,
    );

    // Create FarmAssets entity
    final farmAssets = FarmAssets(
      avocadoTotal: int.tryParse(_avocadoTotalController.text) ?? 0,
      avocadoFruiting: int.tryParse(_avocadoFruitingController.text) ?? 0,
      femaleChickens: int.tryParse(_femaleChickensController.text) ?? 0,
      roosters: int.tryParse(_roostersController.text) ?? 0,
      maleCattle: int.tryParse(_maleCattleController.text) ?? 0,
      femaleCattle: int.tryParse(_femaleCattleController.text) ?? 0,
      largeBeehives: int.tryParse(_largeBeehivesController.text) ?? 0,
      smallBeehives: int.tryParse(_smallBeehivesController.text) ?? 0,
      bananaPlants: int.tryParse(_bananaPlantsController.text) ?? 0,
      passionSeedlings: int.tryParse(_passionSeedlingsController.text) ?? 0,
      potatoPlantingDate: _potatoPlantingDate,
      potatoHectares: double.tryParse(_potatoHectaresController.text) ?? 0.0,
    );

    // Create farmer using factory constructor
    final farmer = Farmer.fromDetails(
      id: '',
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim().isEmpty
          ? null
          : _middleNameController.text.trim(),
      surname: _surnameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      nationalId: _nidaController.text.trim(),
      cooperativeId: user.cooperativeId ?? '',
      hasAppAccess: _hasAppAccess,
      creditScore: 50.0,
      registeredAt: DateTime.now(),
      dateOfBirth: _dateOfBirth,
      gender: _gender,
      locationDetails: locationDetails,
      farmAssets: farmAssets,
    );

    await ref.read(farmerRegistrationProvider.notifier).registerFarmer(farmer);

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

  Widget _getCurrentStepWidget() {
    switch (_currentStep) {
      case 0:
        return PersonalInfoStepWidget(
          firstNameController: _firstNameController,
          middleNameController: _middleNameController,
          surnameController: _surnameController,
          nidaController: _nidaController,
          phoneController: _phoneController,
          emailController: _emailController,
          dateOfBirth: _dateOfBirth,
          gender: _gender,
          onDateOfBirthChanged: (date) {
            setState(() {
              _dateOfBirth = date;
            });
          },
          onGenderChanged: (value) {
            setState(() {
              _gender = value;
            });
          },
        );
      case 1:
        return LocationStepWidget(
          selectedRegionId: _selectedRegionId,
          selectedDistrictId: _selectedDistrictId,
          selectedWardId: _selectedWardId,
          selectedVillageId: _selectedVillageId,
          onRegionChanged: (value) {
            setState(() {
              _selectedRegionId = value;
            });
          },
          onDistrictChanged: (value) {
            setState(() {
              _selectedDistrictId = value;
            });
          },
          onWardChanged: (value) {
            setState(() {
              _selectedWardId = value;
            });
          },
          onVillageChanged: (value) {
            setState(() {
              _selectedVillageId = value;
            });
          },
        );
      case 2:
        return FarmAssetsStepWidget(
          avocadoTotalController: _avocadoTotalController,
          avocadoFruitingController: _avocadoFruitingController,
          femaleChickensController: _femaleChickensController,
          roostersController: _roostersController,
          maleCattleController: _maleCattleController,
          femaleCattleController: _femaleCattleController,
          largeBeehivesController: _largeBeehivesController,
          smallBeehivesController: _smallBeehivesController,
          bananaPlantsController: _bananaPlantsController,
          passionSeedlingsController: _passionSeedlingsController,
          potatoHectaresController: _potatoHectaresController,
          potatoPlantingDate: _potatoPlantingDate,
          onPotatoPlantingDateChanged: (date) {
            setState(() {
              _potatoPlantingDate = date;
            });
          },
        );
      case 3:
        return FarmerAccessStep(
          hasAppAccess: _hasAppAccess,
          onChanged: (value) {
            setState(() {
              _hasAppAccess = value;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(farmerRegistrationProvider);
    const totalSteps = 4;
    final progress = (_currentStep + 1) / totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Farmer'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of $totalSteps',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _getCurrentStepWidget(),
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: registrationState.isLoading
                            ? null
                            : () {
                                setState(() {
                                  _currentStep--;
                                });
                              },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: registrationState.isLoading
                          ? null
                          : () {
                              if (_currentStep < 3) {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _currentStep++;
                                  });
                                }
                              } else {
                                _handleSubmit();
                              }
                            },
                      icon: registrationState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _currentStep < 3
                                  ? Icons.arrow_forward
                                  : Icons.check,
                            ),
                      label: Text(
                        _currentStep < 3 ? 'Continue' : 'Register Farmer',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
