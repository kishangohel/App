import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class OnboardingOutlineButton extends StatelessWidget {
  final String _text;
  final Function _onPressed;

  const OnboardingOutlineButton({
    required String text,
    required Function onPressed,
  })  : _text = text,
        _onPressed = onPressed;

  @override
  Widget build(BuildContext context) {
    Color _borderTextColor = Colors.white;
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.light) {
      _borderTextColor = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: OutlinedButton(
        child: AutoSizeText(
          _text,
          maxLines: 1,
          style: Theme.of(context).textTheme.headline5?.copyWith(
                color: _borderTextColor,
              ),
        ),
        onPressed: () => _onPressed(),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: _borderTextColor,
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
