// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/history_provider.dart';
import '../models/prediction_result.dart';
import 'result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('My History'),
            actions: [
              if (provider.totalTests > 0)
                TextButton.icon(
                  onPressed: () => _confirmClear(context, provider),
                  icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.danger),
                  label: Text('Clear', style: GoogleFonts.dmSans(color: AppTheme.danger, fontSize: 13)),
                ),
            ],
          ),
          body: provider.totalTests == 0
            ? _buildEmpty()
            : _buildContent(context, provider),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.history, size: 56, color: AppTheme.border),
        const SizedBox(height: 16),
        Text('No assessments yet', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textMid)),
        const SizedBox(height: 6),
        Text('Your past results will appear here', style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted)),
      ]),
    );
  }

  Widget _buildContent(BuildContext context, HistoryProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildOverviewCard(provider),
        const SizedBox(height: 14),
        _buildDistribution(provider),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('PAST ASSESSMENTS',
            style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.0)),
        ),
        const SizedBox(height: 10),
        ...provider.history.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _HistoryItem(result: r, onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(result: r)))),
        )),
      ]),
    );
  }

  Widget _buildOverviewCard(HistoryProvider p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('YOUR OVERVIEW', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white70, letterSpacing: 0.8)),
        const SizedBox(height: 12),
        Row(children: [
          _overviewStat('${p.totalTests}', 'Total Tests'),
          _divider(),
          _overviewStat(p.averageRiskPercent, 'Avg Risk'),
          _divider(),
          _overviewStat(
            p.latest?.riskLevel ?? '-',
            'Latest',
            color: p.latest != null
                ? AppTheme.riskColor(p.latest!.riskLevel)
                : Colors.white,
          ),
        ]),
      ]),
    );
  }

  Widget _overviewStat(String val, String label, {Color color = Colors.white}) {
    return Expanded(child: Column(children: [
      Text(val, style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white60)),
    ]));
  }

  Widget _divider() => Container(width: 0.5, height: 36, color: Colors.white24);

  Widget _buildDistribution(HistoryProvider p) {
    final dist = p.riskDistribution;
    final total = p.totalTests;
    final colors = {
      'Low': AppTheme.success,
      'Moderate': AppTheme.warning,
      'High': const Color(0xFFE07B39),
      'Very High': AppTheme.danger,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Risk Distribution', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        const SizedBox(height: 12),
        ...['Low','Moderate','High','Very High'].map((level) {
          final count = dist[level] ?? 0;
          final pct = total > 0 ? count / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: colors[level])),
              const SizedBox(width: 8),
              SizedBox(width: 70, child: Text(level, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMid))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation(colors[level]),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 32, child: Text('${(pct * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted), textAlign: TextAlign.right)),
            ]),
          );
        }),
      ]),
    );
  }

  void _confirmClear(BuildContext context, HistoryProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Clear History', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
        content: Text('Delete all assessment records?', style: GoogleFonts.dmSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () { provider.clearHistory(); Navigator.pop(context); },
            child: Text('Clear', style: GoogleFonts.dmSans(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final PredictionResult result;
  final VoidCallback onTap;
  const _HistoryItem({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(result.riskLevel);
    final bg    = AppTheme.riskBg(result.riskLevel);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_formatDate(result.timestamp), style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                Text(_formatTime(result.timestamp), style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Text(result.riskLevel, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _val('${result.input.glucose.toStringAsFixed(0)}', 'Glucose'),
            _val(result.input.bmi.toStringAsFixed(1), 'BMI'),
            _val('${result.input.age.toStringAsFixed(0)}yr', 'Age'),
            _val(result.probabilityPercent, 'Risk', color: color),
          ]),
        ]),
      ),
    );
  }

  Widget _val(String v, String l, {Color? color}) => Expanded(child: Column(children: [
    Text(v, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: color ?? AppTheme.textDark)),
    Text(l, style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.textMuted)),
  ]));

  String _formatDate(DateTime d) => '${_month(d.month)} ${d.day}, ${d.year}';
  String _formatTime(DateTime d) => '${d.hour % 12 == 0 ? 12 : d.hour % 12}:${d.minute.toString().padLeft(2,'0')} ${d.hour >= 12 ? 'PM' : 'AM'}';
  String _month(int m) => ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];
}
