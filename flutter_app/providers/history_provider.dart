// lib/providers/history_provider.dart
import 'package:flutter/material.dart';
import '../models/prediction_result.dart';

class HistoryProvider extends ChangeNotifier {
  final List<PredictionResult> _history = [];

  List<PredictionResult> get history => List.unmodifiable(_history.reversed.toList());
  int get totalTests => _history.length;

  double get averageRisk {
    if (_history.isEmpty) return 0;
    return _history.map((h) => h.probability).reduce((a, b) => a + b) / _history.length;
  }

  String get averageRiskPercent => '${(averageRisk * 100).toStringAsFixed(0)}%';

  PredictionResult? get latest => _history.isEmpty ? null : _history.last;

  Map<String, int> get riskDistribution {
    final dist = {'Low': 0, 'Moderate': 0, 'High': 0, 'Very High': 0};
    for (final h in _history) {
      dist[h.riskLevel] = (dist[h.riskLevel] ?? 0) + 1;
    }
    return dist;
  }

  void addResult(PredictionResult result) {
    _history.add(result);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
