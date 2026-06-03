import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livestock/features/off_takers/presentation/providers/off_taker_providers.dart';
import 'package:livestock/features/off_takers/presentation/widgets/off_taker_card.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Off-takers list screen (MVP - simplified)
class OffTakersListScreen extends ConsumerWidget {
  const OffTakersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offTakersAsync = ref.watch(offTakersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).offTakers),
        elevation: 0,
        centerTitle: true,
      ),
      body: offTakersAsync.when(
        data: (offTakers) {
          if (offTakers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No off-takers yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first off-taker',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(offTakersProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: offTakers.length,
              itemBuilder: (context, index) {
                final offTaker = offTakers[index];
                return OffTakerCard(
                  offTaker: offTaker,
                  onTap: () {
                    // TODO: Navigate to detail screen (post-MVP)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selected: ${offTaker.businessName}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          );
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
                size: 60,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load off-takers',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
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
                onPressed: () {
                  ref.invalidate(offTakersProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/off-takers/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
