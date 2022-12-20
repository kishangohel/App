import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class VShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  const VShimmerWidget({
    Key? key,
    required this.width,
    required this.height,
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
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: SizedBox(
          height: height,
          width: width,
        ),
      ),
    );
  }
}