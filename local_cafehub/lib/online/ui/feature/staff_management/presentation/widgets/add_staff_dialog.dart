import 'package:flutter/material.dart';

class AddStaffDialog extends StatefulWidget {
  final Function(String email, String role) onAdd;

  const AddStaffDialog({super.key, required this.onAdd});

  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  late TextEditingController _emailController;
  String _selectedRole = 'kitchen';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter email')));
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter valid email')));
      return;
    }

    setState(() => _isLoading = true);
    widget.onAdd(email, _selectedRole);

    // Close dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Staff Member'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'staff@example.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Role',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedRole,
                isExpanded: true,
                underline: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                onChanged: _isLoading
                    ? null
                    : (String? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedRole = newValue);
                        }
                      },
                items: const [
                  DropdownMenuItem(
                    value: 'kitchen',
                    child: Row(
                      children: [
                        Text('👨‍🍳'),
                        SizedBox(width: 8),
                        Text('Kitchen Staff'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'waiter',
                    child: Row(
                      children: [
                        Text('🧑‍💼'),
                        SizedBox(width: 8),
                        Text('Waiter'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleAdd,
          icon: _isLoading ? const SizedBox() : const Icon(Icons.add),
          label: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
