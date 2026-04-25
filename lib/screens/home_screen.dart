import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';
import '../app_colors.dart';
import '../widgets/date_panel.dart';
import '../widgets/dot_matrix_panel.dart';
import '../widgets/activity_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Activity?> _slots = [null, null, null];
  final List<DotEntry> _dots = [];
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      setState(() => _now = DateTime.now());
    });
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final slotsJson = prefs.getString('slots');
    final dotsJson = prefs.getString('dots');
    if (slotsJson != null || dotsJson != null) {
      setState(() {
        if (slotsJson != null) {
          final list = jsonDecode(slotsJson) as List;
          for (int i = 0; i < 3; i++) {
            _slots[i] = list[i] == null ? null : Activity.fromJson(list[i] as Map<String, dynamic>);
          }
        }
        if (dotsJson != null) {
          final list = jsonDecode(dotsJson) as List;
          _dots.addAll(list.map((e) => DotEntry.fromJson(e as Map<String, dynamic>)));
        }
      });
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('slots', jsonEncode(_slots.map((s) => s?.toJson()).toList()));
    await prefs.setString('dots', jsonEncode(_dots.map((d) => d.toJson()).toList()));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onSelectorTapped(int index) {
    if (_slots[index] == null) {
      _showCreateModal(index);
    } else {
      _showActivitySheet(index);
    }
  }

  void _showCreateModal(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (ctx) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(viewInsets: EdgeInsets.zero),
        child: FractionallySizedBox(
          heightFactor: 0.5,
          alignment: Alignment.bottomCenter,
          child: ActivityModal(
            onCreated: (a) { setState(() => _slots[index] = a); _save(); },
          ),
        ),
      ),
    );
  }

  void _showActivitySheet(int index) {
    final activity = _slots[index]!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: activity.color,
                radius: 16,
              ),
              title: Text(
                activity.name,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              subtitle: Text('+${activity.dotsPerUnit} dot${activity.dotsPerUnit > 1 ? 's' : ''} per log'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Log activity'),
              onTap: () {
                Navigator.pop(ctx);
                _log(activity);
              },
            ),
            ListTile(
              leading: const Icon(Icons.undo, color: Colors.orange),
              title: const Text('Undo last log',
                  style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(ctx);
                _undo(activity.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remove activity',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _slots[index] = null);
                _save();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _log(Activity activity) {
    setState(() {
      for (int i = 0; i < activity.dotsPerUnit; i++) {
        _dots.add(DotEntry(
          activityId: activity.id,
          color: activity.color,
          timestamp: DateTime.now(),
        ));
      }
    });
    _save();
  }

  void _undo(String activityId) {
    setState(() {
      for (int i = 0; i < _slots.fold<int>(0, (sum, s) => sum + (s?.id == activityId ? s!.dotsPerUnit : 0)); i++) {
        final lastIndex = _dots.lastIndexWhere((d) => d.activityId == activityId);
        if (lastIndex != -1) _dots.removeAt(lastIndex);
      }
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLime,
      body: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 45,
            child: DatePanel(
              now: _now,
              selectorSlots: _slots,
              completedCount: _dots.length,
              onSelectorTapped: _onSelectorTapped,
            ),
          ),
          Expanded(
            flex: 55,
            child: DotMatrixPanel(dotEntries: _dots, now: _now),

          ),
        ],
      ),
    );
  }
}
