/// * Font Awesome 5, Copyright (C) 2016 by Dave Gandy
///         Author:    Dave Gandy
///         License:   SIL (https://github.com/FortAwesome/Font-Awesome/blob/master/LICENSE.txt)
///         Homepage:  http://fortawesome.github.com/Font-Awesome/
///
import 'package:flutter/widgets.dart';

class FixedFontAwesomeIcons {
  FixedFontAwesomeIcons._();

  static const _kFontFam = 'FixedFontAwesomeIcons';
  static const String? _kFontPkg = null;

  /// The original trophy icon is slightly larger than it should be which
  /// causes an issue when a ShaderMask is used to apply a gradient to the Icon
  /// where the edges of the Icon are missing the gradient and the underlying
  /// color is visible. This icon has been manually modified with FontForge to
  /// correct its size.
  static const IconData trophy = IconData(
    0xf091,
    fontFamily: _kFontFam,
    fontPackage: _kFontPkg,
  );
}
