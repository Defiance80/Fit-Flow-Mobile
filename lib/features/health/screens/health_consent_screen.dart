import 'package:fitflow/common/widgets/custom_app_bar.dart';
import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_colors.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One-time biometric data consent screen.
/// Clients must agree before health data is shared with their trainer.
class HealthConsentScreen extends StatefulWidget {
  final VoidCallback onConsented;

  const HealthConsentScreen({super.key, required this.onConsented});

  @override
  State<HealthConsentScreen> createState() => _HealthConsentScreenState();
}

class _HealthConsentScreenState extends State<HealthConsentScreen> {
  bool _shareActivity = true;
  bool _shareHeartRate = true;
  bool _shareSleep = true;
  bool _shareWeight = false;
  bool _agreedToTerms = false;

  static const String _consentKey = 'health_data_consent_given';

  /// Check if consent was already given
  static Future<bool> hasConsented() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  /// Revoke consent
  static Future<void> revokeConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, false);
  }

  Future<void> _giveConsent() async {
    if (!_agreedToTerms) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);

    // Store granular preferences
    await prefs.setBool('health_share_activity', _shareActivity);
    await prefs.setBool('health_share_heart_rate', _shareHeartRate);
    await prefs.setBool('health_share_sleep', _shareSleep);
    await prefs.setBool('health_share_weight', _shareWeight);

    widget.onConsented();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Health Data Privacy'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: 48,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Center(
              child: CustomText(
                'Your Health Data, Your Control',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Center(
              child: CustomText(
                'Fit Flow can share your health and fitness data with your trainer so they can personalize your training programs. You choose what to share.',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: context.color.onSurface.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // What gets shared section
            CustomText(
              'Choose what to share',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            _buildDataToggle(
              context,
              icon: Icons.directions_walk_rounded,
              title: 'Activity & Steps',
              subtitle: 'Daily steps, calories burned, active minutes',
              value: _shareActivity,
              onChanged: (v) => setState(() => _shareActivity = v),
            ),
            _buildDataToggle(
              context,
              icon: Icons.favorite_rounded,
              title: 'Heart Rate & HRV',
              subtitle: 'Resting heart rate, average HR, heart rate variability',
              value: _shareHeartRate,
              onChanged: (v) => setState(() => _shareHeartRate = v),
            ),
            _buildDataToggle(
              context,
              icon: Icons.bedtime_rounded,
              title: 'Sleep',
              subtitle: 'Sleep duration and quality',
              value: _shareSleep,
              onChanged: (v) => setState(() => _shareSleep = v),
            ),
            _buildDataToggle(
              context,
              icon: Icons.monitor_weight_outlined,
              title: 'Weight & Body Composition',
              subtitle: 'Weight, body fat percentage',
              value: _shareWeight,
              onChanged: (v) => setState(() => _shareWeight = v),
            ),

            const SizedBox(height: 24),

            // Privacy assurances
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.color.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.color.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    'Your Privacy Matters',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildPrivacyPoint(context, Icons.visibility_off_rounded,
                      'Only your assigned trainer can see your data'),
                  _buildPrivacyPoint(context, Icons.lock_rounded,
                      'Data is encrypted and stored securely'),
                  _buildPrivacyPoint(context, Icons.undo_rounded,
                      'You can revoke access at any time in Settings'),
                  _buildPrivacyPoint(context, Icons.delete_outline_rounded,
                      'Request data deletion at any time'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Terms checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                  activeColor: AppColors.primaryColor,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: CustomText(
                        'I understand and consent to sharing my selected health data with my trainer for the purpose of personalized fitness programming.',
                        style: Theme.of(context).textTheme.bodyMedium!,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: _agreedToTerms ? _giveConsent : null,
                title: 'Agree & Continue',
                backgroundColor: _agreedToTerms ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: CustomText(
                  'Not Now',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: context.color.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDataToggle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.color.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.primaryColor.withValues(alpha: 0.3) : context.color.outline,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    title,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  CustomText(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: context.color.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPoint(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Icon(icon, size: 18, color: AppColors.successColor),
          Expanded(
            child: CustomText(
              text,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: context.color.onSurface.withValues(alpha: 0.7),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
