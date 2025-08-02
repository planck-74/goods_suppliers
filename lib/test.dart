import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Category {
  final String name;
  final Widget illustration;
  final List<Color> gradientColors;
  final double width;
  final double height;

  Category({
    required this.name,
    required this.illustration,
    required this.gradientColors,
    required this.width,
    required this.height,
  });
}

// Custom illustration painters
class ColdDrinkIllustration extends StatelessWidget {
  final double size;
  final bool isHovered;

  const ColdDrinkIllustration(
      {super.key, this.size = 50, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: ColdDrinkPainter(isHovered),
    );
  }
}

class ColdDrinkPainter extends CustomPainter {
  final bool isHovered;
  ColdDrinkPainter(this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Glass
    paint.color = Colors.white.withOpacity(0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center, width: size.width * 0.6, height: size.height * 0.8),
        const Radius.circular(8),
      ),
      paint,
    );

    // Drink
    paint.color = Colors.blue[300]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(center.dx, center.dy + 5),
            width: size.width * 0.5,
            height: size.height * 0.6),
        const Radius.circular(6),
      ),
      paint,
    );

    // Ice cubes
    paint.color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(Offset(center.dx - 8, center.dy - 10), 4, paint);
    canvas.drawCircle(Offset(center.dx + 6, center.dy - 15), 3, paint);

    // Straw
    paint.color = Colors.red[400]!;
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx + 10, center.dy - 20),
      Offset(center.dx + 15, center.dy - 35),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DairyIllustration extends StatelessWidget {
  final double size;
  final bool isHovered;

  const DairyIllustration({super.key, this.size = 50, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: DairyPainter(isHovered),
    );
  }
}

class DairyPainter extends CustomPainter {
  final bool isHovered;
  DairyPainter(this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Milk carton
    paint.color = Colors.white;
    final cartonPath = Path();
    cartonPath.moveTo(center.dx - 15, center.dy + 20);
    cartonPath.lineTo(center.dx - 15, center.dy - 10);
    cartonPath.lineTo(center.dx - 10, center.dy - 20);
    cartonPath.lineTo(center.dx + 10, center.dy - 20);
    cartonPath.lineTo(center.dx + 15, center.dy - 10);
    cartonPath.lineTo(center.dx + 15, center.dy + 20);
    cartonPath.close();
    canvas.drawPath(cartonPath, paint);

    // Top fold
    paint.color = Colors.blue[100]!;
    final topPath = Path();
    topPath.moveTo(center.dx - 10, center.dy - 20);
    topPath.lineTo(center.dx, center.dy - 25);
    topPath.lineTo(center.dx + 10, center.dy - 20);
    canvas.drawPath(topPath, paint);

    // Milk splash
    paint.color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(Offset(center.dx + 20, center.dy - 5), 8, paint);
    canvas.drawCircle(Offset(center.dx + 25, center.dy + 5), 5, paint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy + 8), 4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SugarFlourIllustration extends StatelessWidget {
  final double size;
  final bool isHovered;

  const SugarFlourIllustration(
      {super.key, this.size = 50, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: SugarFlourPainter(isHovered),
    );
  }
}

class SugarFlourPainter extends CustomPainter {
  final bool isHovered;
  SugarFlourPainter(this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Flour bag
    paint.color = Colors.brown[100]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center, width: size.width * 0.7, height: size.height * 0.8),
        const Radius.circular(8),
      ),
      paint,
    );

