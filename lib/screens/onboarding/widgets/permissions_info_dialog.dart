import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class PermissionsInfoDialog extends StatelessWidget {
  final String title;
  final String contents;
  const PermissionsInfoDialog({
    required this.title,
    required this.contents,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Center(
        child: Card(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 4.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: AutoSizeText(
                    title,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: AutoSizeText(
                      contents,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text(
                    "Close",
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
