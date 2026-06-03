import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_providers.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_collection/presentation/providers/milk_collection_providers.dart';
import 'package:livestock/features/milk_collection/presentation/screens/milk_collection_screen.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Main milk collection screen for primary navigation
/// 
/// Provides quick access to record milk collections and view recent deliveries
class MilkCollectionMainScreen extends ConsumerStatefulWidget {
  const MilkCollectionMainScreen({super.key});

  @override
  ConsumerState<MilkCollectionMainScreen> createState() =>
      _MilkCollectionMainScreenState();
}

class _MilkCollectionMainScreenState
    extends ConsumerState<MilkCollectionMainScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshDeliveries() {
    final user = ref.read(currentAuthUserProvider);
    if (user?.cooperativeId != null) {
      ref.invalidate(todaysDeliveriesProvider(user!.cooperativeId!));
    }
  }

  String _formatCurrency(double amount) {
    // Format with thousand separators
    final formatter = amount.toStringAsFixed(0);
    final parts = <String>[];
    var remaining = formatter;
    
    while (remaining.length > 3) {
      parts.insert(0, remaining.substring(remaining.length - 3));
      remaining = remaining.substring(0, remaining.length - 3);
    }
    if (remaining.isNotEmpty) {
      parts.insert(0, remaining);
    }
    
    return 'TZS ${parts.join(',')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAuthUserProvider);
    
    // Get today's deliveries if user has cooperative
    final deliveriesAsync = user?.cooperativeId != null
        ? ref.watch(todaysDeliveriesProvider(user!.cooperativeId!))
        : null;

    // Calculate stats from deliveries
    double totalLiters = 0;
    int uniqueFarmers = 0;
    double totalAmount = 0;
    List<MilkDelivery> recentDeliveries = [];

    if (deliveriesAsync != null) {
      deliveriesAsync.whenData((result) {
        if (result is Success<List<MilkDelivery>>) {
          final deliveries = result.value;
          
          // Filter deliveries based on search query
          List<MilkDelivery> filteredDeliveries = deliveries;
          if (_searchQuery.isNotEmpty) {
            final searchLower = _searchQuery.toLowerCase();
            filteredDeliveries = deliveries.where((delivery) {
              // Search by farmerId (which might contain name or ID)
              if (delivery.farmerId.toLowerCase().contains(searchLower)) {
                return true;
              }
              
              // Also try to get farmer name from provider
              final farmerAsync = ref.read(farmerByIdProvider(delivery.farmerId));
              return farmerAsync.whenOrNull(
                data: (farmer) {
                  if (farmer == null) return false;
                  return farmer.name.toLowerCase().contains(searchLower) ||
                         farmer.phoneNumber.toLowerCase().contains(searchLower);
                },
              ) ?? false;
            }).toList();
          }
          
          recentDeliveries = filteredDeliveries.take(10).toList();
          
          totalLiters = deliveries.fold(0, (sum, d) => sum + d.quantityLiters);
          uniqueFarmers = deliveries.map((d) => d.farmerId).toSet().length;
          totalAmount = deliveries.fold(0, (sum, d) => sum + d.totalAmount);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).milkCollection),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDeliveries,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search farmer by name or phone...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Quick stats card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: deliveriesAsync == null
                  ? Center(child: Text(AppLocalizations.of(context).pleaseLogIn))
                  : deliveriesAsync.when(
                      data: (result) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              icon: Icons.water_drop,
                              label: AppLocalizations.of(context).today,
                              value: '${totalLiters.toStringAsFixed(1)} L',
                              color: Colors.blue,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            _buildStatItem(
                              icon: Icons.people,
                              label: 'Farmers',
                              value: '$uniqueFarmers',
                              color: Colors.green,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            _buildStatItem(
                              icon: Icons.payments,
                              label: 'Amount',
                              value: _formatCurrency(totalAmount),
                              color: Colors.orange,
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.water_drop,
                            label: AppLocalizations.of(context).today,
                            value: '0 L',
                            color: Colors.blue,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _buildStatItem(
                            icon: Icons.people,
                            label: 'Farmers',
                            value: '0',
                            color: Colors.green,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _buildStatItem(
                            icon: Icons.payments,
                            label: 'Amount',
                            value: 'TZS 0',
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // Recent collections section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).recentCollections,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full history - only if user is logged in
                    final user = ref.read(currentAuthUserProvider);
                    if (user != null) {
                      // For now, show message that we need farmer context
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a farmer from the farmers list to view their history'),
                        ),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context).viewAll),
                ),
              ],
            ),
          ),

          // Recent deliveries list
          Expanded(
            child: deliveriesAsync == null
                ? Center(
                    child: Text(
                      'Please log in to view collections',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : deliveriesAsync.when(
                    data: (result) {
                      if (result is Success<List<MilkDelivery>>) {
                        if (recentDeliveries.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.water_drop_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No collections yet today',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the button below to record a collection',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: recentDeliveries.length,
                          itemBuilder: (context, index) {
                            final delivery = recentDeliveries[index];
                            return _DeliveryCard(delivery: delivery);
                          },
                        );
                      } else if (result is Error) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load deliveries',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _refreshDeliveries,
                                icon: const Icon(Icons.refresh),
                                label: Text(AppLocalizations.of(context).retry),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading deliveries',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refreshDeliveries,
                            icon: const Icon(Icons.refresh),
                            label: Text(AppLocalizations.of(context).retry),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'milk_collection_fab',
        onPressed: () async {
          // Navigate directly to milk collection recording screen
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MilkCollectionScreen(),
            ),
          );
          
          // Refresh deliveries when returning from recording
          if (result == true && mounted) {
            _refreshDeliveries();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context).recordCollection),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Widget to display a delivery card with farmer name
class _DeliveryCard extends ConsumerWidget {
  final MilkDelivery delivery;

  const _DeliveryCard({required this.delivery});

  String _formatCurrency(double amount) {
    // Format with thousand separators
    final formatter = amount.toStringAsFixed(0);
    final parts = <String>[];
    var remaining = formatter;
    
    while (remaining.length > 3) {
      parts.insert(0, remaining.substring(remaining.length - 3));
      remaining = remaining.substring(0, remaining.length - 3);
    }
    if (remaining.isNotEmpty) {
      parts.insert(0, remaining);
    }
    
    return 'TZS ${parts.join(',')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch farmer details to get the name
    final farmerAsync = ref.watch(farmerByIdProvider(delivery.farmerId));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: farmerAsync.when(
        data: (farmer) {
          final farmerName = farmer?.name ?? delivery.farmerId;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                farmerName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              farmerName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${delivery.quantityLiters.toStringAsFixed(1)} L',
            ),
            trailing: Text(
              _formatCurrency(delivery.totalAmount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          );
        },
        loading: () => ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(
              Icons.water_drop,
              color: Colors.blue.shade700,
            ),
          ),
          title: Text(AppLocalizations.of(context).loading),
          subtitle: Text(
            '${delivery.quantityLiters.toStringAsFixed(1)} L',
          ),
          trailing: Text(
            _formatCurrency(delivery.totalAmount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        error: (error, stack) => ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(
              Icons.water_drop,
              color: Colors.blue.shade700,
            ),
          ),
          title: Text(delivery.farmerId),
          subtitle: Text(
            '${delivery.quantityLiters.toStringAsFixed(1)} L',
          ),
          trailing: Text(
            _formatCurrency(delivery.totalAmount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ),
    );
  }
}
