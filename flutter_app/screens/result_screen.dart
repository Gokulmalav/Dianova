// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';
import '../models/prediction_result.dart';
import 'welcome_screen.dart';

class ResultScreen extends StatefulWidget {
  final PredictionResult result;
  const ResultScreen({super.key, required this.result});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get rc => AppTheme.riskColor(widget.result.riskLevel);
  Color get rb => AppTheme.riskBg(widget.result.riskLevel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeIn,
        child: CustomScrollView(
          slivers: [
            _buildHeader(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _buildStats(),
                  const SizedBox(height: 14),
                  _buildRiskBar(),
                  const SizedBox(height: 14),
                  _buildTopFeatures(),
                  const SizedBox(height: 14),
                  _buildRecommendations(),
                  const SizedBox(height: 14),
                  _buildDisclaimer(),
                  const SizedBox(height: 20),
                  _buildActions(context),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.white),
          onPressed: () => Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false),
        ),
      ],
      backgroundColor: AppTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text('Risk Analysis', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 16),
                // Circular gauge
                SizedBox(
                  width: 120, height: 70,
                  child: CircularPercentIndicator(
                    radius: 55,
                    lineWidth: 10,
                    percent: widget.result.probability.clamp(0.0, 1.0),
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.result.probabilityPercent,
                          style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Risk Score', style: GoogleFonts.dmSans(fontSize: 9, color: Colors.white70)),
                      ],
                    ),
                    progressColor: _gaugeColor(),
                    backgroundColor: Colors.white24,
                    startAngle: 180,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: rb.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: rc.withOpacity(0.5), width: 0.5),
                  ),
                  child: Text(
                    widget.result.riskLevel == 'Very High'
                      ? '🚨 Very High Risk'
                      : widget.result.riskLevel == 'High'
                        ? '⚠ High Risk'
                        : widget.result.riskLevel == 'Moderate'
                          ? '⚡ Moderate Risk'
                          : '✓ Low Risk',
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _gaugeColor() {
    switch (widget.result.riskLevel.toLowerCase()) {
      case 'low': return const Color(0xFF7EE8B2);
      case 'moderate': return const Color(0xFFFFD87A);
      case 'high': return const Color(0xFFFFAA6B);
      default: return const Color(0xFFFF8A8A);
    }
  }

  Widget _buildStats() {
    final i = widget.result.input;
    return Row(children: [
      _statCard('Glucose', '${i.glucose.toStringAsFixed(0)}', 'mg/dL', Icons.water_drop_outlined, AppTheme.dangerBg, AppTheme.danger),
      const SizedBox(width: 10),
      _statCard('BMI', i.bmi.toStringAsFixed(1), 'kg/m²', Icons.accessibility_new, AppTheme.infoBg, AppTheme.primary),
      const SizedBox(width: 10),
      _statCard('Age', '${i.age.toStringAsFixed(0)}', 'years', Icons.person_outline, AppTheme.successBg, AppTheme.success),
    ]);
  }

  Widget _statCard(String label, String val, String unit, IconData icon, Color bg, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Column(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(height: 6),
          Text(val, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          Text(unit, style: GoogleFonts.dmSans(fontSize: 9, color: AppTheme.textMuted)),
          Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.textMid)),
        ]),
      ),
    );
  }

  Widget _buildRiskBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Risk Probability', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        const SizedBox(height: 12),
        LinearPercentIndicator(
          width: MediaQuery.of(context).size.width - 64,
          lineHeight: 16,
          percent: widget.result.probability.clamp(0.0, 1.0),
          backgroundColor: AppTheme.border,
          linearGradient: const LinearGradient(
            colors: [Color(0xFF3B6D11), Color(0xFFFFB347), Color(0xFFE24B4A)],
          ),
          barRadius: const Radius.circular(8),
          center: Text(widget.result.probabilityPercent,
            style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Low', style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.success)),
          Text('Moderate', style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.warning)),
          Text('High', style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.danger)),
        ]),
      ]),
    );
  }

  Widget _buildTopFeatures() {
    final sorted = widget.result.featureImportance.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top4 = sorted.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Key Risk Factors', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        const SizedBox(height: 12),
        ...top4.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            SizedBox(width: 100, child: Text(e.key, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMid))),
            Expanded(
              child: LinearPercentIndicator(
                lineHeight: 8,
                percent: e.value.clamp(0.0, 1.0),
                backgroundColor: AppTheme.border,
                progressColor: AppTheme.primary,
                barRadius: const Radius.circular(4),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 8),
            Text('${(e.value * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary)),
          ]),
        )),
      ]),
    );
  }

  Widget _buildRecommendations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.lightbulb_outline, size: 16, color: AppTheme.warning),
          const SizedBox(width: 6),
          Text('Recommendations', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        ]),
        const SizedBox(height: 12),
        ...widget.result.recommendations.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 6, height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: rc),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(rec, style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMid, height: 1.5))),
          ]),
        )),
      ]),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warningBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFAD87A), width: 0.5),
      ),
      child: Row(children: [
        Icon(Icons.warning_amber_rounded, size: 15, color: AppTheme.warning),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'This is not a medical diagnosis. Please consult a qualified healthcare professional.',
            style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.warning, height: 1.4),
          ),
        ),
      ]),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text('New Assessment', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: () => Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false),
          child: const Text('Home'),
        ),
      ),
    ]);
  }
}
