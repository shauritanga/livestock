import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';

/// Provider for fetching cooperative name
final cooperativeNameProvider = FutureProvider.family<String, String>((ref, cooperativeId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('cooperatives')
        .doc(cooperativeId)
        .get();
    
    if (doc.exists) {
      return doc.data()?['name'] as String? ?? 'Unknown Cooperative';
    }
    return 'Unknown Cooperative';
  } catch (e) {
    return 'Error loading';
  }
});

/// Provider for fetching collection centre name
final collectionCentreNameProvider = FutureProvider.family<String, Map<String, String>>((ref, ids) async {
  try {
    final cooperativeId = ids['cooperativeId']!;
    final centreId = ids['centreId']!;
    
    final doc = await FirebaseFirestore.instance
        .collection('cooperatives')
        .doc(cooperativeId)
        .collection('collectionCentres')
        .doc(centreId)
        .get();
    
    if (doc.exists) {
      return doc.data()?['name'] as String? ?? 'Unknown Centre';
    }
    return 'Unknown Centre';
  } catch (e) {
    return 'Error loading';
  }
});

/// Profile Screen for viewing and editing user information
class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAuthUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          
          // Profile Avatar and Name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.green,
                  child: Text(
                    user?.displayName?.substring(0, 1).toUpperCase() ?? 'A',
                    style: const TextStyle(
                      fontSize: 48,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? 'Collection Agent',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    user?.role.name.replaceAll('_', ' ').toUpperCase() ?? 'COLLECTION AGENT',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // PERSONAL INFORMATION SECTION
          _buildSectionHeader('PERSONAL INFORMATION'),
          _buildInfoTile(
            icon: Icons.person_outline,
            title: 'Full Name',
            value: user?.displayName ?? 'Not set',
          ),
          _buildInfoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            value: user?.email ?? 'Not set',
          ),
          _buildInfoTile(
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            value: user?.phoneNumber ?? 'Not set',
          ),
          
          const SizedBox(height: 16),
          
          // WORK INFORMATION SECTION
          _buildSectionHeader('WORK INFORMATION'),
          _buildInfoTile(
            icon: Icons.badge_outlined,
            title: 'Role',
            value: user?.role.name.replaceAll('_', ' ').toUpperCase() ?? 'Not set',
          ),
          if (user?.cooperativeId != null)
            _CooperativeInfoTile(cooperativeId: user!.cooperativeId!),
          if (user?.collectionCentreId != null && user?.cooperativeId != null)
            _CollectionCentreInfoTile(
              cooperativeId: user!.cooperativeId!,
              centreId: user.collectionCentreId!,
            ),
          
          const SizedBox(height: 16),
          
          // ACCOUNT SECTION
          _buildSectionHeader('ACCOUNT'),
          _buildInfoTile(
            icon: Icons.verified_user_outlined,
            title: 'User ID',
            value: user?.uid ?? 'Not available',
          ),
          
          const SizedBox(height: 24),
          
          // Edit Profile Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit profile coming soon'),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.grey[700],
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

}

/// Widget to display cooperative name
class _CooperativeInfoTile extends ConsumerWidget {
  final String cooperativeId;

  const _CooperativeInfoTile({required this.cooperativeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(cooperativeNameProvider(cooperativeId));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.business_outlined,
            color: Colors.grey[700],
            size: 24,
          ),
        ),
        title: Text(
          'Cooperative',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        subtitle: nameAsync.when(
          data: (name) => Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          loading: () => const Text(
            'Loading...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          error: (error, stack) => const Text(
            'Error loading',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget to display collection centre name
class _CollectionCentreInfoTile extends ConsumerWidget {
  final String cooperativeId;
  final String centreId;

  const _CollectionCentreInfoTile({
    required this.cooperativeId,
    required this.centreId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(collectionCentreNameProvider({
      'cooperativeId': cooperativeId,
      'centreId': centreId,
    }));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.location_on_outlined,
            color: Colors.grey[700],
            size: 24,
          ),
        ),
        title: Text(
          'Collection Centre',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        subtitle: nameAsync.when(
          data: (name) => Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          loading: () => const Text(
            'Loading...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          error: (error, stack) => const Text(
            'Error loading',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}


