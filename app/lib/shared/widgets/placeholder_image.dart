import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({
    super.key,
    this.width = double.infinity,
    this.height = 240,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: 0,
    );
  }
}
