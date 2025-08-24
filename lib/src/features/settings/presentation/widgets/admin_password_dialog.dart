import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AdminPasswordDialog extends StatefulWidget {
  const AdminPasswordDialog({super.key});

  @override
  State<AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<AdminPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // Auto focus the password field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(Icons.security, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text('settings_admin_password'.tr()),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'settings_security_desc'.tr(),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            focusNode: _focusNode,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Şifre',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.key),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            onFieldSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                Navigator.of(context).pop(value.trim());
              }
            },
          ),

        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('action_cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_passwordController.text.trim().isNotEmpty) {
              Navigator.of(context).pop(_passwordController.text.trim());
            }
          },
          child: Text('action_ok'.tr()),
        ),
      ],
    );
  }
}
