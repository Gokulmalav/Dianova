// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_result.dart';

class ApiService {
  // Android emulator  → http://10.0.2.2:8000
  // iOS simulator     → http://localhost:8000
  // Physical device   → http://YOUR_LOCAL_IP:8000
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const Duration _timeout = Duration(seconds: 30);

  static Future<bool> checkHealth() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/health')).timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) { return false; }
  }

  static Future<PredictionResult> predict(DiabetesInput input) async {
    final res = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    ).timeout(_timeout);

    if (res.statusCode == 200) {
      return PredictionResult.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>, input);
    }
    throw Exception('Server error ${res.statusCode}: ${res.body}');
  }
}
