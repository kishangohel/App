import 'package:flutter/material.dart';

SnackBar doubleBackWarningSnackBar(BuildContext context) {
  return SnackBar(
    backgroundColor: Theme.of(context).colorScheme.onSurface,
    behavior: SnackBarBehavior.floating,
    content: Text(
      "Press back again to close the app.\nAll onboarding progress "
      "will be deleted.",
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.surface,
          ),
      textAlign: TextAlign.center,
    ),
    margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
  );
}

Future<bool> onWillPopScope(
    BuildContext context, DateTime preBackPress) async {
  final timeGap = DateTime.now().difference(preBackPress);
  final cantExit = timeGap >= const Duration(seconds: 2);
  if (cantExit) {
    final snackBar = SnackBar(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      behavior: SnackBarBehavior.floating,
      content: Text(
        "Press back again to close the app.\nAll onboarding progress "
        "will be deleted.",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.surface,
            ),
        textAlign: TextAlign.center,
      ),
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return false;
  } else {
    return true;
  }
}
