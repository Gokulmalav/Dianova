// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'input_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Hero gradient header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 40,
              bottom: 36,
              left: 24,
              right: 24,
            ),
            child: Column(
              children: [
                // App icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.monitor_heart_outlined, color: Colors.white, size: 38),
                ),
                const SizedBox(height: 16),
                Text('Dianova',
                  style: GoogleFonts.dmSans(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Your AI Diabetes Risk Companion',
                  style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),

          // Features list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  _FeatureCard(
                    icon: Icons.bolt_outlined,
                    iconBg: AppTheme.infoBg,
                    iconColor: AppTheme.primary,
                    title: 'Instant Analysis',
                    subtitle: 'Get your personalized risk score in seconds',
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    icon: Icons.lock_outline_rounded,
                    iconBg: AppTheme.successBg,
                    iconColor: AppTheme.success,
                    title: '100% Private',
                    subtitle: 'All data processed on-device, never stored',
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    icon: Icons.show_chart_rounded,
                    iconBg: AppTheme.warningBg,
                    iconColor: AppTheme.warning,
                    title: 'Track Progress',
                    subtitle: 'Monitor your risk trends over time',
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    icon: Icons.recommend_outlined,
                    iconBg: const Color(0xFFF3EEFF),
                    iconColor: const Color(0xFF6B3FC7),
                    title: 'Smart Recommendations',
                    subtitle: 'Actionable health tips based on your data',
                  ),
                  const SizedBox(height: 28),

                  // Start button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const InputScreen())),
                      child: const Text('Start Assessment'),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warningBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFAD87A), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'For informational purposes only. Not a medical diagnosis.',
                            style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  const _FeatureCard({required this.icon, required this.iconBg, required this.iconColor, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
