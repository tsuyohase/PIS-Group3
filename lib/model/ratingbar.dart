import 'package:flutter/material.dart';

//五段階星評価を表示するクラス
class StaticRatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final bool allowHalfRating;

  StaticRatingBar({
    required this.rating,
    this.size = 24.0,
    this.color = Colors.yellow,
    this.allowHalfRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (allowHalfRating) {
          if (rating >= index && rating < index + 1) {
            return Icon(
              Icons.star_half,
              size: size,
              color: color,
            );
          }
        }
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          size: size,
          color: color,
        );
      }),
    );
  }
}
