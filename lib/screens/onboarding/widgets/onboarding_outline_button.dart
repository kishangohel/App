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
    return OutlinedButton(
      child: AutoSizeText(
        widget.text,
        maxLines: 1,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      onPressed: () async {
        if (mounted) await widget.onPressed();
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        alignment: Alignment.center,
      ),
    );
  }
}
