import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  final Function()? onPressed;
  final String text;
  final bool isLoading;

  const BottomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Platform.isIOS ? _iosBuild(context) : _androidBuild(context),
          ),
        ],
      ),
    );
  }

  Widget _androidBuild(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            (MediaQuery.of(context).platformBrightness == Brightness.light)
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primaryContainer,
        foregroundColor:
            (MediaQuery.of(context).platformBrightness == Brightness.light)
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        minimumSize: const Size(
          kMinInteractiveDimension,
          kMinInteractiveDimension,
        ),
      ),
      child: (isLoading) ? const CircularProgressIndicator() : Text(text),
    );
  }

  Widget _iosBuild(BuildContext context) {
    return CupertinoButton.filled(
      onPressed: onPressed,
      minSize: kMinInteractiveDimensionCupertino,
      child: (isLoading) ? const CircularProgressIndicator() : Text(text),
    );
  }
}
