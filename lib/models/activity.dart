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
}
