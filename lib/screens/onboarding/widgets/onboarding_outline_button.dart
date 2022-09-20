import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class OnboardingOutlineButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onPressed;

  const OnboardingOutlineButton({
    required this.text,
    required this.onPressed,
  });

  @override
  State<StatefulWidget> createState() => _OnboardingOutlineButtonState();
}

class _OnboardingOutlineButtonState extends State<OnboardingOutlineButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        child: AutoSizeText(
          widget.text,
          maxLines: 1,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        onPressed: () async {
          if (mounted) await widget.onPressed();
        },
        style: OutlinedButton.styleFrom(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 8.0,
          ),
          side: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: 2.0,
          ),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
