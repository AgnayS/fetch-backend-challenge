import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetch_backend/providers/points_provider.dart';
import 'package:fetch_backend/models/transaction.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointsState = ref.watch(pointsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetch Backend Challenge'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Point Balance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (pointsState.balance.isNotEmpty)
                      ...pointsState.balance.entries.map(
                            (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text('${entry.value} points', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    else
                      const Text('No points available'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Console Output',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ListView.builder(
                        itemCount: pointsState.consoleOutput.length,
                        itemBuilder: (context, index) {
                          return Text(pointsState.consoleOutput[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _showAddPointsDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Points'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _showSpendPointsDialog(context, ref),
                    child: const Text('Spend Points'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _runTests(ref),
                    child: const Text('Run Tests'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _resetData(ref),
                    child: const Text('Reset Data'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPointsDialog(BuildContext context, WidgetRef ref) {
    String payer = '';
    int points = 0;
    DateTime timestamp = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Points'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Payer'),
              onChanged: (value) => payer = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Points'),
              keyboardType: TextInputType.number,
              onChanged: (value) => points = int.tryParse(value) ?? 0,
            ),
            TextButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: timestamp,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  timestamp = picked;
                }
              },
              child: const Text('Select Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (payer.isNotEmpty) {
                await ref.read(pointsProvider.notifier).addPoints(
                  Transaction(
                    payer: payer,
                    points: points,
                    timestamp: timestamp,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSpendPointsDialog(BuildContext context, WidgetRef ref) {
    int points = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spend Points'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Points to Spend'),
          keyboardType: TextInputType.number,
          onChanged: (value) => points = int.tryParse(value) ?? 0,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (points > 0) {
                await ref.read(pointsProvider.notifier).spendPoints(points);
                Navigator.pop(context);
              }
            },
            child: const Text('Spend'),
          ),
        ],
      ),
    );
  }

  void _runTests(WidgetRef ref) async {
    await ref.read(pointsProvider.notifier).runTests();
  }

  void _resetData(WidgetRef ref) async {
    await ref.read(pointsProvider.notifier).resetData();
  }
}