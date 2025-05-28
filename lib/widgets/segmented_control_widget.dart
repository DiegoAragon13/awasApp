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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ButtonWidget(label: 'Gas'),
          const SizedBox(width: 8),
          ButtonWidget(label: 'Agua'),
          const SizedBox(width: 8),
          ButtonWidget(label: 'Intrusos'),
          const SizedBox(width: 8),
          ButtonWidget(label: "Temperatura"),
        ],
      ),
    );
  }

}

class ButtonWidget extends StatelessWidget {
  final String label;

  const ButtonWidget({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final providerFilters = Provider.of<SegmentedControlProvider>(context);
    final isSelected = providerFilters.isSelected(label);

    return FilterChip(
      label: Text(label),
      onSelected: (bool selected) {
        selected
            ? providerFilters.addFilter(label)
            : providerFilters.removeFilter(label);
      },
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.tertiary,
    );
  }
}
