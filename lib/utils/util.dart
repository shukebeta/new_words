import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_config.dart';
import '../generated/app_localizations.dart';

class Util {
  static void showError(
    ScaffoldMessengerState scaffoldMessengerState,
    String errorMessage,
  ) {
    scaffoldMessengerState.showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: Colors.orange),
    );
  }

  static void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.okButton ?? 'OK'),
            ),
          ],
        );
      },
    );
  }

  static void showInfo(
    ScaffoldMessengerState scaffoldMessengerState,
    String message,
  ) {
    scaffoldMessengerState.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            Colors
                .blue, // Optional: Set a different background color for info messages
      ),
    );
  }

  static void showInfoDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.okButton ?? 'OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<String?> showInputDialog(
    BuildContext context,
    String title,
    String hintText,
  ) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: !AppConfig.isIOSWeb,
            decoration: InputDecoration(hintText: hintText),
            onSubmitted: (value) {
              Navigator.of(context).pop(controller.text); // Submit on Enter
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: Text(AppLocalizations.of(context)?.okButton ?? 'OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)?.cancelButton ?? 'Cancel',
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<Map<String, String>?> showKeywordOrTagDialog(
    BuildContext context,
    String title,
    String hintText,
  ) async {
    TextEditingController controller = TextEditingController();
    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: !AppConfig.isIOSWeb,
            decoration: InputDecoration(hintText: hintText),
            onSubmitted: (value) {
              // Mimic the 'Search' button behavior on submission
              if (controller.text.isNotEmpty) {
                Navigator.of(
                  context,
                ).pop({'action': 'search', 'text': controller.text});
              } else {
                Navigator.of(context).pop(); // Mimic Cancel if empty
              }
            },
          ),
          actions: <Widget>[
            Tooltip(
              // Add Tooltip for Search
              message: 'Search note content for keywords',
              child: TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Navigator.of(
                      context,
                    ).pop({'action': 'search', 'text': controller.text});
                  } else {
                    // Optionally show a message that input is needed for search
                    // Or just do nothing / mimic cancel
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  AppLocalizations.of(context)?.searchButton ?? 'Search',
                ),
              ),
            ),
            Tooltip(
              // Add Tooltip for Go
              message: 'Navigate to tag, date, or note ID',
              child: TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Navigator.of(
                      context,
                    ).pop({'action': 'go', 'text': controller.text});
                  } else {
                    // Optionally show a message that input is needed for go
                    // Or just do nothing / mimic cancel
                    Navigator.of(context).pop();
                  }
                },
                child: Text(AppLocalizations.of(context)?.goButton ?? 'Go'),
              ),
            ),
            Tooltip(
              // Add Tooltip for Cancel
              message: 'Close dialog',
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Returns null for Cancel
                },
                child: Text(
                  AppLocalizations.of(context)?.cancelButton ?? 'Cancel',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static String formatUnixTimestampToLocalDate(
    int unixTimestamp,
    String strFormat,
  ) {
    // Convert Unix timestamp (seconds since epoch) to TZDateTime
    final dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);

    final dateFormat = DateFormat(strFormat);

    // Format the TZDateTime object to a string
    final formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  static String getErrorMessage(dynamic apiResult) {
    return '${apiResult['errorCode']}: ${apiResult['message']}';
  }

  static bool isPasteBoardSupported() {
    return kIsWeb ||
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }

  static bool isImageCompressionSupported() {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }
}
