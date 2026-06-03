import 'package:flutter/material.dart';
import 'package:livestock/core/utils/date_formatter.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/insurance/presentation/widgets/insurance_status_card.dart';
import 'package:livestock/features/milk_collection/presentation/screens/milk_delivery_history_screen.dart';

/// Screen displaying detailed farmer information
class FarmerDetailScreen extends StatelessWidget {
  final Farmer farmer;

  const FarmerDetailScreen({
    super.key,
    required this.farmer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with photo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: farmer.photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              farmer.photoUrl!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            farmer.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    farmer.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${farmer.id}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Statistics cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.pets,
                      label: 'Total Cattle',
                      value: farmer.totalCattle.toString(),
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.water_drop,
                      label: 'Lactating',
                      value: farmer.lactatingCattle.toString(),
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.star,
                      label: 'Credit Score',
                      value: farmer.creditScore.toStringAsFixed(0),
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MilkDeliveryHistoryScreen(
                              farmer: farmer,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('View Delivery History'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Task 13.1: Insurance Status Card
            InsuranceStatusCard(farmerId: farmer.id),

            // Contact Information
            _SectionHeader(title: 'Contact Information'),
            _InfoTile(
              icon: Icons.phone,
              label: 'Phone Number',
              value: farmer.phoneNumber,
            ),
            if (farmer.email != null)
              _InfoTile(
                icon: Icons.email,
                label: 'Email',
                value: farmer.email!,
              ),
            _InfoTile(
              icon: Icons.badge,
              label: 'National ID',
              value: farmer.nationalId,
            ),
            _InfoTile(
              icon: Icons.location_on,
              label: 'Location',
              value: farmer.location,
            ),

            // App Access
            _SectionHeader(title: 'App Access'),
            _InfoTile(
              icon: Icons.smartphone,
              label: 'Mobile App Access',
              value: farmer.hasAppAccess ? 'Enabled' : 'Disabled',
              valueColor: farmer.hasAppAccess ? Colors.green : Colors.grey,
            ),

            // Registration Info
            _SectionHeader(title: 'Registration'),
            _InfoTile(
              icon: Icons.calendar_today,
              label: 'Registered On',
              value: DateFormatter.formatDate(farmer.registeredAt),
            ),
            if (farmer.lastDeliveryDate != null)
              _InfoTile(
                icon: Icons.access_time,
                label: 'Last Delivery',
                value: DateFormatter.formatDate(farmer.lastDeliveryDate!),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: valueColor,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
