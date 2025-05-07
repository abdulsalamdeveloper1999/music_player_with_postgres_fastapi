import 'package:flutter/material.dart';

class MusicThemeBackground extends StatelessWidget {
  final Widget child;

  const MusicThemeBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1E2E), // Dark purple
            Color(0xFF0D0D14), // Near black
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background music elements
          _buildBackgroundElements(),

          // Main content
          child,
        ],
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        // Music notes
        Positioned(
          top: 40,
          right: 30,
          child: _buildMusicNote(50, Color(0xFF6A3DE8).withOpacity(0.3)),
        ),
        Positioned(
          bottom: 50,
          left: 30,
          child: _buildMusicNote(60, Color(0xFF3D7BE8).withOpacity(0.3)),
        ),
        Positioned(
          top: 140,
          left: 40,
          child: _buildMusicNote(30, Color(0xFFE83D7B).withOpacity(0.3)),
        ),

        // Equalizer bars
        Positioned(
          bottom: 120,
          right: 40,
          child: _buildEqualizerBars(50, Color(0xFFE83D7B).withOpacity(0.3)),
        ),

        // Music symbols
        Positioned(
          top: 220,
          right: 60,
          child: _buildMusicSymbol(40, Color(0xFF6A3DE8).withOpacity(0.3)),
        ),

        // Vinyl record
        Positioned(
          bottom: 200,
          left: 20,
          child: _buildVinylRecord(80, Color(0xFF3D7BE8).withOpacity(0.2)),
        ),

        // Wave pattern
        Positioned(
          top: 300,
          left: 0,
          right: 0,
          child: _buildWavePattern(Color(0xFF6A3DE8).withOpacity(0.1)),
        ),
      ],
    );
  }

  Widget _buildMusicNote(double size, Color color) {
    return Container(
      width: size,
      height: size * 1.5,
      child: CustomPaint(
        painter: MusicNotePainter(color: color),
      ),
    );
  }

  Widget _buildEqualizerBars(double size, Color color) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: EqualizerPainter(color: color),
      ),
    );
  }

  Widget _buildMusicSymbol(double size, Color color) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: MusicSymbolPainter(color: color),
      ),
    );
  }

  Widget _buildVinylRecord(double size, Color color) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: VinylRecordPainter(color: color),
      ),
    );
  }

  Widget _buildWavePattern(Color color) {
    return Container(
      height: 100,
      width: double.infinity,
      child: CustomPaint(
        painter: WavePatternPainter(color: color),
      ),
    );
  }
}

// Custom painter for music note
class MusicNotePainter extends CustomPainter {
  final Color color;

  MusicNotePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw note head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.7, size.height * 0.8),
        width: size.width * 0.6,
        height: size.width * 0.4,
      ),
      paint,
    );

    // Draw note stem
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.9,
        size.height * 0.2,
        size.width * 0.1,
        size.height * 0.6,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for equalizer bars
class EqualizerPainter extends CustomPainter {
  final Color color;

  EqualizerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final barWidth = size.width / 5;

    // Draw equalizer bars with varying heights
    final heights = [0.4, 0.7, 0.9, 0.5, 0.8];

    for (int i = 0; i < heights.length; i++) {
      final barHeight = size.height * heights[i];
      final barX = i * barWidth;
      final barY = size.height - barHeight;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barWidth * 0.7, barHeight),
          Radius.circular(barWidth * 0.3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for treble clef music symbol
class MusicSymbolPainter extends CustomPainter {
  final Color color;

  MusicSymbolPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final Path path = Path();

    // Simplified treble clef
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.2,
        size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.6,
        size.width * 0.5, size.height * 0.9);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for vinyl record
class VinylRecordPainter extends CustomPainter {
  final Color color;

  VinylRecordPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Outer circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // Inner circle (hole)
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 10,
      Paint()..color = Color(0xFF0D0D14),
    );

    // Record grooves
    for (double i = 0.2; i <= 0.9; i += 0.15) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 2 * i,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for wave pattern (sound wave)
class WavePatternPainter extends CustomPainter {
  final Color color;

  WavePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    // Starting point
    path.moveTo(0, size.height / 2);

    // Wave pattern along the width
    final waveCount = 6;
    final waveHeight = size.height / 4;

    for (int i = 0; i <= waveCount; i++) {
      final x1 = size.width / waveCount * (i + 0.25);
      final x2 = size.width / waveCount * (i + 0.75);
      final endX = size.width / waveCount * (i + 1);

      path.cubicTo(x1, size.height / 2 - waveHeight, x2,
          size.height / 2 + waveHeight, endX, size.height / 2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
