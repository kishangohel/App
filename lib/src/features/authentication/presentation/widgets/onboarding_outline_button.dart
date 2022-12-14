import 'package:flutter/material.dart';

class OnboardingOutlineButton extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onPressed;

  const OnboardingOutlineButton({
    Key? key,
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OnboardingOutlineButtonState();
}

class _OnboardingOutlineButtonState extends State<OnboardingOutlineButton> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: widget.child,
      onPressed: widget.onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        alignment: Alignment.center,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
