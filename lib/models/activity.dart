import 'package:flutter/material.dart';

class Activity {
  final String id;
  String name;
  Color color;
  int dotsPerUnit;

  Activity({
    required this.id,
    required this.name,
    required this.color,
    this.dotsPerUnit = 1,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color.toARGB32(),
    'dotsPerUnit': dotsPerUnit,
  };

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
    id: j['id'] as String,
    name: j['name'] as String,
    color: Color(j['color'] as int),
    dotsPerUnit: j['dotsPerUnit'] as int? ?? 1,
  );
}

class DaySnapshot {
  final DateTime date;
  final List<DotEntry> dots;

  DaySnapshot({required this.date, required this.dots});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'dots': dots.map((d) => d.toJson()).toList(),
  };

  factory DaySnapshot.fromJson(Map<String, dynamic> j) => DaySnapshot(
    date: DateTime.parse(j['date'] as String),
    dots: (j['dots'] as List).map((e) => DotEntry.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

class DotEntry {
  final String activityId;
  final Color color;
  final DateTime timestamp;

  DotEntry({
    required this.activityId,
    required this.color,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'activityId': activityId,
    'color': color.toARGB32(),
    'timestamp': timestamp.toIso8601String(),
  };

  factory DotEntry.fromJson(Map<String, dynamic> j) => DotEntry(
    activityId: j['activityId'] as String,
    color: Color(j['color'] as int),
    timestamp: DateTime.parse(j['timestamp'] as String),
  );
}
