import 'package:flutter/material.dart';

class CategoryFormDialog extends StatefulWidget {
  final dynamic category;
  final Function(String name) onSubmit;

  const CategoryFormDialog({super.key, this.category, required this.onSubmit});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Category' : 'Add New Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Category Name',
              hintText: 'Enter category name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.category),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Category name is required';
              }
              return null;
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(_nameController.text);
              Navigator.pop(context);
            }
          },
          child: Text(isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
