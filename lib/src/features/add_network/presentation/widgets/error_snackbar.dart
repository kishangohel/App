import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

SnackBar errorSnackBar(BuildContext context, String message) => SnackBar(
      content: Container(
        height: 50,
        alignment: Alignment.center,
        child: AutoSizeText(
          message,
          style: Theme.of(context).textTheme.button?.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.all(8.0),
      behavior: SnackBarBehavior.floating,
      elevation: 8.0,
    );
