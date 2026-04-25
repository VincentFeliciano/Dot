import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../app_colors.dart';

// Cyan used for elapsed time progress
const Color kLimeDark = kCyan;

class DatePanel extends StatelessWidget {
  final DateTime now;
  final List<Activity?> selectorSlots;
  final int completedCount;
  final void Function(int) onSelectorTapped;

  const DatePanel({
    super.key,
    required this.now,
    required this.selectorSlots,
    required this.completedCount,
    required this.onSelectorTapped,
  });

  double _timeFraction() {
    // Fraction of the day elapsed: midnight=0.0, end of day=1.0
    return (now.hour * 60.0 + now.minute) / (24 * 60);
  }

  String _dateStr() {
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final y = (now.year % 100).toString().padLeft(2, '0');
    return '$m$d$y';
  }

  @override
  Widget build(BuildContext context) {
    final date = _dateStr();
    final fraction = _timeFraction();

    return LayoutBuilder(builder: (ctx, constraints) {
      final totalH = constraints.maxHeight;
      final totalW = constraints.maxWidth;
      final redH = totalH * 0.18;
      final mainH = totalH - redH;
      // Green grows over the entire panel height (behind red section too)
      final greenH = (totalH * fraction).clamp(0.0, totalH);
      final dotDiam = (totalW * 0.30).clamp(24.0, 44.0);

      return Stack(children: [
        // Bright lime base — remaining time (bottom portion)
        Container(color: kLime),

        // Dark lime — elapsed time, fills from top down
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: greenH,
          child: Container(color: kLimeDark),
        ),

        // Red bottom section
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: redH,
          child: Container(
            color: kRed, // #ff0d1a
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                '$completedCount',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 200,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),

        // Date — rotated 90° CW, top-left corner, smaller size
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: mainH * 0.48,
          child: RotatedBox(
            quarterTurns: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.bottomLeft, // top-left corner of panel
              child: Text(
                date,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  color: kNavy,
                  fontSize: 500,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        ),

        // 24-hour clock — greyscale, left edge, just above the red count box
        Positioned(
          bottom: redH + 6,
          left: 8,
          child: Text(
            '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: kNavy,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
        ),

        // Selector dots — shifted right so they don't overlap the date text
        Positioned(
          left: totalW * 0.50 - 15,
          top: mainH * 0.38 + 130,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => _SelectorDot(
                activity: selectorSlots[i],
                onTap: () => onSelectorTapped(i),
                size: dotDiam,
              ),
            ),
          ),
        ),
      ]);
    });
  }
}

class _SelectorDot extends StatelessWidget {
  final Activity? activity;
  final VoidCallback onTap;
  final double size;

  const _SelectorDot({
    required this.activity,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: size * 0.15),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: activity?.color ?? kNavy,
          shape: BoxShape.circle,
        ),
        child: activity == null
            ? Icon(Icons.add, color: Colors.white, size: size * 0.45)
            : null,
      ),
    );
  }
}
