import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:livestock/core/utils/validators.dart';

/// Step widget for comprehensive farmer personal information
class PersonalInfoStepWidget extends StatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController middleNameController;
  final TextEditingController surnameController;
  final TextEditingController nidaController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final DateTime? dateOfBirth;
  final String? gender;
  final Function(DateTime?) onDateOfBirthChanged;
  final Function(String?) onGenderChanged;

  const PersonalInfoStepWidget({
    super.key,
    required this.firstNameController,
    required this.middleNameController,
    required this.surnameController,
    required this.nidaController,
    required this.phoneController,
    required this.emailController,
    required this.dateOfBirth,
    required this.gender,
    required this.onDateOfBirthChanged,
    required this.onGenderChanged,
  });

  @override
  State<PersonalInfoStepWidget> createState() => _PersonalInfoStepWidgetState();
}

class _PersonalInfoStepWidgetState extends State<PersonalInfoStepWidget> {
  void _handlePhoneFocus() {
    if (widget.phoneController.text.isEmpty) {
      widget.phoneController.text = '+255';
      widget.phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.phoneController.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
            'Enter the farmer\'s complete personal details',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // First Name
          TextFormField(
            controller: widget.firstNameController,
            decoration: InputDecoration(
              labelText: 'First Name *',
              hintText: 'Enter first name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => Validators.validatePersonName(value, 'First name'),
          ),
          const SizedBox(height: 16),

          // Middle Name
          TextFormField(
            controller: widget.middleNameController,
            decoration: InputDecoration(
              labelText: 'Middle Name (Optional)',
              hintText: 'Enter middle name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            textCapitalization: TextCapitalization.words,
            validator: Validators.validateOptionalMiddleName,
          ),
          const SizedBox(height: 16),

          // Surname
          TextFormField(
            controller: widget.surnameController,
            decoration: InputDecoration(
              labelText: 'Surname *',
              hintText: 'Enter surname',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => Validators.validatePersonName(value, 'Surname'),
          ),
          const SizedBox(height: 16),

          // Date of Birth
          TextFormField(
            controller: TextEditingController(
              text: widget.dateOfBirth == null
                  ? ''
                  : DateFormat('dd/MM/yyyy').format(widget.dateOfBirth!),
            ),
            decoration: InputDecoration(
              labelText: 'Date of Birth *',
              hintText: 'Select date of birth',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              helperText: 'Farmer must be 18-100 years old',
            ),
            readOnly: true,
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: widget.dateOfBirth ?? DateTime(1990),
                firstDate: DateTime(1930),
                lastDate: DateTime.now(),
                helpText: 'Select Date of Birth',
              );
              if (selectedDate != null) {
                widget.onDateOfBirthChanged(selectedDate);
              }
            },
            validator: (value) => Validators.validateAge(widget.dateOfBirth),
          ),
          const SizedBox(height: 16),

          // NIDA Number
          TextFormField(
            controller: widget.nidaController,
            decoration: InputDecoration(
              labelText: 'NIDA Number *',
              hintText: 'Enter 20-digit NIDA number',
              prefixIcon: const Icon(Icons.badge),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              helperText: 'National ID must be exactly 20 digits',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(20),
            ],
            validator: Validators.validateNIDA,
          ),
          const SizedBox(height: 16),

          // Gender
          DropdownButtonFormField<String>(
            initialValue: widget.gender,
            decoration: InputDecoration(
              labelText: 'Gender *',
              prefixIcon: const Icon(Icons.wc),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            hint: const Text('Select gender'),
            items: ['Male', 'Female']
                .map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(g),
                    ))
                .toList(),
            onChanged: widget.onGenderChanged,
            validator: Validators.validateGender,
          ),
          const SizedBox(height: 16),

          // Phone Number
          Focus(
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                _handlePhoneFocus();
              }
            },
            child: TextFormField(
              controller: widget.phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: '+255 XXX XXX XXX',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                helperText: 'Format: +255XXXXXXXXX',
              ),
              keyboardType: TextInputType.phone,
              validator: Validators.validateTanzaniaPhone,
            ),
          ),
          const SizedBox(height: 16),

          // Email (Optional)
          TextFormField(
            controller: widget.emailController,
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
            validator: Validators.validateOptionalEmail,
          ),
          const SizedBox(height: 16),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Fields marked with * are required',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
