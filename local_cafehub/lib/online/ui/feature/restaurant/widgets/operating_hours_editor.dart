import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/operating_hours.dart';
import 'package:intl/intl.dart';

import 'compact_time_button.dart';
import 'special_closure_dialog.dart';

class OperatingHoursEditor extends StatefulWidget {
  final OperatingHours? initialHours;
  final ValueChanged<OperatingHours> onChanged;

  const OperatingHoursEditor({
    super.key,
    this.initialHours,
    required this.onChanged,
  });

  @override
  State<OperatingHoursEditor> createState() => _OperatingHoursEditorState();
}

class _OperatingHoursEditorState extends State<OperatingHoursEditor> {
  late Map<String, DaySchedule?> _regularHours;
  late List<SpecialClosure> _specialClosures;

  final List<String> _daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  @override
  void initState() {
    super.initState();
    _initializeHours();
  }

  void _initializeHours() {
    if (widget.initialHours != null) {
      _regularHours = Map.from(widget.initialHours!.regularHours ?? {});
      _specialClosures = List.from(widget.initialHours!.specialClosures ?? []);
    } else {
      _regularHours = {
        for (var day in _daysOfWeek) day: DaySchedule.open('09:00', '22:00'),
      };
      _specialClosures = [];
    }
  }

  void _notifyChanges() {
    widget.onChanged(
      OperatingHours(
        regularHours: _regularHours,
        specialClosures: _specialClosures,
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    String day,
    bool isOpenTime,
  ) async {
    final schedule = _regularHours[day];
    if (schedule == null || schedule.isClosed) return;

    final currentTime = isOpenTime ? schedule.openTime : schedule.closeTime;
    final initialTime = TimeOfDay.fromDateTime(
      currentTime != null
          ? DateFormat('HH:mm').parse(currentTime)
          : DateTime.now(),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isOpenTime) {
          _regularHours[day] = DaySchedule(
            isClosed: false,
            openTime: timeString,
            closeTime: schedule.closeTime,
          );
        } else {
          _regularHours[day] = DaySchedule(
            isClosed: false,
            openTime: schedule.openTime,
            closeTime: timeString,
          );
        }
      });
      _notifyChanges();
    }
  }

  void _toggleDayClosed(String day, bool isOpen) {
    setState(() {
      if (!isOpen) {
        _regularHours[day] = DaySchedule.closed();
      } else {
        _regularHours[day] = DaySchedule.open('09:00', '22:00');
      }
    });
    _notifyChanges();
  }

  void _addSpecialClosure() async {
    final result = await showDialog<SpecialClosure>(
      context: context,
      builder: (context) => const SpecialClosureDialog(),
    );

    if (result != null) {
      setState(() {
        _specialClosures.add(result);
      });
      _notifyChanges();
    }
  }

  void _removeSpecialClosure(int index) {
    setState(() {
      _specialClosures.removeAt(index);
    });
    _notifyChanges();
  }

  String _formatDayName(String day) {
    return day[0].toUpperCase() + day.substring(1);
  }

  String _formatTime12Hour(String time24) {
    try {
      final time = DateFormat('HH:mm').parse(time24);
      return DateFormat('h:mm a').format(time);
    } catch (e) {
      return time24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Regular Hours Section Header
        Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                color: theme.colorScheme.primary,
                size: 24.r,
              ),
              SizedBox(width: 12.w),
              Text(
                'Weekly Operating Hours',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ...List.generate(_daysOfWeek.length, (index) {
          final day = _daysOfWeek[index];
          final schedule = _regularHours[day];
          final isClosed = schedule?.isClosed ?? true;
          final isOpen = !isClosed;

          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              color: isOpen
                  ? theme.colorScheme.surfaceContainerLow
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isOpen
                    ? theme.colorScheme.primary.withValues(alpha: 0.3)
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Day header with toggle
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.r),
                      topRight: Radius.circular(15.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          isOpen ? Icons.store : Icons.store_outlined,
                          color: isOpen
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          size: 20.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDayName(day),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isOpen
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (isClosed)
                              Text(
                                'Closed',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            if (isOpen)
                              Text(
                                '${_formatTime12Hour(schedule?.openTime ?? '09:00')} - ${_formatTime12Hour(schedule?.closeTime ?? '22:00')}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Toggle Switch
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isOpen ? 'Open' : 'Closed',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isOpen
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onErrorContainer,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Switch(
                              value: isOpen,
                              onChanged: (value) =>
                                  _toggleDayClosed(day, value),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Time selection (only shown when open)
                if (isOpen) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CompactTimeButton(
                          label: 'Opens',
                          time: _formatTime12Hour(
                            schedule?.openTime ?? '09:00',
                          ),
                          icon: Icons.wb_sunny_outlined,
                          onTap: () => _selectTime(context, day, true),
                          theme: theme,
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward,
                          color: theme.colorScheme.outline,
                          size: 16.r,
                        ),
                        SizedBox(width: 8.w),
                        CompactTimeButton(
                          label: 'Closes',
                          time: _formatTime12Hour(
                            schedule?.closeTime ?? '22:00',
                          ),
                          icon: Icons.nightlight_outlined,
                          onTap: () => _selectTime(context, day, false),
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),

        SizedBox(height: 32.h),

        // Special Closures Section Header
        Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.errorContainer,
                theme.colorScheme.tertiaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.event_busy,
                color: theme.colorScheme.error,
                size: 24.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Special Closures & Holidays',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
              Material(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8.r),
                child: InkWell(
                  onTap: _addSpecialClosure,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: theme.colorScheme.error,
                      size: 24.r,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        if (_specialClosures.isEmpty)
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: theme.colorScheme.primary,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Special Closures',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Tap + to add holidays or temporary closures',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(_specialClosures.length, (index) {
            final closure = _specialClosures[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(11.r),
                        topRight: Radius.circular(11.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.event_busy,
                            color: theme.colorScheme.error,
                            size: 20.r,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            closure.note,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        Material(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          child: InkWell(
                            onTap: () => _removeSpecialClosure(index),
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Icon(
                                Icons.delete_outline,
                                color: theme.colorScheme.error,
                                size: 20.r,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: theme.colorScheme.error,
                          size: 18.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${DateFormat('MMM dd, yyyy').format(DateTime.parse(closure.startDate))} - ${DateFormat('MMM dd, yyyy').format(DateTime.parse(closure.endDate))}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
