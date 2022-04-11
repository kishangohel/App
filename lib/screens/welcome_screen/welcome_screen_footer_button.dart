import 'package:flutter/material.dart';

class WelcomeScreenFooterButton extends StatefulWidget {
  final void Function()? initialAction;
  final void Function() completedAction;
  final String? initialButtonText;
  final String completedButtonText;

  const WelcomeScreenFooterButton({
    this.initialAction,
    this.initialButtonText,
    required this.completedAction,
    required this.completedButtonText,
  });

  @override
  State<StatefulWidget> createState() => _WelcomeScreenFooterButtonState();
}

class _WelcomeScreenFooterButtonState extends State<WelcomeScreenFooterButton> {
  bool actionComplete = false;

  @override
  Widget build(BuildContext context) {
    if (widget.initialAction == null && widget.initialButtonText == null) {
      return ElevatedButton(
        onPressed: widget.completedAction,
        child: _WelcomeScreenFooterButton(
          widget.completedButtonText,
        ),
      );
    }
    return (!actionComplete)
        ? ElevatedButton(
            onPressed: () {
              widget.initialAction!();
              setState(() => actionComplete = true);
            },
            child: _WelcomeScreenFooterButton(
              widget.initialButtonText!,
            ),
          )
        : ElevatedButton(
            onPressed: widget.completedAction,
            child: _WelcomeScreenFooterButton(
              widget.completedButtonText,
            ),
          );
  }
}

class _WelcomeScreenFooterButton extends StatelessWidget {
  final String text;

  const _WelcomeScreenFooterButton(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.button!.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
