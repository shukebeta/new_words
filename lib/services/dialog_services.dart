import 'package:flutter/material.dart';

class DialogService {
  static Future<bool?> showUnsavedChangesDialog(BuildContext context) {
    return showConfirmDialog(context,
        title: 'Unsaved changes',
        text: 'You have unsaved changes. Do you really want to leave?');
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    String title = 'Yes to confirm.',
    String text = "Are you sure?",
    String noText = 'Cancel',
    String yesText = 'Yes',
    Function? yesCallback,
    Function? noCallback,
  }) async {
    var result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(noText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(yesText),
          ),
        ],
      ),
    );
    if (result != null) {
      if (result && yesCallback != null) yesCallback();
      if (!result && noCallback != null) noCallback();
    }
    return result;
  }
}
