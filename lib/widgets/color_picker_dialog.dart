import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ColorPickerDialog extends StatelessWidget {
  final String? selectedColor;
  final ValueChanged<String?> onColorSelected;

  const ColorPickerDialog({
    super.key,
    this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Color'),
      content: SizedBox(
        width: 300,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: AppTheme.noteColors.length,
          itemBuilder: (context, index) {
            final color = AppTheme.noteColors[index];
            final isSelected = selectedColor == '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
            
            return GestureDetector(
              onTap: () {
                onColorSelected('#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}');
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 0),
                            blurRadius: 2,
                            color: Colors.black,
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onColorSelected(null);
            Navigator.pop(context);
          },
          child: const Text('No Color'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
