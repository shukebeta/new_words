import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../generated/app_localizations.dart';

class CommonInputDialog extends StatefulWidget {
  final String title;
  final List<String? Function(String?)> validators;
  final Future<dynamic> Function(String) onConfirm;
  final AppLocalizations localizations;
  final String? confirmButtonText;

  const CommonInputDialog({
    super.key,
    required this.title,
    required this.validators,
    required this.onConfirm,
    required this.localizations,
    this.confirmButtonText,
  });

  static Future<dynamic> show(
    BuildContext context, {
    required String title,
    required List<String? Function(String?)> validators,
    required Future<dynamic> Function(String) onConfirm,
    AppLocalizations? localizations,
    String? confirmButtonText,
  }) async {
    final l10n = localizations ?? AppLocalizations.of(context)!;
    return showDialog<dynamic>(
      context: context,
      builder: (context) => CommonInputDialog(
        title: title,
        validators: validators,
        onConfirm: onConfirm,
        localizations: l10n,
      ),
    );
  }

  @override
  State<CommonInputDialog> createState() => _CommonInputDialogState();
}

class _CommonInputDialogState extends State<CommonInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool _isSubmitting = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final result = await widget.onConfirm(_textController.text);
        if (mounted) {
          Navigator.of(context).pop(result);
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _textController,
          autofocus: !AppConfig.isIOSWeb,
          validator: (value) {
            for (final validator in widget.validators) {
              final error = validator(value);
              if (error != null) return error;
            }
            return null;
          },
          onFieldSubmitted: (value) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(widget.localizations.cancelButton),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.confirmButtonText ?? widget.localizations.confirmButton),
        ),
      ],
    );
  }
}
