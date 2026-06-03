import 'package:flutter/material.dart';
import 'package:livestock/core/utils/validators.dart';

/// Step widget for farmer personal information
class FarmerInfoStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController nationalIdController;

  const FarmerInfoStep({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.nationalIdController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter the farmer\'s basic information',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Full Name *',
            hintText: 'Enter farmer\'s full name',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: Validators.validateName,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number *',
            hintText: '+255 XXX XXX XXX',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.phone,
          validator: Validators.validatePhoneNumber,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email (Optional)',
            hintText: 'farmer@example.com',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              return Validators.validateEmail(value);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: nationalIdController,
          decoration: InputDecoration(
            labelText: 'National ID *',
            hintText: 'Enter national ID number',
            prefixIcon: const Icon(Icons.badge),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) =>
              Validators.validateRequired(value, 'National ID'),
        ),
      ],
    );
  }
}
