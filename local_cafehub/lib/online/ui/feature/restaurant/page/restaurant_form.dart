import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_type.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/operating_hours.dart';
import 'package:bhansa_ghar/online/core/repositories/restaurant_repository.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/widgets/map.dart';
import '../bloc/restaurant_bloc.dart';
import '../widgets/operating_hours_editor.dart';

class RestaurantForm extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantForm({super.key, required this.restaurant});

  @override
  State<RestaurantForm> createState() => _RestaurantFormState();
}

class _RestaurantFormState extends State<RestaurantForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _descriptionController;

  double? _latitude;
  double? _longitude;
  bool _addressSelected = false;
  int? _selectedType;
  List<RestaurantType> _availableTypes = [];
  bool _loadingTypes = false;
  OperatingHours? _operatingHours;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.restaurant.name ?? '');
    _addressController = TextEditingController(
      text: widget.restaurant.address ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.restaurant.phone ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.restaurant.description ?? '',
    );

    // Initialize location data
    _latitude = widget.restaurant.latitude;
    _longitude = widget.restaurant.longitude;
    _addressSelected =
        widget.restaurant.latitude != null &&
        widget.restaurant.longitude != null;
    _selectedType = widget.restaurant.type?.id;

    // Initialize operating hours
    if (widget.restaurant.operatingHours != null) {
      _operatingHours = OperatingHours.fromJson(
        widget.restaurant.operatingHours!,
      );
    } else {
      _operatingHours = OperatingHours.empty();
    }

    // Load restaurant types
    _loadRestaurantTypes();
  }

  Future<void> _loadRestaurantTypes() async {
    setState(() => _loadingTypes = true);
    try {
      final types = await context
          .read<RestaurantRepository>()
          .getRestaurantTypes();
      setState(() {
        _availableTypes = types;
        _loadingTypes = false;
      });
    } catch (e) {
      setState(() => _loadingTypes = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load restaurant types: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onLocationSelected(double lat, double lng, String address) {
    setState(() {
      _latitude = lat;
      _longitude = lng;
      _addressController.text = address;
      _addressSelected = true;
    });
  }

  void _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPicker(
          onLocationSelected: _onLocationSelected,
          initialLat: _latitude,
          initialLng: _longitude,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      _onLocationSelected(
        result['latitude'],
        result['longitude'],
        result['address'],
      );
    }
  }

  void _saveRestaurant() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_addressSelected || _latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location on the map')),
        );
        return;
      }
      if (_selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant type is required')),
        );
        return;
      }

      final request = RestaurantUpdateRequest(
        name: _nameController.text.trim(),
        type: _selectedType!,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        operatingHours: _operatingHours?.toJson(),
      );

      context.read<RestaurantBloc>().add(
        UpdateRestaurantEvent(request: request),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUpdating =
        context.watch<RestaurantBloc>().state is RestaurantUpdating;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Name
          Text(
            'Restaurant Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Restaurant Name',
              hintText: 'Enter restaurant name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              prefixIcon: Icon(Icons.business, size: 20.r),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter restaurant name';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Address Field with Map Picker
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_addressSelected)
                TextFormField(
                  controller: _addressController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Address * (Selected)',
                    hintText: 'Pick location on map',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    prefixIcon: Icon(Icons.location_on, size: 20.r),
                  ),
                  maxLines: 3,
                ),
              if (_addressSelected) SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: _openMapPicker,
                  icon: Icon(Icons.map, size: 20.r),
                  label: Text(
                    _addressSelected
                        ? 'Change Location'
                        : 'Pick Location on Map',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Phone Number Field
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number *',
              hintText: 'Enter restaurant phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              prefixIcon: Icon(Icons.phone, size: 20.r),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              // Basic phone number validation
              final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
              if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Description Field
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Enter restaurant description (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              prefixIcon: Icon(Icons.description, size: 20.r),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 16.h),

          // Restaurant Type Dropdown
          DropdownButtonFormField<int>(
            initialValue: _selectedType,
            decoration: InputDecoration(
              labelText: 'Restaurant Type *',
              hintText: 'Select restaurant type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              prefixIcon: Icon(Icons.category, size: 20.r),
            ),
            items: _availableTypes.map((type) {
              return DropdownMenuItem<int>(
                value: type.id,
                child: Text(type.displayName ?? type.name ?? 'Unknown'),
              );
            }).toList(),
            onChanged: _loadingTypes
                ? null
                : (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
            validator: (value) {
              if (value == null) {
                return 'Please select a restaurant type';
              }
              return null;
            },
          ),
          SizedBox(height: 32.h),

          // Operating Hours Section
          Text(
            'Operating Hours',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          OperatingHoursEditor(
            initialHours: _operatingHours,
            onChanged: (hours) {
              setState(() {
                _operatingHours = hours;
              });
            },
          ),
          SizedBox(height: 32.h),

          // Restaurant Type (Read-only display)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.category,
                  color: theme.colorScheme.primary,
                  size: 20.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restaurant Type',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      Text(
                        widget.restaurant.type?.displayName ?? 'Unknown Type',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: isUpdating ? null : _saveRestaurant,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: isUpdating
                  ? SizedBox(
                      height: 20.r,
                      width: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.r,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
