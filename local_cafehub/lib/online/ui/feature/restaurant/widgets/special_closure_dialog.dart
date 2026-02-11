import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/operating_hours.dart';
import 'package:intl/intl.dart';

/// Dialog for adding special closure periods (holidays, renovations, etc.)
///
/// This dialog allows users to:
/// - Enter a reason for the closure
/// - Select start and end dates
/// - Validates that dates are selected and end date is after start date
class SpecialClosureDialog extends StatefulWidget {
  const SpecialClosureDialog({super.key});

  @override
  State<SpecialClosureDialog> createState() => _SpecialClosureDialogState();
}

class _SpecialClosureDialogState extends State<SpecialClosureDialog> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both start and end dates'),
          ),
        );
        return;
      }

      if (_endDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End date must be after start date')),
        );
        return;
      }

      Navigator.of(context).pop(
        SpecialClosure(
          startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
          endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
          note: _noteController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Add Special Closure'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'e.g., Holiday, Renovation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reason';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(
                  _startDate != null
                      ? DateFormat('MMM dd, yyyy').format(_startDate!)
                      : 'Select date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(true),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(height: 12.h),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(
                  _endDate != null
                      ? DateFormat('MMM dd, yyyy').format(_endDate!)
                      : 'Select date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(false),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Add')),
      ],
    );
  }
}
