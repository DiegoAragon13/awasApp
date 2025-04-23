import 'package:awas_app/providers/segmented_control_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SegmentedControlWidget extends StatefulWidget {
  const SegmentedControlWidget({super.key});

  @override
  State<SegmentedControlWidget> createState() => _SegmentedControlWidgetState();
}

class _SegmentedControlWidgetState extends State<SegmentedControlWidget> {
  //TODO method to handle the selection of the buttons



  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ButtonWidget(label: 'Gas'),
        const SizedBox(width: 8),
        ButtonWidget(label: 'Agua'),
        const SizedBox(width: 8),
        ButtonWidget(label: 'Intrusos'),
      ],
    );
  }
}

class ButtonWidget extends StatefulWidget {
  final String label; 
  
  const ButtonWidget({
    super.key, required this.label,
  });

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  bool isSelected = false;
  

  @override
  Widget build(BuildContext context) {
    final providerFilters = Provider.of<SegmentedControlProvider>(context);
    return FilterChip(label: Text(widget.label), onSelected: (bool value) {
          // Handle selection
          setState(() {
            isSelected = !isSelected;
            isSelected ? providerFilters.addFilter(widget.label) : providerFilters.removeFilter(widget.label);
          });
        },
        selected: isSelected,
        selectedColor: Theme.of(context).colorScheme.tertiary);
  }
}
