// lib/screens/input_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/prediction_result.dart';
import '../services/api_service.dart';
import '../providers/history_provider.dart';
import 'result_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});
  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0; // 0 = Info, 1 = Clinical, 2 = History

  final _ageCtrl        = TextEditingController();
  final _pregnanciesCtrl= TextEditingController();
  final _bmiCtrl        = TextEditingController();
  final _glucoseCtrl    = TextEditingController();
  final _bpCtrl         = TextEditingController();
  final _insulinCtrl    = TextEditingController();
  final _skinCtrl       = TextEditingController();
  final _pedigreeCtrl   = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    for (final c in [_ageCtrl,_pregnanciesCtrl,_bmiCtrl,_glucoseCtrl,_bpCtrl,_insulinCtrl,_skinCtrl,_pedigreeCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) setState(() => _step = (_step + 1).clamp(0, 2));
  }

  void _prevStep() => setState(() => _step = (_step - 1).clamp(0, 2));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final input = DiabetesInput(
      age              : double.tryParse(_ageCtrl.text)         ?? 0,
      pregnancies      : double.tryParse(_pregnanciesCtrl.text) ?? 0,
      bmi              : double.tryParse(_bmiCtrl.text)         ?? 0,
      glucose          : double.tryParse(_glucoseCtrl.text)     ?? 0,
      bloodPressure    : double.tryParse(_bpCtrl.text)          ?? 0,
      insulin          : double.tryParse(_insulinCtrl.text)     ?? 0,
      skinThickness    : double.tryParse(_skinCtrl.text)        ?? 0,
      diabetesPedigree : double.tryParse(_pedigreeCtrl.text)    ?? 0,
    );

    try {
      final result = await ApiService.predict(input);
      if (!mounted) return;
      context.read<HistoryProvider>().addResult(result);
      Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(result: result)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.danger));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: _step > 0 ? _prevStep : () => Navigator.pop(context),
        ),
        title: const Text('Health Assessment'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildStepIndicator(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _step == 0 ? _buildStep0() : _step == 1 ? _buildStep1() : _buildStep2(),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    const labels = ['Info', 'Clinical', 'History'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                decoration: BoxDecoration(
                  color: i <= _step ? AppTheme.primary : AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) => Text(labels[i],
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: i == _step ? FontWeight.w600 : FontWeight.w400,
                color: i == _step ? AppTheme.primary : AppTheme.textMuted,
              ))),
          ),
        ],
      ),
    );
  }

  // ── Step 0: Basic Info ──────────────────────────────────────────────────
  Widget _buildStep0() {
    return Column(key: const ValueKey(0), crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Basic Information'),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _field(_ageCtrl, 'Age', 'years', min: 1, max: 120, required: true)),
        const SizedBox(width: 12),
        Expanded(child: _field(_pregnanciesCtrl, 'Pregnancies', 'count', min: 0, max: 17)),
      ]),
      const SizedBox(height: 14),
      _field(_bmiCtrl, 'BMI', 'kg/m²', min: 10, max: 70, required: true),
      const SizedBox(height: 28),
      _nextBtn('Next: Clinical Data'),
    ]);
  }

  // ── Step 1: Clinical ────────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(key: const ValueKey(1), crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Clinical Measurements'),
      const SizedBox(height: 12),
      _field(_glucoseCtrl, 'Fasting Glucose', 'mg/dL', min: 0, max: 300, required: true,
        icon: Icons.water_drop_outlined, iconColor: AppTheme.danger),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _field(_bpCtrl, 'Blood Pressure', 'mmHg', min: 0, max: 200, required: true,
          icon: Icons.favorite_border, iconColor: AppTheme.danger)),
        const SizedBox(width: 12),
        Expanded(child: _field(_insulinCtrl, 'Insulin', 'μU/ml', min: 0, max: 900,
          hint: 'Optional')),
      ]),
      const SizedBox(height: 28),
      _nextBtn('Next: Family History'),
    ]);
  }

  // ── Step 2: History ─────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(key: const ValueKey(2), crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Family History'),
      const SizedBox(height: 12),
      _field(_pedigreeCtrl, 'Diabetes Pedigree Function', '', min: 0, max: 3,
        hint: 'e.g. 0.47',
        tooltip: 'Scores diabetes likelihood based on family history (0.078–2.42)'),
      const SizedBox(height: 14),
      _field(_skinCtrl, 'Skin Thickness', 'mm', min: 0, max: 100, hint: 'Optional'),
      const SizedBox(height: 28),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Analyze My Risk'),
        ),
      ),
    ]);
  }

  Widget _sectionLabel(String text) {
    return Row(children: [
      Container(width: 3, height: 16, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(text.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 1.0)),
    ]);
  }

  Widget _nextBtn(String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: _nextStep, child: Text(label)),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String unit, {
    double min = 0,
    double max = 999,
    bool required = false,
    String? hint,
    String? tooltip,
    IconData? icon,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          if (icon != null) ...[Icon(icon, size: 13, color: iconColor ?? AppTheme.primary), const SizedBox(width: 4)],
          Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textMid)),
          if (required) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: AppTheme.infoBg, borderRadius: BorderRadius.circular(4)),
              child: Text('Required', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.primary)),
            ),
          ],
          if (tooltip != null) ...[
            const SizedBox(width: 4),
            Tooltip(message: tooltip, child: Icon(Icons.info_outline, size: 13, color: AppTheme.textMuted)),
          ],
        ]),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textDark),
          decoration: InputDecoration(
            hintText: hint ?? (min == 0 ? '0' : min.toStringAsFixed(0)),
            suffixText: unit.isEmpty ? null : unit,
          ),
          validator: (v) {
            if (required && (v == null || v.isEmpty)) return 'Required';
            if (v != null && v.isNotEmpty) {
              final n = double.tryParse(v);
              if (n == null) return 'Invalid number';
              if (n < min || n > max) return '$min–$max';
            }
            return null;
          },
        ),
      ],
    );
  }
}
