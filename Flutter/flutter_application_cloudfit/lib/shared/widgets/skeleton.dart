import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;

  const SkeletonBox({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2C2C2C),
      highlightColor: const Color(0xFF3D3D3D),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}