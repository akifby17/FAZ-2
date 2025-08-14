import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../pages/fabric_operations_page.dart';

Future<void> showFabricDialog(BuildContext context,
    {String initialLoomsText = ''}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'fabric_ops_title'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _WideActionButton(
                text: 'fabric_start_order'.tr(),
                onPressed: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (ctx) =>
                        FabricStartDialog(initialLoomsText: initialLoomsText),
                  );
                },
              ),
              const SizedBox(height: 16),
              _WideActionButton(
                text: 'fabric_stop_order'.tr(),
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: navigate to stop flow
                },
              ),
              const SizedBox(height: 16),
              _WideActionButton(
                text: 'fabric_finish_order'.tr(),
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: navigate to finish flow
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _WideActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _WideActionButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F4D78),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
