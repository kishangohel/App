import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

/// A switch, name of the permission, and pop up that provides more
// details on the requested permission's purpose.
class PermissionRequestRow extends StatefulWidget {
  final String permissionName;

  /// The function to call when the switch is toggled.
  /// If this is null, the switch will be disabled.
  final void Function()? onChanged;

  /// Whether the switch is set or unset
  final bool switchValue;

  /// The content to show if the user clicks the "More Info" button
  final Widget moreInfoDialog;

  const PermissionRequestRow({
    required this.permissionName,
    required this.onChanged,
    required this.switchValue,
    required this.moreInfoDialog,
  });

  @override
  State<StatefulWidget> createState() => _PermissionRequestRowState();
}

class _PermissionRequestRowState extends State<PermissionRequestRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: FlutterSwitch(
              value: widget.switchValue,
              activeIcon: Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              activeColor: Theme.of(context).colorScheme.onSurface,
              activeToggleColor: Theme.of(context).colorScheme.surface,
              inactiveIcon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              inactiveColor: Theme.of(context).colorScheme.onSurface,
              inactiveToggleColor: Theme.of(context).colorScheme.surface,
              onToggle: (value) async {
                if (widget.onChanged != null) {
                  // Must show info prompt before permission prompt on Android
                  if (Platform.isAndroid) {
                    await showDialog(
                      context: context,
                      builder: (context) => widget.moreInfoDialog,
                    );
                  }
                  widget.onChanged!();
                }
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AutoSizeText(
                widget.permissionName,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium,
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
              child: AutoSizeText(
                "More info",
                maxLines: 1,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
