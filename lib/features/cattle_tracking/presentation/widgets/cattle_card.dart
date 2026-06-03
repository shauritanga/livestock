import 'package:flutter/material.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';

/// Card widget displaying cattle summary information
class CattleCard extends StatelessWidget {
  final Cattle cattle;

  const CattleCard({
    super.key,
    required this.cattle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  cattle.gender == CattleGender.female
                      ? Icons.female
                      : Icons.male,
                  size: 32,
                  color: cattle.gender == CattleGender.female
                      ? Colors.pink
                      : Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cattle.breed,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cattle.ageYears.toStringAsFixed(1)} years old',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  label: _getLactationStatusLabel(cattle.lactationStatus),
                  color: _getLactationStatusColor(cattle.lactationStatus),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.health_and_safety,
                    label: 'Health',
                    value: cattle.healthStatus,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.water_drop,
                    label: 'Avg. Production',
                    value: '${cattle.averageDailyProduction.toStringAsFixed(1)}L',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLactationStatusLabel(LactationStatus status) {
    switch (status) {
      case LactationStatus.lactating:
        return 'Lactating';
      case LactationStatus.dry:
        return 'Dry';
      case LactationStatus.pregnant:
        return 'Pregnant';
      case LactationStatus.calf:
        return 'Calf';
    }
  }

  Color _getLactationStatusColor(LactationStatus status) {
    switch (status) {
      case LactationStatus.lactating:
        return Colors.green;
      case LactationStatus.dry:
        return Colors.orange;
      case LactationStatus.pregnant:
        return Colors.purple;
      case LactationStatus.calf:
        return Colors.blue;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
