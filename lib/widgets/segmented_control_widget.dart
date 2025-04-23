import 'package:flutter/material.dart';

class SegmentedControlWidget extends StatefulWidget {
  const SegmentedControlWidget({super.key});

  @override
  State<SegmentedControlWidget> createState() => _SegmentedControlWidgetState();
}

class _SegmentedControlWidgetState extends State<SegmentedControlWidget> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilterChip(label: const Text('Gas'), onSelected: (bool value) {
          // Handle selection
          setState(() {
            isSelected = !isSelected;
          });
        },
        selected: isSelected,),
        const SizedBox(width: 8),
        FilterChip(label: const Text('Agua'), onSelected: (_) {}),
        const SizedBox(width: 8),
        FilterChip(label: const Text('Intrusos'), onSelected: (_) {}),
      ],
    );
  }
}
