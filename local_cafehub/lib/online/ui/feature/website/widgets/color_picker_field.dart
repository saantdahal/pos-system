import 'package:flutter/material.dart';

typedef OnColorChanged = void Function(String colorHex);

class ColorPickerField extends StatefulWidget {
  final String label;
  final String currentColorHex;
  final OnColorChanged onColorChanged;

  const ColorPickerField({
    super.key,
    required this.label,
    required this.currentColorHex,
    required this.onColorChanged,
  });

  @override
  State<ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {
  late Color _selectedColor;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _selectedColor = _hexToColor(widget.currentColorHex);
    _hexController = TextEditingController(text: widget.currentColorHex);
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hexString) {
    try {
      final hex = hexString.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _updateColor(Color color) {
    setState(() {
      _selectedColor = color;
      _hexController.text = _colorToHex(color);
    });
    widget.onColorChanged(_colorToHex(color));
  }

  void _onHexChanged(String value) {
    if (value.isEmpty) return;
    final cleanHex = value.replaceFirst('#', '');
    if (cleanHex.length == 6) {
      try {
        final color = Color(int.parse('FF$cleanHex', radix: 16));
        setState(() {
          _selectedColor = color;
        });
        widget.onColorChanged('#${cleanHex.toUpperCase()}');
      } catch (e) {
        // Invalid hex
      }
    }
  }

  void _showSimpleColorPicker() {
    final commonColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            children: commonColors
                .map(
                  (color) => GestureDetector(
                    onTap: () {
                      _updateColor(color);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: _selectedColor.value == color.value
                              ? Colors.black
                              : Colors.grey[300]!,
                          width: _selectedColor.value == color.value ? 3 : 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            // Color preview circle
            GestureDetector(
              onTap: _showSimpleColorPicker,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Hex input field
            Expanded(
              child: TextFormField(
                controller: _hexController,
                decoration: InputDecoration(
                  labelText: 'Hex Color',
                  hintText: '#FF6B6B',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.palette),
                ),
                onChanged: _onHexChanged,
                maxLength: 7,
              ),
            ),
            const SizedBox(width: 12),
            // Pick button
            ElevatedButton(
              onPressed: _showSimpleColorPicker,
              child: const Icon(Icons.colorize),
            ),
          ],
        ),
      ],
    );
  }
}