    // Sugar cubes
    paint.color = Colors.white;
    for (int i = 0; i < 6; i++) {
      final x = center.dx - 10 + (i % 3) * 7;
      final y = center.dy - 5 + (i ~/ 3) * 7;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: 5, height: 5),
          const Radius.circular(1),
        ),
        paint,
      );
    }

    // Flour particles
    paint.color = Colors.white.withOpacity(0.8);
    for (int i = 0; i < 8; i++) {
      final x = center.dx + 15 + (i % 2) * 4;
      final y = center.dy - 15 + i * 3;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PastaIllustration extends StatelessWidget {
  final double size;
  final bool isHovered;

  const PastaIllustration({super.key, this.size = 50, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: PastaPainter(isHovered),
    );
  }
}

class PastaPainter extends CustomPainter {
  final bool isHovered;
  PastaPainter(this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);

    // Pasta strands
    paint.color = Colors.orange[300]!;
    for (int i = 0; i < 8; i++) {
      final path = Path();
      final startX = center.dx - 20 + i * 5;
      path.moveTo(startX, center.dy - 20);
      path.quadraticBezierTo(
        startX + 5,
        center.dy - 10,
        startX - 2,
        center.dy,
      );
      path.quadraticBezierTo(
        startX + 3,
        center.dy + 10,
        startX,
        center.dy + 20,
      );
      canvas.drawPath(path, paint);
    }

    // Bowl
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withOpacity(0.9);
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(center.dx, center.dy + 15), width: 40, height: 20),
      0,
      3.14,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CleaningIllustration extends StatelessWidget {
  final double size;
  final bool isHovered;

  const CleaningIllustration({super.key, this.size = 50, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: CleaningPainter(isHovered),
    );
  }
}

class CleaningPainter extends CustomPainter {
  final bool isHovered;
  CleaningPainter(this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Spray bottle
    paint.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center, width: size.width * 0.4, height: size.height * 0.7),
        const Radius.circular(8),
      ),
      paint,
    );

    // Trigger
    paint.color = Colors.grey[300]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(center.dx + 8, center.dy + 5), width: 15, height: 8),
        const Radius.circular(4),
      ),
      paint,
    );

    // Spray particles
    paint.color = Colors.blue[200]!.withOpacity(0.7);
    for (int i = 0; i < 6; i++) {
      final x = center.dx + 18 + i * 3;
      final y = center.dy - 15 + i * 2;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }

    // Bubbles
    paint.color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(Offset(center.dx - 15, center.dy - 10), 4, paint);
    canvas.drawCircle(Offset(center.dx - 20, center.dy + 5), 3, paint);
    canvas.drawCircle(Offset(center.dx - 12, center.dy + 12), 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CookieIllustration extends StatelessWidget {
  final double size;
  final bool isHovered;

  const CookieIllustration({super.key, this.size = 50, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: CookiePainter(isHovered),
    );
  }
}

class CookiePainter extends CustomPainter {
  final bool isHovered;
  CookiePainter(this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Cookie base
    paint.color = Colors.brown[300]!;
    canvas.drawCircle(center, size.width * 0.35, paint);

    // Chocolate chips
    paint.color = Colors.brown[700]!;
    final chipPositions = [
      Offset(center.dx - 8, center.dy - 6),
      Offset(center.dx + 5, center.dy - 10),
      Offset(center.dx - 4, center.dy + 4),
      Offset(center.dx + 8, center.dy + 6),
      Offset(center.dx + 2, center.dy - 2),
    ];

    for (final pos in chipPositions) {
      canvas.drawCircle(pos, 2.5, paint);
    }

    // Candy
    paint.color = Colors.pink[300]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(center.dx + 20, center.dy - 15),
            width: 12,
            height: 8),
        const Radius.circular(4),
      ),
      paint,
    );

    // Sparkles
    paint.color = Colors.yellow[300]!;
    final sparklePositions = [
      Offset(center.dx - 20, center.dy - 15),
      Offset(center.dx + 25, center.dy + 10),
    ];

    for (final pos in sparklePositions) {
      _drawSparkle(canvas, pos, 3);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = Colors.yellow[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SnacksIllustration extends StatelessWidget {
  final double size;
  final bool isHovered;

  const SnacksIllustration({super.key, this.size = 50, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: SnacksPainter(isHovered),
    );
  }
}

class SnacksPainter extends CustomPainter {
  final bool isHovered;
  SnacksPainter(this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Chips bag
    paint.color = Colors.red[300]!;
    final bagPath = Path();
    bagPath.moveTo(center.dx - 15, center.dy + 20);
    bagPath.lineTo(center.dx - 18, center.dy - 15);
    bagPath.lineTo(center.dx + 18, center.dy - 15);
    bagPath.lineTo(center.dx + 15, center.dy + 20);
    bagPath.close();
    canvas.drawPath(bagPath, paint);

    // Chips spilling out
    paint.color = Colors.orange[200]!;
    final chipPositions = [
      Offset(center.dx + 20, center.dy + 10),
      Offset(center.dx + 25, center.dy + 15),
      Offset(center.dx + 18, center.dy + 18),
    ];

    for (final pos in chipPositions) {
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 8, height: 4),
        paint,
      );
    }

    // Bag label
    paint.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(center.dx, center.dy - 5), width: 20, height: 8),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class JuiceIllustration extends StatelessWidget {
  final double size;
  final bool isHovered;

  const JuiceIllustration({super.key, this.size = 50, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: JuicePainter(isHovered),
    );
  }
}

class JuicePainter extends CustomPainter {
  final bool isHovered;
  JuicePainter(this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Juice box
    paint.color = Colors.orange[100]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center, width: size.width * 0.5, height: size.height * 0.7),
        const Radius.circular(6),
      ),
      paint,
    );

    // Orange slices
    paint.color = Colors.orange[400]!;
    canvas.drawCircle(Offset(center.dx - 5, center.dy), 8, paint);

    // Orange segments
    paint.color = Colors.orange[600]!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    for (int i = 0; i < 6; i++) {
      final angle = i * 3.14 / 3;
      canvas.drawLine(
        Offset(center.dx - 5, center.dy),
        Offset(center.dx - 5 + 8 * 0.7 * cos(angle),
            center.dy + 8 * 0.7 * sin(angle)),
        paint,
      );
    }

    // Straw
    paint.style = PaintingStyle.fill;
    paint.color = Colors.blue[300]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(center.dx + 8, center.dy - 15),
            width: 3,
            height: 20),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WaterIllustration extends StatelessWidget {
  final double size;
  final bool isHovered;

  const WaterIllustration({super.key, this.size = 50, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: WaterPainter(isHovered),
    );
  }
}

