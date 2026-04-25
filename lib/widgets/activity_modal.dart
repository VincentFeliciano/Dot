import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../app_colors.dart';

const List<Color> kActivityColors = [
  // DOTTYCOLORS
  kNavy,
  kRed,
  kLime,
  kCyan,
  kGreen,
  // DOTTYCOLORS2
  Color(0xFF000000),
  Color(0xFF0100AB),
  Color(0xFF00AB00),
  Color(0xFF00AAA9),
  Color(0xFFAB0001),
  Color(0xFFAA00AB),
  Color(0xFF5655FF),
  Color(0xFF56FF56),
  Color(0xFF54FFFE),
  Color(0xFFFF5556),
  Color(0xFFFE55FE),
  Color(0xFFFEFF54),
  Color(0xFFFFFFFF),
];

class ActivityModal extends StatefulWidget {
  final void Function(Activity) onCreated;

  const ActivityModal({super.key, required this.onCreated});

  @override
  State<ActivityModal> createState() => _ActivityModalState();
}

class _ActivityModalState extends State<ActivityModal> {
  final _nameController = TextEditingController();
  Color _selectedColor = kActivityColors[0];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _create() {
    if (_nameController.text.trim().isEmpty) return;
    widget.onCreated(Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      color: _selectedColor,
      dotsPerUnit: 1,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kRed,
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const Text(
            'NEW ACTIVITY',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 14),

          // Name field
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _create(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
            decoration: const InputDecoration(
              hintText: 'Activity name',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54, width: 1.5),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Color picker — wrap grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kActivityColors.map((c) {
              final selected = _selectedColor == c;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: Container(
                  width: selected ? 30 : 24,
                  height: selected ? 30 : 24,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.white30,
                      width: selected ? 2.5 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const Spacer(),

          // Create button — large text, no background
          GestureDetector(
            onTap: _create,
            child: const SizedBox(
              width: double.infinity,
              child: Text(
                'CREATE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 6,
                  height: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
