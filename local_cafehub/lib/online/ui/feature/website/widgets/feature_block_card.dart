import 'package:flutter/material.dart';

typedef OnFeatureChanged =
    void Function(
      int featureIndex,
      String title,
      String description,
      String icon,
    );

class FeatureBlockCard extends StatefulWidget {
  final int featureIndex;
  final String? title;
  final String? description;
  final String? icon;
  final OnFeatureChanged onFeatureChanged;

  const FeatureBlockCard({
    super.key,
    required this.featureIndex,
    this.title,
    this.description,
    this.icon,
    required this.onFeatureChanged,
  });

  @override
  State<FeatureBlockCard> createState() => _FeatureBlockCardState();
}

class _FeatureBlockCardState extends State<FeatureBlockCard> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _iconController;

  final List<String> _commonIcons = [
    '🍽️',
    '⭐',
    '🚀',
    '💡',
    '🎯',
    '🏆',
    '❤️',
    '🔥',
    '✨',
    '🌟',
    '💪',
    '🎨',
    '📱',
    '🌍',
    '🎉',
    '🛡️',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.description ?? '',
    );
    _iconController = TextEditingController(text: widget.icon ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onFeatureChanged(
      widget.featureIndex,
      _titleController.text,
      _descriptionController.text,
      _iconController.text,
    );
  }

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Select Icon'),
        content: GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          children: _commonIcons
              .map(
                (icon) => GestureDetector(
                  onTap: () {
                    _iconController.text = icon;
                    _notifyChange();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _iconController.text == icon
                            ? Colors.blue
                            : Colors.grey[300]!,
                        width: _iconController.text == icon ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(icon, style: const TextStyle(fontSize: 32)),
                  ),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Feature ${widget.featureIndex + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Icon selector
            Row(
              children: [
                GestureDetector(
                  onTap: _showIconPicker,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _iconController.text.isEmpty
                            ? '❓'
                            : _iconController.text,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showIconPicker,
                    icon: const Icon(Icons.emoji_emotions),
                    label: const Text('Pick Icon'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Feature Title',
                hintText: 'e.g., Fast Service',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLength: 100,
              onChanged: (_) => _notifyChange(),
            ),
            const SizedBox(height: 16),
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Feature Description',
                hintText: 'Describe this feature...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              maxLength: 500,
              onChanged: (_) => _notifyChange(),
            ),
          ],
        ),
      ),
    );
  }
}
