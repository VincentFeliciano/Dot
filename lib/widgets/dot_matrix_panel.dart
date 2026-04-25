import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../app_colors.dart';
import 'date_panel.dart' show kLimeDark;

const Color _kDotGray = Color(0xFFCCCCCC);
const int _kCols = 10;
const int _kRows = 24;
const double _kSpacing = 2.0;

class DotMatrixPanel extends StatelessWidget {
  final List<DotEntry> dotEntries;
  final DateTime now;

  const DotMatrixPanel({
    super.key,
    required this.dotEntries,
    required this.now,
  });

  double _timeFraction() {
    return (now.hour * 60.0 + now.minute) / (24 * 60);
  }

  // Maps grid index (row*10+col) → color for filled dots.
  // Row = hour (0-23), col = minute-slot (floor(minute/6), 0-9).
  // If target slot is taken, shifts right until an empty slot is found.
  Map<int, Color> _buildCellMap() {
    final map = <int, Color>{};
    for (final entry in dotEntries) {
      final row = entry.timestamp.hour.clamp(0, 23);
      int col = (entry.timestamp.minute / 6).floor().clamp(0, 9);
      while (col < _kCols && map.containsKey(row * _kCols + col)) {
        col++;
      }
      if (col < _kCols) {
        map[row * _kCols + col] = entry.color;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      // Dots are square based on column width; row spacing expands to fill height
      final dotSize = (w - _kSpacing * (_kCols - 1)) / _kCols;
      final rowSpacing = (h - dotSize * _kRows) / (_kRows - 1);
      final radius = BorderRadius.circular(dotSize / 2);
      final fraction = _timeFraction();
      final fillH = h * fraction;
      final cellMap = _buildCellMap();

      return Stack(children: [
        Container(color: kLime),
        Positioned(
          top: 0, left: 0, right: 0,
          height: fillH,
          child: Container(color: kLimeDark),
        ),
        Stack(children: [
          Column(children: [
            Expanded(child: _TimeLabel('M')),
            Expanded(child: _TimeLabel('N')),
            Expanded(child: _TimeLabel('E')),
          ]),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _kCols,
              crossAxisSpacing: _kSpacing,
              mainAxisSpacing: rowSpacing,
              mainAxisExtent: dotSize,
            ),
            itemCount: _kRows * _kCols,
            itemBuilder: (ctx, index) {
              final color = cellMap[index];
              return _Dot(filled: color != null, color: color, radius: radius);
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
  final BorderRadius radius;

  const _Dot({required this.filled, required this.radius, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: filled ? color : _kDotGray,
        borderRadius: radius,
      ),
    );
  }
}
