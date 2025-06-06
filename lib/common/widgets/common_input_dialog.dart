import 'package:flutter/material.dart';

class CommonInputDialog extends StatefulWidget {
  final String title;
  final List<String? Function(String?)> validators;
  final Future<dynamic> Function(String) onConfirm;

  const CommonInputDialog({
    Key? key,
    required this.title,
    required this.validators,
    required this.onConfirm,
  }) : super(key: key);

  static Future<dynamic> show(
    BuildContext context, {
    required String title,
    required List<String? Function(String?)> validators,
    required Future<dynamic> Function(String) onConfirm,
  }) async {
    return showDialog<dynamic>(
      context: context,
      builder: (context) => CommonInputDialog(
        title: title,
        validators: validators,
        onConfirm: onConfirm,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          )
        );
        if (mounted) setState(() => _isSubmitting = false);
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
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Enter text',
          ),
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
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Confirm'),
        ),
      ],
    );
  }
}