class WaterPainter extends CustomPainter {
  final bool isHovered;
  WaterPainter(this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Water bottle
    paint.color = Colors.white.withOpacity(0.9);
    final bottlePath = Path();
    bottlePath.moveTo(center.dx - 8, center.dy + 20);
    bottlePath.lineTo(center.dx - 8, center.dy - 5);
    bottlePath.lineTo(center.dx - 5, center.dy - 15);
    bottlePath.lineTo(center.dx + 5, center.dy - 15);
    bottlePath.lineTo(center.dx + 8, center.dy - 5);
    bottlePath.lineTo(center.dx + 8, center.dy + 20);
    bottlePath.close();
    canvas.drawPath(bottlePath, paint);

    // Water inside
    paint.color = Colors.blue[100]!.withOpacity(0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(center.dx, center.dy + 5), width: 12, height: 25),
        const Radius.circular(2),
      ),
      paint,
    );

    // Cap
    paint.color = Colors.blue[400]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(center.dx, center.dy - 18), width: 10, height: 6),
        const Radius.circular(3),
      ),
      paint,
    );

    // Water drops
    paint.color = Colors.blue[200]!.withOpacity(0.8);
    canvas.drawCircle(Offset(center.dx + 15, center.dy - 5), 3, paint);
    canvas.drawCircle(Offset(center.dx + 20, center.dy + 5), 2, paint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy + 10), 2.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HotDrinksIllustration extends StatelessWidget {
  final double size;
  final bool isHovered;

  const HotDrinksIllustration(
      {super.key, this.size = 50, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: HotDrinksPainter(isHovered),
    );
  }
}

