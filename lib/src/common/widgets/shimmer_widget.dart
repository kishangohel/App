import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class VShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const VShimmerWidget({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return Shimmer.fromColors(
      baseColor: (brightness == Brightness.light)
          ? Colors.grey[300]!
          : Colors.grey[800]!,
      highlightColor: (brightness == Brightness.light)
          ? Colors.grey[350]!
          : Colors.grey[850]!,
      child: Card(
        margin: margin,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: SizedBox(
          height: height,
          width: width,
        ),
      ),
    );
  }
}
