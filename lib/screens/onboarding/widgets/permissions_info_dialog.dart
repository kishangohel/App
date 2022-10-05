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
    Color fontColor = Colors.black;
    Color backgroundColor = Colors.white;
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) {
      fontColor = Colors.white;
      backgroundColor = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Center(
        child: Card(
          color: backgroundColor,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: AutoSizeText(
                    title,
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      contents,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, null),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: BorderSide(
                      color: fontColor,
                    ),
                  ),
                  child: Text(
                    "Close",
                    style: Theme.of(context)
                        .textTheme
                        .button
                        ?.copyWith(fontWeight: FontWeight.w600),
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
