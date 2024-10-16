import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetch_backend/models/transaction.dart';
import 'package:fetch_backend/services/api_service.dart';

class PointsState {
  final Map<String, int> balance;
  final List<Transaction> transactions;
  final List<String> consoleOutput;

  PointsState({required this.balance, required this.transactions, required this.consoleOutput});
}

class PointsNotifier extends StateNotifier<PointsState> {
  final ApiService _apiService;

  PointsNotifier(this._apiService) : super(PointsState(balance: {}, transactions: [], consoleOutput: [])) {
    _fetchBalance();
  }

  void _addConsoleOutput(String output) {
    state = PointsState(
      balance: state.balance,
      transactions: state.transactions,
      consoleOutput: [...state.consoleOutput, output],
    );
  }

  Future<void> _fetchBalance() async {
    final balance = await _apiService.getBalance();
    _addConsoleOutput('Fetched balance: $balance');
    state = PointsState(balance: balance, transactions: state.transactions, consoleOutput: state.consoleOutput);
  }

  Future<String> addPoints(Transaction transaction) async {
    _addConsoleOutput('Sending request: Add ${transaction.points} points for ${transaction.payer}');
    final result = await _apiService.addPoints(transaction);
    state.transactions.add(transaction);
    await _fetchBalance();
    _addConsoleOutput('Response: $result');
    return result;
  }

  Future<String> spendPoints(int points) async {
    _addConsoleOutput('Sending request: Spend $points points');
    final spentPoints = await _apiService.spendPoints(points);
    for (var spentPoint in spentPoints) {
      state.transactions.add(Transaction(
        payer: spentPoint['payer'],
        points: spentPoint['points'],
        timestamp: DateTime.now().toUtc(),
      ));
    }
    await _fetchBalance();
    _addConsoleOutput('Response: $spentPoints');
    return spentPoints.toString();
  }

  Future<void> resetData() async {
    _addConsoleOutput('Sending request: Reset data');
    final result = await _apiService.resetData();
    state = PointsState(balance: {}, transactions: [], consoleOutput: state.consoleOutput);
    _addConsoleOutput('Response: $result');
  }

  Future<void> runTests() async {
    await resetData();

    final testTransactions = [
      Transaction(payer: "DANNON", points: 300, timestamp: DateTime.parse("2022-10-31T10:00:00Z")),
      Transaction(payer: "UNILEVER", points: 200, timestamp: DateTime.parse("2022-10-31T11:00:00Z")),
      Transaction(payer: "DANNON", points: -200, timestamp: DateTime.parse("2022-10-31T15:00:00Z")),
      Transaction(payer: "MILLER COORS", points: 10000, timestamp: DateTime.parse("2022-11-01T14:00:00Z")),
      Transaction(payer: "DANNON", points: 1000, timestamp: DateTime.parse("2022-11-02T14:00:00Z")),
    ];

    for (var transaction in testTransactions) {
      await addPoints(transaction);
    }

    await spendPoints(5000);

    await _fetchBalance();
  }
}

final pointsProvider = StateNotifierProvider<PointsNotifier, PointsState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PointsNotifier(apiService);
});