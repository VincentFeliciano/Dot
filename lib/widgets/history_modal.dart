import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../app_colors.dart';

class HistoryModal extends StatelessWidget {
  final List<DaySnapshot> snapshots;

  const HistoryModal({super.key, required this.snapshots});

  @override
  Widget build(BuildContext context) {
    final sorted = [...snapshots]..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      color: kNavy,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'HISTORY',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: sorted.isEmpty
                ? const Center(
                    child: Text(
                      'No previous days yet.',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: sorted.length,
                    itemBuilder: (ctx, i) => _SnapshotCard(snapshot: sorted[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final DaySnapshot snapshot;
  const _SnapshotCard({required this.snapshot});

  String _dateLabel() {
    final d = snapshot.date;
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Map<int, Color> _buildCellMap() {
    final map = <int, Color>{};
    for (final entry in snapshot.dots) {
      final row = entry.timestamp.hour.clamp(0, 23);
      int col = (entry.timestamp.minute / 6).floor().clamp(0, 9);
      while (col < 10 && map.containsKey(row * 10 + col)) col++;
      if (col < 10) map[row * 10 + col] = entry.color;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final cellMap = _buildCellMap();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _dateLabel(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${snapshot.dots.length} dot${snapshot.dots.length != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MiniGrid(cellMap: cellMap),
        ],
      ),
    );
  }
}

class _MiniGrid extends StatelessWidget {
  final Map<int, Color> cellMap;
  const _MiniGrid({required this.cellMap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      const cols = 10;
      const rows = 24;
      const spacing = 1.5;
      final dotSize = (constraints.maxWidth - spacing * (cols - 1)) / cols;
      final height = dotSize * rows + spacing * (rows - 1);

      return SizedBox(
        height: height,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: dotSize,
          ),
          itemCount: rows * cols,
          itemBuilder: (ctx, index) {
            final color = cellMap[index];
            return Container(
              decoration: BoxDecoration(
                color: color ?? Colors.white24,
                borderRadius: BorderRadius.circular(dotSize / 2),
              ),
            );
          },
        ),
      );
    });
  }
}
