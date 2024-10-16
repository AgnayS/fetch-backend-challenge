class Transaction {
  final String payer;
  final int points;
  final DateTime timestamp;

  Transaction({
    required this.payer,
    required this.points,
    required this.timestamp,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      payer: json['payer'],
      points: json['points'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payer': payer,
      'points': points,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}