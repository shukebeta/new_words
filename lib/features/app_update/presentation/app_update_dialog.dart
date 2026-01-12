import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:new_words/providers/update_provider.dart';
import 'package:new_words/generated/app_localizations.dart';

/// Dialog showing available app update with download and install options
class AppUpdateDialog extends StatefulWidget {
  const AppUpdateDialog({super.key});

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  String _getCurrentVersion() {
    return _packageInfo?.version ?? '?';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Consumer<UpdateProvider>(
      builder: (context, provider, child) {
        final release = provider.availableUpdate;

        if (release == null) {
          return const SizedBox.shrink();
        }

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.system_update_alt,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.appUpdateAvailable),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Version info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.newVersionAvailable} ${release.version}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.currentVersion} ${_getCurrentVersion()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Release notes
                if (release.body != null && release.body!.isNotEmpty) ...[
                  Text(
                    l10n.releaseNotes,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.dividerColor,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: MarkdownBody(
                        data: release.body!,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Download progress
                if (provider.isDownloading) ...[
                  LinearProgressIndicator(
                    value: provider.downloadProgress,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.downloadProgress} ${(provider.downloadProgress * 100).toInt()}%',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                ],

                // Installing status
                if (provider.isInstalling) ...[
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.installingUpdate,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Error message
                if (provider.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            // Later button (only when not downloading/installing)
            if (!provider.isDownloading && !provider.isInstalling)
              TextButton(
                onPressed: () {
                  provider.dismissUpdate();
                  Navigator.of(context).pop();
                },
                child: Text(l10n.laterButton),
              ),

            // Update/Download button
            if (!provider.isDownloading && !provider.isInstalling)
              ElevatedButton(
                onPressed: provider.downloadedApkPath != null
                    ? () => provider.installUpdate()
                    : () => provider.downloadAndInstall(),
                child: Text(
                  provider.downloadedApkPath != null
                      ? l10n.installingUpdate
                      : l10n.updateButton,
                ),
              ),
          ],
        );
      },
    );
  }
}
