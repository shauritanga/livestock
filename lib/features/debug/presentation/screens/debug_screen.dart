import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/core/constants/firebase_constants.dart';

/// Debug screen for development and testing purposes
class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  bool _isSeeding = false;
  String? _seedingStatus;
  Map<String, dynamic>? _seedingStats;
  bool _isSeedingFarmers = false;
  String? _farmersSeedingStatus;
  int? _farmersSeedCount;
  bool _isSeedingDeliveries = false;
  String? _deliveriesSeedingStatus;
  int? _deliveriesCount;

  Future<void> _seedLocationData() async {
    setState(() {
      _isSeeding = true;
      _seedingStatus = 'Loading data.json...';
      _seedingStats = null;
    });

    try {
      // Load data.json from assets
      final String jsonString = await rootBundle.loadString('data.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;

      setState(() {
        _seedingStatus = 'Data loaded. Uploading to Firestore...';
        _seedingStats = {
          'regions': (data['regions'] as Map).length,
          'districts': (data['districts'] as Map).length,
          'wards': (data['wards'] as Map).length,
          'villages': (data['villages'] as Map).length,
        };
      });

      // Upload to Firestore
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection(FirebaseConstants.locationsCollection)
          .doc('tz_geo_2025')
          .set(data, SetOptions(merge: false));

      setState(() {
        _seedingStatus = 'Success! Data uploaded to Firestore.';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Location data seeded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _seedingStatus = 'Error: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isSeeding = false;
      });
    }
  }

  Future<void> _verifyLocationData() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore
          .collection(FirebaseConstants.locationsCollection)
          .doc('tz_geo_2025')
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('✅ Location Data Verified'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Document exists: ${doc.exists}'),
                  const SizedBox(height: 8),
                  Text('Regions: ${(data['regions'] as Map).length}'),
                  Text('Districts: ${(data['districts'] as Map).length}'),
                  Text('Wards: ${(data['wards'] as Map).length}'),
                  Text('Villages: ${(data['villages'] as Map).length}'),
                  const SizedBox(height: 8),
                  Text('Last updated: ${data['updatedAt']}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Location data not found in Firestore'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _seedFarmers() async {
    setState(() {
      _isSeedingFarmers = true;
      _farmersSeedingStatus = 'Loading farmers.json...';
      _farmersSeedCount = null;
    });

    try {
      // Load farmers.json from assets
      final String jsonString = await rootBundle.loadString('farmers.json');
      final List<dynamic> farmersData = json.decode(jsonString);

      setState(() {
        _farmersSeedingStatus = 'Loaded ${farmersData.length} farmers. Uploading to Firestore...';
        _farmersSeedCount = farmersData.length;
      });

      final firestore = FirebaseFirestore.instance;
      int successCount = 0;
      int skipCount = 0;

      // Default cooperative (flat structure - no collection centres)
      const cooperativeId = 'coop_test_001';

      for (var farmerJson in farmersData) {
        try {
          // Skip if missing required fields
          if (farmerJson['phone'] == null || farmerJson['phone'].toString().isEmpty) {
            skipCount++;
            continue;
          }

          // Format phone number
          String phone = farmerJson['phone'].toString().trim();
          if (!phone.startsWith('+')) {
            phone = '+255${phone.replaceFirst(RegExp(r'^0'), '')}';
          }

          // Create farmer document (flat structure)
          final farmerDoc = {
            // Core fields
            'name': '${farmerJson['firstName']} ${farmerJson['middleName'] ?? ''} ${farmerJson['surname']}'.trim(),
            'phoneNumber': phone,
            'email': null,
            'nationalId': farmerJson['nida']?.toString() ?? '00000000000000000000',
            'location': '${farmerJson['village']}, ${farmerJson['ward']}, ${farmerJson['district']}, ${farmerJson['region']}',
            'cooperativeId': cooperativeId,
            'hasAppAccess': false,
            'creditScore': 50.0,
            'totalCattle': (farmerJson['cattleMale'] ?? 0) + (farmerJson['cattleFemale'] ?? 0),
            'lactatingCattle': farmerJson['cattleFemale'] ?? 0,
            'registeredAt': FieldValue.serverTimestamp(),

            // Detailed fields
            'firstName': farmerJson['firstName'],
            'middleName': farmerJson['middleName'],
            'surname': farmerJson['surname'],
            'dateOfBirth': farmerJson['dateOfBirth'],
            'gender': farmerJson['gender'],

            // Location details
            'locationDetails': {
              'regionId': 'region_${farmerJson['region']?.toString().toLowerCase().replaceAll(' ', '_')}',
              'regionName': farmerJson['region'],
              'districtId': 'district_${farmerJson['district']?.toString().toLowerCase().replaceAll(' ', '_')}',
              'districtName': farmerJson['district'],
              'wardId': 'ward_${farmerJson['ward']?.toString().toLowerCase().replaceAll(' ', '_')}',
              'wardName': farmerJson['ward'],
              'villageId': 'village_${farmerJson['village']?.toString().toLowerCase().replaceAll(' ', '_')}',
              'villageName': farmerJson['village'],
              'isUrban': false,
            },

            // Farm assets
            'farmAssets': {
              'avocadoTotal': farmerJson['avocadoTotal'] ?? 0,
              'avocadoFruiting': farmerJson['avocadoFruiting'] ?? 0,
              'femaleChickens': farmerJson['chickensFemale'] ?? 0,
              'roosters': farmerJson['roosters'] ?? 0,
              'maleCattle': farmerJson['cattleMale'] ?? 0,
              'femaleCattle': farmerJson['cattleFemale'] ?? 0,
              'largeBeehives': farmerJson['beehivesLarge'] ?? 0,
              'smallBeehives': farmerJson['beehivesSmall'] ?? 0,
              'bananaPlants': farmerJson['bananaPlants'] ?? 0,
              'passionSeedlings': farmerJson['passionSeedlings'] ?? 0,
              'potatoPlantingDate': farmerJson['potatoPlantingDate'],
              'potatoHectares': (farmerJson['potatoHectares'] ?? 0).toDouble(),
            },
          };

          // Add to Firestore (flat structure - top-level farmers collection)
          await firestore
              .collection(FirebaseConstants.farmersCollection)
              .add(farmerDoc);

          successCount++;
        } catch (e) {
          // Skip farmer with error
          skipCount++;
        }
      }

      setState(() {
        _farmersSeedingStatus = 'Success! Seeded $successCount farmers (skipped $skipCount)';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Seeded $successCount farmers successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _farmersSeedingStatus = 'Error: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isSeedingFarmers = false;
      });
    }
  }

  Future<void> _seedMilkDeliveries() async {
    setState(() {
      _isSeedingDeliveries = true;
      _deliveriesSeedingStatus = 'Fetching farmers from Firestore...';
      _deliveriesCount = null;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      const cooperativeId = 'coop_test_001';

      // Get all farmers
      final farmersSnapshot = await firestore
          .collection(FirebaseConstants.farmersCollection)
          .where('cooperativeId', isEqualTo: cooperativeId)
          .get();

      if (farmersSnapshot.docs.isEmpty) {
        setState(() {
          _deliveriesSeedingStatus = 'Error: No farmers found. Please seed farmers first.';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No farmers found. Please seed farmers first.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final farmers = farmersSnapshot.docs;
      setState(() {
        _deliveriesSeedingStatus = 'Found ${farmers.length} farmers. Generating deliveries...';
      });

      // Generate deliveries from January 1, 2025 to November 23, 2025
      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 11, 23);
      final totalDays = endDate.difference(startDate).inDays + 1;

      int totalDeliveries = 0;
      var batch = firestore.batch();
      int batchCount = 0;

      // Generate deliveries for each day
      for (int dayOffset = 0; dayOffset < totalDays; dayOffset++) {
        final deliveryDate = startDate.add(Duration(days: dayOffset));

        // Each farmer delivers 1-2 times per day with some randomness
        for (final farmerDoc in farmers) {
          final farmerId = farmerDoc.id;

          // 80% chance of delivery on any given day
          if (DateTime.now().millisecondsSinceEpoch % 100 < 80) {
            // Morning delivery
            final morningDate = DateTime(
              deliveryDate.year,
              deliveryDate.month,
              deliveryDate.day,
              6,
              0,
            );

            final morningDelivery = _createDeliveryDocument(
              farmerId,
              cooperativeId,
              morningDate,
              'morning',
            );

            final deliveryRef = firestore
                .collection(FirebaseConstants.milkDeliveriesCollection)
                .doc();
            batch.set(deliveryRef, morningDelivery);
            batchCount++;
            totalDeliveries++;

            // 40% chance of evening delivery
            if (DateTime.now().millisecondsSinceEpoch % 100 < 40) {
              final eveningDate = DateTime(
                deliveryDate.year,
                deliveryDate.month,
                deliveryDate.day,
                18,
                0,
              );

              final eveningDelivery = _createDeliveryDocument(
                farmerId,
                cooperativeId,
                eveningDate,
                'evening',
              );

              final eveningRef = firestore
                  .collection(FirebaseConstants.milkDeliveriesCollection)
                  .doc();
              batch.set(eveningRef, eveningDelivery);
              batchCount++;
              totalDeliveries++;
            }

            // Commit batch every 500 operations (Firestore limit)
            if (batchCount >= 500) {
              await batch.commit();
              batch = firestore.batch(); // Create new batch
              batchCount = 0;
              setState(() {
                _deliveriesSeedingStatus = 'Progress: $totalDeliveries deliveries created...';
              });
            }
          }
        }

        // Update progress every 30 days
        if ((dayOffset + 1) % 30 == 0) {
          final progress = ((dayOffset + 1) / totalDays * 100).round();
          setState(() {
            _deliveriesSeedingStatus = 'Progress: $progress% ($totalDeliveries deliveries)';
          });
        }
      }

      // Commit remaining batch
      if (batchCount > 0) {
        await batch.commit();
      }

      setState(() {
        _deliveriesCount = totalDeliveries;
        _deliveriesSeedingStatus = 'Success! Created $totalDeliveries deliveries';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Seeded $totalDeliveries milk deliveries successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _deliveriesSeedingStatus = 'Error: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isSeedingDeliveries = false;
      });
    }
  }

  Map<String, dynamic> _createDeliveryDocument(
    String farmerId,
    String cooperativeId,
    DateTime deliveryDate,
    String timeOfDay,
  ) {
    // Generate realistic quantity (morning deliveries are typically larger)
    // Quantities in 0.5L increments (0.5, 1.0, 1.5, 2.0, etc.)
    final baseQuantity = timeOfDay == 'morning' ? 15.0 : 8.0;
    final variation = (DateTime.now().millisecondsSinceEpoch % 1000) / 100 - 5; // +/- 5 liters
    final rawQuantity = (baseQuantity + variation).clamp(5.0, 30.0);
    
    // Round to nearest 0.5L increment
    final quantity = (rawQuantity * 2).round() / 2;

    // Quality grade distribution: 70% standard, 20% premium, 10% substandard
    final qualityRandom = (DateTime.now().millisecondsSinceEpoch % 100) / 100;
    String qualityGrade;
    if (qualityRandom < 0.2) {
      qualityGrade = 'premium';
    } else if (qualityRandom < 0.9) {
      qualityGrade = 'standard';
    } else {
      qualityGrade = 'substandard';
    }

    // Calculate price based on quality
    const basePrice = 1200.0; // TZS per liter
    final qualityMultiplier = qualityGrade == 'premium' ? 1.1 : qualityGrade == 'substandard' ? 0.9 : 1.0;
    final pricePerLiter = basePrice * qualityMultiplier;
    final totalAmount = quantity * pricePerLiter;

    return {
      'farmerId': farmerId,
      'cooperativeId': cooperativeId,
      'cattleId': null,
      'quantityLiters': quantity,
      'qualityGrade': qualityGrade,
      'pricePerLiter': double.parse(pricePerLiter.toStringAsFixed(2)),
      'totalAmount': double.parse(totalAmount.toStringAsFixed(2)),
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'recordedBy': 'debug_seed',
      'createdAt': Timestamp.fromDate(deliveryDate),
    };
  }

  Future<void> _clearLocationData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete all location data from Firestore?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore.collection(FirebaseConstants.locationsCollection).doc('tz_geo_2025').delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🗑️ Location data deleted'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐛 Debug Tools'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Location Data Section
          _buildSectionHeader('🌍 Location Data Management'),
          const SizedBox(height: 8),
          
          _buildDebugCard(
            title: 'Seed Location Data',
            subtitle: 'Upload Tanzania geographical data to Firestore',
            icon: Icons.upload_file,
            color: Colors.blue,
            onTap: _isSeeding ? null : _seedLocationData,
            trailing: _isSeeding
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          
          if (_seedingStatus != null) ...[
            const SizedBox(height: 8),
            Card(
              color: _seedingStatus!.contains('Error')
                  ? Colors.red.shade50
                  : _seedingStatus!.contains('Success')
                      ? Colors.green.shade50
                      : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _seedingStatus!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _seedingStatus!.contains('Error')
                            ? Colors.red.shade900
                            : _seedingStatus!.contains('Success')
                                ? Colors.green.shade900
                                : Colors.blue.shade900,
                      ),
                    ),
                    if (_seedingStats != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Regions: ${_seedingStats!['regions']} | '
                        'Districts: ${_seedingStats!['districts']} | '
                        'Wards: ${_seedingStats!['wards']} | '
                        'Villages: ${_seedingStats!['villages']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 8),
          _buildDebugCard(
            title: 'Verify Location Data',
            subtitle: 'Check if location data exists in Firestore',
            icon: Icons.check_circle_outline,
            color: Colors.green,
            onTap: _verifyLocationData,
          ),
          
          const SizedBox(height: 8),
          _buildDebugCard(
            title: 'Clear Location Data',
            subtitle: 'Delete all location data from Firestore',
            icon: Icons.delete_outline,
            color: Colors.red,
            onTap: _clearLocationData,
          ),
          
          const SizedBox(height: 24),
          
          // Farmers Data Section
          _buildSectionHeader('👨‍🌾 Farmers Data Management'),
          const SizedBox(height: 8),
          
          _buildDebugCard(
            title: 'Seed Farmers Data',
            subtitle: 'Upload sample farmers from farmers.json to Firestore',
            icon: Icons.people,
            color: Colors.purple,
            onTap: _isSeedingFarmers ? null : _seedFarmers,
            trailing: _isSeedingFarmers
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          
          if (_farmersSeedingStatus != null) ...[
            const SizedBox(height: 8),
            Card(
              color: _farmersSeedingStatus!.contains('Error')
                  ? Colors.red.shade50
                  : _farmersSeedingStatus!.contains('Success')
                      ? Colors.green.shade50
                      : Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _farmersSeedingStatus!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _farmersSeedingStatus!.contains('Error')
                            ? Colors.red.shade900
                            : _farmersSeedingStatus!.contains('Success')
                                ? Colors.green.shade900
                                : Colors.purple.shade900,
                      ),
                    ),
                    if (_farmersSeedCount != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Total farmers in file: $_farmersSeedCount',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Milk Deliveries Section
          _buildSectionHeader('🥛 Milk Deliveries Management'),
          const SizedBox(height: 8),
          
          _buildDebugCard(
            title: 'Seed Milk Deliveries',
            subtitle: 'Generate sample deliveries (Jan 1 - Nov 23, 2025)',
            icon: Icons.local_shipping,
            color: Colors.teal,
            onTap: _isSeedingDeliveries ? null : _seedMilkDeliveries,
            trailing: _isSeedingDeliveries
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          
          if (_deliveriesSeedingStatus != null) ...[
            const SizedBox(height: 8),
            Card(
              color: _deliveriesSeedingStatus!.contains('Error')
                  ? Colors.red.shade50
                  : _deliveriesSeedingStatus!.contains('Success')
                      ? Colors.green.shade50
                      : Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _deliveriesSeedingStatus!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _deliveriesSeedingStatus!.contains('Error')
                            ? Colors.red.shade900
                            : _deliveriesSeedingStatus!.contains('Success')
                                ? Colors.green.shade900
                                : Colors.teal.shade900,
                      ),
                    ),
                    if (_deliveriesCount != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Total deliveries created: $_deliveriesCount',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // App Info Section
          _buildSectionHeader('ℹ️ App Information'),
          const SizedBox(height: 8),
          
          _buildInfoCard('App Name', 'AgriPOA'),
          _buildInfoCard('Version', '1.0.0'),
          _buildInfoCard('Build', '100'),
          _buildInfoCard('Environment', 'Development'),
          
          const SizedBox(height: 24),
          
          // Database Section
          _buildSectionHeader('🗄️ Database'),
          const SizedBox(height: 8),
          
          _buildDebugCard(
            title: 'Firestore Console',
            subtitle: 'Open Firebase Console (external)',
            icon: Icons.open_in_new,
            color: Colors.orange,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Open Firebase Console in your browser'),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Warning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This screen is for development only. Do not use in production.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDebugCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
