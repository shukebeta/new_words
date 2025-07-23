import 'package:flutter/material.dart';
import 'package:new_words/generated/app_localizations.dart';

/// Public privacy policy screen accessible without authentication
/// 
/// This screen provides the complete privacy policy for the New Words app
/// and is accessible via direct web URL for compliance with app store policies.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const routeName = '/privacy-policy';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.privacyPolicy),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Make it responsive for web
          final isWideScreen = constraints.maxWidth > 800;
          final maxWidth = isWideScreen ? 800.0 : double.infinity;
          
          return Center(
            child: Container(
              width: maxWidth,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Text(
                      localizations.privacyPolicy,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.privacyPolicySubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${localizations.lastUpdated}: December 15, 2024',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Table of Contents
                    _buildSection(
                      context,
                      localizations.tableOfContents,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTocItem(context, '1. ${localizations.informationWeCollect}'),
                          _buildTocItem(context, '2. ${localizations.howWeUseInformation}'),
                          _buildTocItem(context, '3. ${localizations.dataStorageAndSecurity}'),
                          _buildTocItem(context, '4. ${localizations.thirdPartyServices}'),
                          _buildTocItem(context, '5. ${localizations.yourRights}'),
                          _buildTocItem(context, '6. ${localizations.contactInformation}'),
                          _buildTocItem(context, '7. ${localizations.policyUpdates}'),
                        ],
                      ),
                    ),

                    // 1. Information We Collect
                    _buildSection(
                      context,
                      '1. ${localizations.informationWeCollect}',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(localizations.informationWeCollectDescription),
                          const SizedBox(height: 16),
                          Text(
                            localizations.personalInformation,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBulletPoint(context, localizations.emailAddress),
                          _buildBulletPoint(context, localizations.passwordEncrypted),
                          _buildBulletPoint(context, localizations.languagePreferences),
                          const SizedBox(height: 16),
                          Text(
                            localizations.learningData,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBulletPoint(context, localizations.vocabularyWords),
                          _buildBulletPoint(context, localizations.aiGeneratedExplanations),
                          _buildBulletPoint(context, localizations.learningProgress),
                          _buildBulletPoint(context, localizations.storiesAndFavorites),
                        ],
                      ),
                    ),

                    // 2. How We Use Information
                    _buildSection(
                      context,
                      '2. ${localizations.howWeUseInformation}',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(localizations.howWeUseInformationDescription),
                          const SizedBox(height: 16),
                          _buildBulletPoint(context, localizations.provideAppFunctionality),
                          _buildBulletPoint(context, localizations.generateAIExplanations),
                          _buildBulletPoint(context, localizations.trackLearningProgress),
                          _buildBulletPoint(context, localizations.manageUserAccount),
                          _buildBulletPoint(context, localizations.processSubscriptions),
                        ],
                      ),
                    ),

                    // 3. Data Storage and Security
                    _buildSection(
                      context,
                      '3. ${localizations.dataStorageAndSecurity}',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(localizations.dataStorageDescription),
                          const SizedBox(height: 16),
                          Text(
                            localizations.localStorage,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBulletPoint(context, localizations.authenticationTokens),
                          _buildBulletPoint(context, localizations.userPreferences),
                          _buildBulletPoint(context, localizations.appSettings),
                          const SizedBox(height: 16),
                          Text(
                            localizations.serverStorage,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBulletPoint(context, localizations.accountInformation),
                          _buildBulletPoint(context, localizations.vocabularyAndProgress),
                          _buildBulletPoint(context, localizations.aiGeneratedContent),
                        ],
                      ),
                    ),

                    // 4. Third-Party Services
                    _buildSection(
                      context,
                      '4. ${localizations.thirdPartyServices}',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(localizations.thirdPartyServicesDescription),
                          const SizedBox(height: 16),
                          _buildBulletPoint(context, localizations.googlePlayBilling),
                          const SizedBox(height: 16),
                          Text(localizations.noAnalyticsTracking),
                        ],
                      ),
                    ),

                    // 5. Your Rights
                    _buildSection(
                      context,
                      '5. ${localizations.yourRights}',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(localizations.yourRightsDescription),
                          const SizedBox(height: 16),
                          _buildBulletPoint(context, localizations.accessYourData),
                          _buildBulletPoint(context, localizations.updateYourInformation),
                          _buildBulletPoint(context, localizations.deleteYourAccount),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizations.accountDeletionAvailable,
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        localizations.accountDeletionDescription,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 6. Contact Information
                    _buildSection(
                      context,
                      '6. ${localizations.contactInformation}',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(localizations.contactInformationDescription),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New Words App',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Email: newwords.via.stories@gmail.com'),
                                Text('Website: https://newwords.shukebeta.com'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 7. Policy Updates
                    _buildSection(
                      context,
                      '7. ${localizations.policyUpdates}',
                      Text(localizations.policyUpdatesDescription),
                    ),

                    const SizedBox(height: 48), // Extra bottom spacing
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        content,
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTocItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}