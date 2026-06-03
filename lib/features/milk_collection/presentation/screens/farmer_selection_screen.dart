import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_list_state_provider.dart';
import 'package:livestock/features/milk_collection/presentation/screens/milk_collection_screen.dart';

/// Screen for selecting a farmer to record milk collection
class FarmerSelectionScreen extends ConsumerStatefulWidget {
  const FarmerSelectionScreen({super.key});

  @override
  ConsumerState<FarmerSelectionScreen> createState() =>
      _FarmerSelectionScreenState();
}

class _FarmerSelectionScreenState extends ConsumerState<FarmerSelectionScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load farmers when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFarmers();
    });
  }

  void _loadFarmers() {
    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    if (user.role.name == 'collection_agent' && user.collectionCentreId != null) {
      ref.read(farmerListProvider.notifier).loadFarmersByCollectionCentre(
            user.collectionCentreId!,
          );
    } else if (user.cooperativeId != null) {
      ref.read(farmerListProvider.notifier).loadFarmersByCooperative(
            user.cooperativeId!,
          );
    }
  }

  void _handleSearch(String query) {
    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    if (user.role.name == 'collection_agent' && user.collectionCentreId != null) {
      ref.read(farmerListProvider.notifier).loadFarmersByCollectionCentre(
            user.collectionCentreId!,
            searchQuery: query,
          );
    } else if (user.cooperativeId != null) {
      ref.read(farmerListProvider.notifier).loadFarmersByCooperative(
            user.cooperativeId!,
            searchQuery: query,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAuthUserProvider);
    final state = ref.watch(farmerListProvider);
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Select Farmer'),
        ),
        body: const Center(
          child: Text('User not authenticated'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Farmer'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
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
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
                // Trigger search with debouncing would be better, but for now search immediately
                if (value.length >= 2 || value.isEmpty) {
                  _handleSearch(value);
                }
              },
            ),
          ),

          // Farmers list
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? Center(
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
                              'Failed to load farmers',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.errorMessage!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadFarmers,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : state.farmers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No farmers registered yet'
                                      : 'No farmers found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Register farmers to start recording collections',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.farmers.length,
                            itemBuilder: (context, index) {
                              final farmer = state.farmers[index];
                              return _FarmerCard(
                                farmer: farmer,
                                onTap: () {
                                  // Navigate to milk collection screen with selected farmer
                                  // Recording screen will handle navigation back to main screen
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MilkCollectionScreen(
                                        farmer: farmer,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _FarmerCard extends StatelessWidget {
  final Farmer farmer;
  final VoidCallback onTap;

  const _FarmerCard({
    required this.farmer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Text(
            farmer.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          farmer.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(farmer.phoneNumber),
            if (farmer.location.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                farmer.location,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
