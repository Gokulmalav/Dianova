// lib/models/prediction_result.dart

class PredictionResult {
  final bool diabetic;
  final double probability;
  final String riskLevel;
  final double confidence;
  final Map<String, double> featureImportance;
  final List<String> recommendations;
  final DateTime timestamp;
  final DiabetesInput input;

  PredictionResult({
    required this.diabetic,
    required this.probability,
    required this.riskLevel,
    required this.confidence,
    required this.featureImportance,
    required this.recommendations,
    required this.input,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory PredictionResult.fromJson(Map<String, dynamic> json, DiabetesInput input) {
    return PredictionResult(
      diabetic: json['diabetic'] as bool,
      probability: (json['probability'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      featureImportance: Map<String, double>.from(
        (json['feature_importance'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
      ),
      recommendations: List<String>.from(json['recommendations']),
      input: input,
    );
  }

  String get probabilityPercent => '${(probability * 100).toStringAsFixed(1)}%';
  String get confidencePercent  => '${(confidence  * 100).toStringAsFixed(1)}%';
  int    get probabilityInt     => (probability * 100).round();
}


class DiabetesInput {
  double pregnancies;
  double glucose;
  double bloodPressure;
  double skinThickness;
  double insulin;
  double bmi;
  double diabetesPedigree;
  double age;

  DiabetesInput({
    this.pregnancies    = 0,
    this.glucose        = 0,
    this.bloodPressure  = 0,
    this.skinThickness  = 0,
    this.insulin        = 0,
    this.bmi            = 0,
    this.diabetesPedigree = 0,
    this.age            = 0,
  });

  Map<String, dynamic> toJson() => {
    'pregnancies'      : pregnancies,
    'glucose'          : glucose,
    'blood_pressure'   : bloodPressure,
    'skin_thickness'   : skinThickness,
    'insulin'          : insulin,
    'bmi'              : bmi,
    'diabetes_pedigree': diabetesPedigree,
    'age'              : age,
  };
}
