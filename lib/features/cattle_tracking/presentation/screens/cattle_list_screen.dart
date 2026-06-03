import 'package:flutter/material.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/cattle_tracking/presentation/screens/cattle_registration_screen.dart';
import 'package:livestock/features/cattle_tracking/presentation/widgets/cattle_card.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';

/// Screen displaying list of cattle for a farmer
class CattleListScreen extends StatelessWidget {
  final Farmer farmer;
  final List<Cattle> cattle;

  const CattleListScreen({
    super.key,
    required this.farmer,
    required this.cattle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${farmer.name}\'s Cattle'),
        elevation: 0,
      ),
      body: cattle.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.pets_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No cattle registered yet',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to register cattle',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cattle.length,
              itemBuilder: (context, index) {
                return CattleCard(cattle: cattle[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CattleRegistrationScreen(farmer: farmer),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Register Cattle'),
      ),
    );
  }
}