class HotDrinksPainter extends CustomPainter {
  final bool isHovered;
  HotDrinksPainter(this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Coffee cup
    paint.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center, width: size.width * 0.5, height: size.height * 0.6),
        const Radius.circular(8),
      ),
      paint,
    );

    // Coffee
    paint.color = Colors.brown[600]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(center.dx, center.dy + 2),
            width: size.width * 0.4,
            height: size.height * 0.45),
        const Radius.circular(6),
      ),
      paint,
    );

    // Handle
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(center.dx + 15, center.dy), width: 12, height: 16),
      -1.57,
      3.14,
      false,
      paint,
    );

    // Steam
    paint.color = Colors.grey[300]!.withOpacity(0.8);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;

    final steamPaths = [
      _createSteamPath(Offset(center.dx - 8, center.dy - 15)),
      _createSteamPath(Offset(center.dx, center.dy - 15)),
      _createSteamPath(Offset(center.dx + 8, center.dy - 15)),
    ];

    for (final path in steamPaths) {
      canvas.drawPath(path, paint);
    }
  }

  Path _createSteamPath(Offset start) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(
      start.dx + 3,
      start.dy - 5,
      start.dx - 2,
      start.dy - 10,
    );
    path.quadraticBezierTo(
      start.dx - 7,
      start.dy - 15,
      start.dx,
      start.dy - 20,
    );
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CannedGoodsIllustration extends StatelessWidget {
  final double size;
  final bool isHovered;

  const CannedGoodsIllustration(
      {super.key, this.size = 50, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: CannedGoodsPainter(isHovered),
    );
  }
}

class CannedGoodsPainter extends CustomPainter {
  final bool isHovered;
  CannedGoodsPainter(this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Can body
    paint.color = Colors.red[400]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center, width: size.width * 0.4, height: size.height * 0.7),
        const Radius.circular(4),
      ),
      paint,
    );

    // Can top
    paint.color = Colors.grey[300]!;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx, center.dy - size.height * 0.35),
          width: size.width * 0.4,
          height: 6),
      paint,
    );

    // Can bottom
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx, center.dy + size.height * 0.35),
          width: size.width * 0.4,
          height: 6),
      paint,
    );

    // Label
    paint.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center, width: size.width * 0.3, height: size.height * 0.3),
        const Radius.circular(2),
      ),
      paint,
    );

    // Second can (stacked)
    paint.color = Colors.green[400]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(center.dx + 12, center.dy + 5),
            width: size.width * 0.35,
            height: size.height * 0.6),
        const Radius.circular(4),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LegumesIllustration extends StatelessWidget {
  final double size;
  final bool isHovered;

  const LegumesIllustration({super.key, this.size = 50, this.isHovered = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: LegumesPainter(isHovered),
    );
  }
}

