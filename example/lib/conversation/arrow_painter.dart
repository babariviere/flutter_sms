import 'package:flutter/rendering.dart';

enum ArrowDirection { Left, Right }

class ArrowPainter extends CustomPainter {
  final Color color;
  final ArrowDirection direction;
  final _paint = new Paint();

  ArrowPainter({this.color, this.direction}) {
    _paint.color = this.color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    Path path = new Path();

    if (this.direction == ArrowDirection.Left) {
      canvas.translate(56.0, 0.0);
      path.lineTo(-15.0, 0.0);
    } else {
      canvas.translate(size.width - 56.0, 0.0);
      path.lineTo(15.0, 0.0);
    }

    path.lineTo(0.0, 20.0);
    path.lineTo(0.0, 0.0);
    canvas.drawPath(path, _paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
