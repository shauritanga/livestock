import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker_category.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker_status.dart';
import 'package:livestock/features/off_takers/presentation/providers/off_taker_providers.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Create off-taker screen (MVP - simplified)
class CreateOffTakerScreen extends ConsumerStatefulWidget {
  const CreateOffTakerScreen({super.key});

  @override
  ConsumerState<CreateOffTakerScreen> createState() => _CreateOffTakerScreenState();
}

class _CreateOffTakerScreenState extends ConsumerState<CreateOffTakerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  
  OffTakerCategory _selectedCategory = OffTakerCategory.processor;
  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactPersonController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveOffTaker() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = ref.read(currentAuthUserProvider);
    if (currentUser?.cooperativeId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final offTaker = OffTaker(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cooperativeId: currentUser!.cooperativeId!,
        businessName: _businessNameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        category: _selectedCategory,
        status: OffTakerStatus.active,
        registeredAt: DateTime.now(),
      );

      final useCase = ref.read(createOffTakerUseCaseProvider);
      final result = await useCase(offTaker);

      if (!mounted) return;

      switch (result) {
        case Success():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Off-taker created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Invalidate the off-takers list to refresh
          ref.invalidate(offTakersProvider);
          context.pop();
        case Error(failure: final failure):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create off-taker: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.createOffTaker),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Business Name
            TextFormField(
              controller: _businessNameController,
              decoration: InputDecoration(
                labelText: localizations.businessName,
                hintText: 'Enter business name',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Business name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Contact Person
            TextFormField(
              controller: _contactPersonController,
              decoration: InputDecoration(
                labelText: localizations.contactPerson,
                hintText: 'Enter contact person name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Contact person is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: localizations.phoneNumber,
                hintText: 'Enter phone number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Phone number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<OffTakerCategory>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: localizations.offTakerCategory,
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: OffTakerCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveOffTaker,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      localizations.save,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
