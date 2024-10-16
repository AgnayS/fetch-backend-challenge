import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetch_backend/models/transaction.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8000';

  Future<Map<String, int>> getBalance() async {
    final response = await http.get(Uri.parse('$baseUrl/balance'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((key, value) => MapEntry(key, value as int));
    } else {
      throw Exception('Failed to load balance');
    }
  }

  Future<String> addPoints(Transaction transaction) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'payer': transaction.payer,
        'points': transaction.points,
        'timestamp': transaction.timestamp.toIso8601String(),
      }),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to add points');
    }
  }

  Future<List<Map<String, dynamic>>> spendPoints(int points) async {
    final response = await http.post(
      Uri.parse('$baseUrl/spend'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'points': points}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to spend points');
    }
  }

  Future<String> resetData() async {
    final response = await http.post(Uri.parse('$baseUrl/reset'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to reset data');
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());