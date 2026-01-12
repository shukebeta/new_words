import 'package:flutter/foundation.dart';
import 'package:new_words/entities/github_release.dart';
import 'package:new_words/services/update_service.dart';

/// Provider for managing app update state
class UpdateProvider extends ChangeNotifier {
  final UpdateService _updateService;

  GitHubRelease? _availableUpdate;
  bool _isChecking = false;
  bool _isDownloading = false;
  bool _isInstalling = false;
  double _downloadProgress = 0.0;
  String? _errorMessage;
  String? _downloadedApkPath;

  UpdateProvider(this._updateService);

  // Getters
  GitHubRelease? get availableUpdate => _availableUpdate;
  bool get isChecking => _isChecking;
  bool get isDownloading => _isDownloading;
  bool get isInstalling => _isInstalling;
  double get downloadProgress => _downloadProgress;
  String? get errorMessage => _errorMessage;
  bool get hasUpdate => _availableUpdate != null;
  String? get downloadedApkPath => _downloadedApkPath;

  /// Check for available updates
  Future<void> checkForUpdate() async {
    if (_isChecking) return;

    _isChecking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final update = await _updateService.checkForUpdate();
      _availableUpdate = update;
    } catch (e) {
      _errorMessage = 'Failed to check for updates: $e';
      debugPrint(_errorMessage);
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// Download the APK for the available update
  Future<void> downloadUpdate() async {
    if (_isDownloading || _availableUpdate == null) return;

    _isDownloading = true;
    _downloadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      final apkPath = await _updateService.downloadApk(
        _availableUpdate!,
        onProgress: (progress) {
          _downloadProgress = progress;
          notifyListeners();
        },
      );
      _downloadedApkPath = apkPath;
      debugPrint('APK downloaded to: $apkPath');
    } catch (e) {
      _errorMessage = 'Download failed: $e';
      debugPrint(_errorMessage);
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  /// Install the downloaded APK
  Future<void> installUpdate() async {
    if (_isInstalling || _downloadedApkPath == null) return;

    _isInstalling = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _updateService.installApk(_downloadedApkPath!);
      debugPrint('Install result: ${result.type} - ${result.message}');
    } catch (e) {
      _errorMessage = 'Install failed: $e';
      debugPrint(_errorMessage);
    } finally {
      _isInstalling = false;
      notifyListeners();
    }
  }

  /// Complete update flow: download and install
  Future<void> downloadAndInstall() async {
    await downloadUpdate();
    if (_downloadedApkPath != null) {
      await installUpdate();
    }
  }

  /// Clear the available update (dismiss update prompt)
  void dismissUpdate() {
    _availableUpdate = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset all state
  void reset() {
    _availableUpdate = null;
    _isChecking = false;
    _isDownloading = false;
    _isInstalling = false;
    _downloadProgress = 0.0;
    _errorMessage = null;
    _downloadedApkPath = null;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
