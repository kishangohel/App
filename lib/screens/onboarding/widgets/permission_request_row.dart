import 'package:flutter/material.dart';

class PermissionRequestRow extends StatefulWidget {
  final Function(bool) onChanged;

  const PermissionRequestRow({required this.onChanged});

  @override
  State<StatefulWidget> createState() => _PermissionRequestRowState();
}

class _PermissionRequestRowState extends State<PermissionRequestRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(value: false, onChanged: widget.onChanged),
      ],
    );
  }
}
