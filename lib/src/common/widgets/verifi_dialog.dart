import 'package:flutter/material.dart';

/// Shared dialog style.
class VerifiDialog extends StatelessWidget {
  final Widget child;

  const VerifiDialog({required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}
