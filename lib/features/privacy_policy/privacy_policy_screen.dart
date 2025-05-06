import 'package:flutter/material.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

/// A screen that displays the app's privacy policy
class PrivacyPolicyScreen extends StatelessWidget {
  /// Creates the [PrivacyPolicyScreen]
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/app_logo.png',
                        height: 80,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Last Updated: June 25, 2023',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Introduction'),
              _buildParagraph(
                'CalNutriPal ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how your personal information is collected, used, and disclosed by CalNutriPal. This Privacy Policy applies to our mobile application CalNutriPal, and its associated services.',
              ),
              _buildParagraph(
                'By using CalNutriPal, you agree to the collection and use of information in accordance with this policy.',
              ),
              _buildSectionTitle('Information We Collect'),
              _buildSubsectionTitle('Contact Info'),
              _buildBulletPoint(
                  'Name: We collect your name to personalize your experience.'),
              _buildBulletPoint(
                  'Email Address: Required for account creation and authentication.'),
              _buildBulletPoint(
                  'Phone Number: Not collected unless you choose to provide it for account recovery.'),
              _buildSubsectionTitle('Health & Fitness'),
              _buildBulletPoint(
                  'Health: We collect nutritional intake data, meal records, and calories consumed.'),
              _buildBulletPoint(
                  'Fitness: We collect height, weight, age, gender, and activity level to calculate BMI, calorie needs, and provide personalized nutrition recommendations.'),
              _buildSubsectionTitle('User Content'),
              _buildBulletPoint(
                  'Photos: We may store food images if you choose to add pictures to your meal entries.'),
              _buildBulletPoint(
                  'Customer Support: We collect communications if you contact our support team.'),
              _buildBulletPoint(
                  'Other User Content: Your food logs, meal entries, and custom food items you create.'),
              _buildSubsectionTitle('Usage Data'),
              _buildBulletPoint(
                  'Analytics Data: We collect anonymized app usage information to improve functionality.'),
              _buildBulletPoint(
                  'Diagnostic Information: App performance data to identify and fix issues.'),
              _buildSectionTitle('How We Use Your Information'),
              _buildBulletPoint(
                  'To provide our service: Calculate nutritional needs, track progress, and deliver personalized recommendations.'),
              _buildBulletPoint(
                  'To improve our service: Analyze usage patterns to enhance features and usability.'),
              _buildBulletPoint(
                  'For technical support: Address your questions and troubleshoot issues.'),
              _buildBulletPoint(
                  'For communication: Send important updates about the app or your account.'),
              _buildSectionTitle('Data Sharing and Disclosure'),
              _buildParagraph(
                  'We do not sell your personal information. We may share your information in the following limited circumstances:'),
              _buildBulletPoint(
                  'With third-party service providers who help us operate our services (e.g., cloud storage providers, analytics services)'),
              _buildBulletPoint('To comply with legal obligations'),
              _buildBulletPoint(
                  'To protect our rights, privacy, safety, or property'),
              _buildBulletPoint(
                  'In connection with a business transfer such as a merger or acquisition'),
              _buildSectionTitle('Data Security'),
              _buildParagraph(
                  'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.'),
              _buildSectionTitle('Your Rights'),
              _buildParagraph(
                  'Depending on your location, you may have the right to:'),
              _buildBulletPoint(
                  'Access the personal information we maintain about you'),
              _buildBulletPoint(
                  'Update or correct inaccuracies in your personal information'),
              _buildBulletPoint(
                  'Request deletion of your personal information'),
              _buildBulletPoint('Export your data in a portable format'),
              _buildSectionTitle('Account Deletion'),
              _buildParagraph(
                  'You have the right to delete your account at any time. To delete your account:'),
              _buildBulletPoint('Go to Profile > Account > Delete Account'),
              _buildBulletPoint('Confirm your decision when prompted'),
              _buildParagraph(
                  'When you delete your account, all of your personal information will be permanently removed from our active systems. This process is irreversible.'),
              _buildSectionTitle('Data Retention After Account Deletion'),
              _buildParagraph('After you delete your account:'),
              _buildBulletPoint(
                  'All personal information will be deleted from our active database immediately'),
              _buildBulletPoint(
                  'Backup systems may retain copies of your data for up to 30 days before being automatically purged'),
              _buildBulletPoint(
                  'We may retain anonymized, aggregated data that cannot be used to identify you for analytical purposes'),
              _buildBulletPoint(
                  'We may retain certain information if required by law or for legitimate business purposes, such as resolving disputes or enforcing our agreements'),
              _buildSectionTitle("Children's Privacy"),
              _buildParagraph(
                  'Our service is not directed to children under the age of 13, and we do not knowingly collect personal information from children under 13.'),
              _buildSectionTitle('Changes to This Privacy Policy'),
              _buildParagraph(
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.'),
              _buildSectionTitle('Contact Us'),
              _buildParagraph(
                  'If you have any questions about this Privacy Policy, please contact us at:'),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                child: RichText(
                  text: TextSpan(
                    text: 'Email: ',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                    children: [
                      TextSpan(
                        text: 'privacy@calnutripal.com',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: 'privacy@calnutripal.com',
                            );
                            try {
                              await launchUrl(emailLaunchUri);
                            } catch (e) {
                              debugPrint('Could not launch email: $e');
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '© 2023 CalNutriPal. All rights reserved.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
