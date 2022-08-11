import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

/// A switch, name of the permission, and pop up that provides more
// details on the requested permission's purpose.
class PermissionRequestRow extends StatefulWidget {
  final String permissionName;
  final Future<bool> Function()? onChanged;
  final Widget moreInfoDialog;

  const PermissionRequestRow({
    required this.permissionName,
    required this.onChanged,
    required this.moreInfoDialog,
  });

  @override
  State<StatefulWidget> createState() => _PermissionRequestRowState();
}

class _PermissionRequestRowState extends State<PermissionRequestRow> {
  bool switchValue = false;
  Color borderColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) borderColor = Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Switch(
              value: switchValue,
              onChanged: (widget.onChanged != null)
                  ? (bool value) async {
                      final permitted = await widget.onChanged!();
                      setState(() => switchValue = permitted);
                    }
                  : null,
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AutoSizeText(
                widget.permissionName,
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => widget.moreInfoDialog,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                side: BorderSide(
                  color: borderColor,
                ),
              ),
              child: AutoSizeText(
                "More info",
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
