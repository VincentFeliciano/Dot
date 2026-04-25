import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../app_colors.dart';
import 'date_panel.dart' show kLimeDark;

const Color _kDotGray = Color(0xFFCCCCCC);

class DotMatrixPanel extends StatelessWidget {
  final List<DotEntry> dotEntries;
  final DateTime now;
  final int columns;

  const DotMatrixPanel({
    super.key,
    required this.dotEntries,
    required this.now,
    this.columns = 8,
  });

  double _timeFraction() {
    return (now.hour * 60.0 + now.minute) / (24 * 60);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const spacing = 2.5;
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      final dotWidth = (w - spacing * (columns - 1)) / columns;
      final rows = ((h + spacing) / (dotWidth + spacing)).floor();
      final dotHeight = (h - spacing * (rows - 1)) / rows;
      final totalDots = rows * columns;

      final fraction = _timeFraction();
      final fillH = h * fraction;

      return Stack(children: [
        // Bright lime base — time remaining
        Container(color: kLime),

        // Dark lime — elapsed time progress bar, fills from top
        Positioned(
          top: 0, left: 0, right: 0,
          height: fillH,
          child: Container(color: kLimeDark),
        ),

        // M / N / E + dots on top of background
        Stack(children: [
          // M / N / E background labels — rotated 90° counter-clockwise, behind dots
          Column(children: [
            Expanded(child: _TimeLabel('M')),
            Expanded(child: _TimeLabel('N')),
            Expanded(child: _TimeLabel('E')),
          ]),

          // Dot grid on top
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              mainAxisExtent: dotHeight,
            ),
            itemCount: totalDots,
            itemBuilder: (ctx, index) {
              final isFilled = index < dotEntries.length;
              return _Dot(
                filled: isFilled,
                color: isFilled ? dotEntries[index].color : null,
              );
            },
          ),
        ]),
      ]);
    });
  }
}

class _TimeLabel extends StatelessWidget {
  final String label;
  const _TimeLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3, // 90° counter-clockwise
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.topCenter, // pushes letter to right screen edge
        child: Text(
          label,
          style: TextStyle(
            fontSize: 500,
            fontWeight: FontWeight.w900,
            color: Colors.black.withValues(alpha: 0.28),
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool filled;
  final Color? color;

  const _Dot({required this.filled, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: filled ? color : _kDotGray,
        shape: BoxShape.circle,
      ),
    );
  }
}