class LegumesPainter extends CustomPainter {
  final bool isHovered;
  LegumesPainter(this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Bean pod
    paint.color = Colors.green[400]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center, width: size.width * 0.6, height: size.width * 0.2),
        const Radius.circular(10),
      ),
      paint,
    );

    // Beans inside pod
    paint.color = Colors.green[200]!;
    final beanPositions = [
      Offset(center.dx - 10, center.dy),
      Offset(center.dx - 3, center.dy),
      Offset(center.dx + 4, center.dy),
      Offset(center.dx + 11, center.dy),
    ];

    for (final pos in beanPositions) {
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 5, height: 7),
        paint,
      );
    }

    // Scattered beans
    paint.color = Colors.brown[300]!;
    final scatteredBeans = [
      Offset(center.dx - 15, center.dy + 15),
      Offset(center.dx - 8, center.dy + 18),
      Offset(center.dx + 5, center.dy + 15),
      Offset(center.dx + 15, center.dy + 12),
      Offset(center.dx + 20, center.dy + 18),
    ];

    for (final pos in scatteredBeans) {
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 4, height: 6),
        paint,
      );
    }

    // Leaves
    paint.color = Colors.green[600]!;
    final leafPath = Path();
    leafPath.moveTo(center.dx - 20, center.dy - 8);
    leafPath.quadraticBezierTo(
        center.dx - 25, center.dy - 15, center.dx - 15, center.dy - 18);
    leafPath.quadraticBezierTo(
        center.dx - 10, center.dy - 15, center.dx - 15, center.dy - 8);
    leafPath.close();
    canvas.drawPath(leafPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Category> categories = [
    Category(
      name: 'مشروبات باردة',
      illustration: const ColdDrinkIllustration(),
      gradientColors: [Colors.blue[400]!, Colors.blue[600]!],
      width: 150,
      height: 120,
    ),
    Category(
      name: 'منتجات الألبان',
      illustration: const DairyIllustration(),
      gradientColors: [Colors.orange[300]!, Colors.orange[500]!],
      width: 140,
      height: 130,
    ),
    Category(
      name: 'سكر و دقيق',
      illustration: const SugarFlourIllustration(),
      gradientColors: [Colors.amber[400]!, Colors.amber[600]!],
      width: 130,
      height: 140,
    ),
    Category(
      name: 'مكرونات و نودلز',
      illustration: const PastaIllustration(),
      gradientColors: [Colors.deepOrange[400]!, Colors.deepOrange[600]!],
      width: 160,
      height: 110,
    ),
    Category(
      name: 'منظفات',
      illustration: const CleaningIllustration(),
      gradientColors: [Colors.teal[400]!, Colors.teal[600]!],
      width: 135,
      height: 135,
    ),
    Category(
      name: 'بسكوت و حلوى',
      illustration: const CookieIllustration(),
      gradientColors: [Colors.pink[400]!, Colors.pink[600]!],
      width: 145,
      height: 125,
    ),
    Category(
      name: 'سناكس',
      illustration: const SnacksIllustration(),
      gradientColors: [Colors.red[400]!, Colors.red[600]!],
      width: 125,
      height: 145,
    ),
    Category(
      name: 'عصائر',
      illustration: const JuiceIllustration(),
      gradientColors: [Colors.orange[500]!, Colors.deepOrange[500]!],
      width: 140,
      height: 130,
    ),
    Category(
      name: 'مياه معدنية',
      illustration: const WaterIllustration(),
      gradientColors: [Colors.lightBlue[400]!, Colors.blue[500]!],
      width: 150,
      height: 120,
    ),
    Category(
      name: 'مشروبات ساخنة',
      illustration: const HotDrinksIllustration(),
      gradientColors: [Colors.brown[400]!, Colors.brown[600]!],
      width: 155,
      height: 115,
    ),
    Category(
      name: 'معلبات',
      illustration: const CannedGoodsIllustration(),
      gradientColors: [Colors.purple[400]!, Colors.purple[600]!],
      width: 130,
      height: 140,
    ),
    Category(
      name: 'بقوليات',
      illustration: const LegumesIllustration(),
      gradientColors: [Colors.green[400]!, Colors.green[600]!],
      width: 135,
      height: 135,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _staggerController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[50]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: const Text(
                        'التصنيفات',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    );
                  },
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.red[400]!.withOpacity(0.8),
                        Colors.red[600]!.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return AnimatedBuilder(
                      animation: _staggerController,
                      builder: (context, child) {
                        final animationStart =
                            (index / categories.length) * 0.5;
                        final animationEnd = animationStart + 0.5;

                        final animation = Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(
                          CurvedAnimation(
                            parent: _staggerController,
                            curve: Interval(
                              animationStart,
                              animationEnd,
                              curve: Curves.elasticOut,
                            ),
                          ),
                        );

                        final slideAnimation = Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _staggerController,
                            curve: Interval(
                              animationStart,
                              animationEnd,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                        );

                        return SlideTransition(
                          position: slideAnimation,
                          child: Transform.scale(
                            scale: animation.value,
                            child: CategoryCard(
                              category: categories[index],
                              index: index,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatefulWidget {
  final Category category;
  final int index;

  const CategoryCard({
    super.key,
    required this.category,
    required this.index,
  });

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHover(bool hovering) {
    setState(() {
      _isHovered = hovering;
    });

    if (hovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  Widget _getIllustrationWithHover() {
    switch (widget.category.name) {
      case 'مشروبات باردة':
        return ColdDrinkIllustration(
            size: _isHovered ? 55 : 50, isHovered: _isHovered);
      case 'منتجات الألبان':
        return DairyIllustration(
            size: _isHovered ? 55 : 50, isHovered: _isHovered);
      case 'سكر و دقيق':
        return SugarFlourIllustration(
            size: _isHovered ? 55 : 50, isHovered: _isHovered);
      case 'مكرونات و نودلز':
        return PastaIllustration(
            size: _isHovered ? 55 : 50, isHovered: _isHovered);
      case 'منظفات':
        return CleaningIllustration(
            size: _isHovered ? 55 : 50, isHovered: _isHovered);
      case 'بسكوت و حلوى':
        return CookieIllustration(
            size: _isHovered ? 55 : 50, isHovered: _isHovered);
      case 'سناكس':
        return SnacksIllustration(
            size: _isHovered ? 55 : 50, isHovered: _isHovered);
      case 'عصائر':
        return JuiceIllustration(
            size: _isHovered ? 55 : 50, isHovered: _isHovered);
      case 'مياه معدنية':
        return WaterIllustration(
            size: _isHovered ? 55 : 50, isHovered: _isHovered);
      case 'مشروبات ساخنة':
        return HotDrinksIllustration(
            size: _isHovered ? 55 : 50, isHovered: _isHovered);
      case 'معلبات':
        return CannedGoodsIllustration(
            size: _isHovered ? 55 : 50, isHovered: _isHovered);
      case 'بقوليات':
        return LegumesIllustration(
            size: _isHovered ? 55 : 50, isHovered: _isHovered);
      default:
        return ColdDrinkIllustration(
            size: _isHovered ? 55 : 50, isHovered: _isHovered);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: MouseRegion(
              onEnter: (_) => _handleHover(true),
              onExit: (_) => _handleHover(false),
              child: GestureDetector(
                onTapDown: (_) => _handleHover(true),
                onTapUp: (_) => _handleHover(false),
                onTapCancel: () => _handleHover(false),
                onTap: () {
                  // Add haptic feedback
                  HapticFeedback.lightImpact();

                  // Show selection animation
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: _getIllustrationWithHover(),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.category.name,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      content: const Text('تم اختيار هذا التصنيف!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('موافق'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.category.gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color:
                            widget.category.gradientColors[1].withOpacity(0.4),
                        blurRadius: _isHovered ? 15 : 8,
                        offset: Offset(0, _isHovered ? 8 : 4),
                        spreadRadius: _isHovered ? 2 : 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Animated background effect
                        Positioned.fill(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _isHovered
                                    ? [
                                        widget.category.gradientColors[0]
                                            .withOpacity(0.9),
                                        widget.category.gradientColors[1]
                                            .withOpacity(0.9),
                                      ]
                                    : widget.category.gradientColors,
                              ),
                            ),
                          ),
                        ),

                        // Shimmer effect
                        if (_isHovered)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: const Alignment(-1.0, -1.0),
                                  end: const Alignment(1.0, 1.0),
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.2),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),

                        // Content
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Hero(
                                tag: 'illustration_${widget.index}',
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.all(_isHovered ? 12 : 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: _getIllustrationWithHover(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  widget.category.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _isHovered ? 16 : 14,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
