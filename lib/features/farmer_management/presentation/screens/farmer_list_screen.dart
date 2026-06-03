import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_list_state_provider.dart';
import 'package:livestock/features/farmer_management/presentation/screens/farmer_detail_screen.dart';
import 'package:livestock/features/farmer_management/presentation/screens/comprehensive_farmer_registration_screen.dart';
import 'package:livestock/features/farmer_management/presentation/widgets/farmer_card.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Screen displaying list of farmers
class FarmerListScreen extends ConsumerStatefulWidget {
  const FarmerListScreen({super.key});

  @override
  ConsumerState<FarmerListScreen> createState() => _FarmerListScreenState();
}

class _FarmerListScreenState extends ConsumerState<FarmerListScreen> {
  final _searchController = TextEditingController();
  bool _hasLoadedFarmers = false;

  @override
  void initState() {
    super.initState();
    // Try to load farmers immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFarmers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFarmers() {
    final user = ref.read(currentAuthUserProvider);

    if (user == null) return;

    // Mark that we've attempted to load farmers
    _hasLoadedFarmers = true;

    // Load farmers by cooperative (collection centres removed)
    if (user.cooperativeId != null) {
      ref
          .read(farmerListProvider.notifier)
          .loadFarmersByCooperative(user.cooperativeId!);
    }
  }

  void _handleSearch(String query) {
    final user = ref.read(currentAuthUserProvider);

    if (user == null) return;

    // Search farmers by cooperative (collection centres removed)
    if (user.cooperativeId != null) {
      ref.read(farmerListProvider.notifier).loadFarmersByCooperative(
            user.cooperativeId!,
            searchQuery: query,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmerListProvider);
    final user = ref.watch(currentAuthUserProvider);

    // Load farmers when user becomes available
    ref.listen(currentAuthUserProvider, (previous, next) {
      if (next != null && !_hasLoadedFarmers) {
        _loadFarmers();
      }
    });

    // Also try to load if user is available but farmers haven't been loaded yet
    if (user != null && !_hasLoadedFarmers && !state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadFarmers();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).farmers),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _handleSearch,
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
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadFarmers,
                              child: Text(AppLocalizations.of(context).retry),
                            ),
                          ],
                        ),
                      )
                    : state.farmers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.searchQuery != null &&
                                          state.searchQuery!.isNotEmpty
                                      ? 'No farmers found matching "${state.searchQuery}"'
                                      : 'No farmers registered yet',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _loadFarmers(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.farmers.length,
                              itemBuilder: (context, index) {
                                final farmer = state.farmers[index];
                                return FarmerCard(
                                  farmer: farmer,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FarmerDetailScreen(farmer: farmer),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'farmer_list_fab',
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ComprehensiveFarmerRegistrationScreen(),
            ),
          );

          if (result != null && mounted) {
            _loadFarmers();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context).registerFarmer),
      ),
    );
  }
}
