import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_request.dart';
import 'package:bhansa_ghar/online/core/repositories/auth_repository.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_event.dart';
import 'package:bhansa_ghar/online/ui/feature/restaurant_setup/bloc/restaurant_setup.dart';
import 'package:bhansa_ghar/online/ui/feature/restaurant_setup/presentation/widgets/restaurant_type_button.dart';
import 'package:bhansa_ghar/online/ui/feature/restaurant_setup/presentation/widgets/time_picker_card.dart';

class RestaurantSetupPage extends StatelessWidget {
  final String? restaurantName;
  final String? restaurantAddress;
  final String? restaurantPhone;
  final double? restaurantLatitude;
  final double? restaurantLongitude;

  const RestaurantSetupPage({
    super.key,
    this.restaurantName,
    this.restaurantAddress,
    this.restaurantPhone,
    this.restaurantLatitude,
    this.restaurantLongitude,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              RestaurantSetupFormCubit(
                authRepository: context.read<AuthRepository>(),
              )..initializeWithWidgetData(
                restaurantName: restaurantName,
                restaurantPhone: restaurantPhone,
                restaurantAddress: restaurantAddress,
                restaurantLatitude: restaurantLatitude,
                restaurantLongitude: restaurantLongitude,
              ),
        ),
        BlocProvider(
          create: (context) =>
              RestaurantSetupBloc(restaurantRepository: context.read())
                ..add(LoadRestaurantTypesRequested()),
        ),
      ],
      child: const _RestaurantSetupView(),
    );
  }
}

class _RestaurantSetupView extends StatelessWidget {
  const _RestaurantSetupView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RestaurantSetupBloc, RestaurantSetupState>(
      listener: (context, state) => _handleSetupStateChange(context, state),
      child: BlocListener<RestaurantSetupFormCubit, RestaurantSetupFormState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            _showErrorSnackBar(context, state.errorMessage!);
            context.read<RestaurantSetupFormCubit>().clearError();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Online Restaurant Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: BlocBuilder<RestaurantSetupFormCubit, RestaurantSetupFormState>(
            builder: (context, formState) {
              return BlocBuilder<RestaurantSetupBloc, RestaurantSetupState>(
                builder: (context, setupState) {
                  final restaurantTypes = formState.restaurantTypes;
                  final selectedType = formState.selectedRestaurantTypeId;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Restaurant Type Section
                        const Text(
                          'Restaurant Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: restaurantTypes.map((type) {
                              final emoji = _getEmojiForType(
                                type.name ?? 'Unknown',
                              );
                              return Row(
                                children: [
                                  RestaurantTypeButton(
                                    label: type.displayName ?? 'Unknown',
                                    value: type.id.toString(),
                                    emoji: emoji,
                                    selectedType: selectedType,
                                    onTap: (value) {
                                      context
                                          .read<RestaurantSetupFormCubit>()
                                          .updateSelectedType(value);
                                    },
                                  ),
                                  if (type != restaurantTypes.last)
                                    const SizedBox(width: 12),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Additional Data Section
                        const Text(
                          'Additional Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          maxLines: 5,
                          controller: context
                              .read<RestaurantSetupFormCubit>()
                              .descriptionController,
                          onChanged: (value) {
                            context
                                .read<RestaurantSetupFormCubit>()
                                .updateDescription(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Description about the restaurant...',
                            hintStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Table Capacity Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Table Capacity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFF7043,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${formState.tableCapacity.toInt()} Tables',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF7043),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: const Color(0xFFFF7043),
                                inactiveTrackColor: const Color(0xFFE0E0E0),
                                thumbColor: const Color(0xFFFF7043),
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 12,
                                ),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: formState.tableCapacity,
                                min: 5,
                                max: 100,
                                label: '${formState.tableCapacity.toInt()}',
                                onChanged: (value) {
                                  context
                                      .read<RestaurantSetupFormCubit>()
                                      .updateTableCapacity(value);
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  '5 tables',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFB8B8B8),
                                  ),
                                ),
                                Text(
                                  '100 tables',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFB8B8B8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Operating Hours Section
                        const Text(
                          'Operating Hours',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            TimePickerCard(
                              title: 'OPENS AT',
                              time: formState.openingTime,
                              icon: Icons.wb_sunny,
                              onTap: () => _selectOpeningTime(context),
                            ),
                            const SizedBox(width: 12),
                            TimePickerCard(
                              title: 'CLOSES AT',
                              time: formState.closingTime,
                              icon: Icons.nights_stay,
                              onTap: () => _selectClosingTime(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Create Restaurant Button with BLoC State
                        BlocBuilder<RestaurantSetupBloc, RestaurantSetupState>(
                          builder: (context, state) {
                            final isLoading = state is RestaurantSetupLoading;
                            return SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _handleCreateRestaurant(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF7043),
                                  disabledBackgroundColor: const Color(
                                    0xFFFF7043,
                                  ).withValues(alpha: 0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 2,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Create Restaurant',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

Future<void> _selectOpeningTime(BuildContext context) async {
  final cubit = context.read<RestaurantSetupFormCubit>();
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: cubit.state.openingTime,
  );
  if (picked != null && picked != cubit.state.openingTime) {
    cubit.updateOpeningTime(picked);
  }
}

Future<void> _selectClosingTime(BuildContext context) async {
  final cubit = context.read<RestaurantSetupFormCubit>();
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: cubit.state.closingTime,
  );
  if (picked != null && picked != cubit.state.closingTime) {
    cubit.updateClosingTime(picked);
  }
}

String _getEmojiForType(String typeName) {
  switch (typeName) {
    case 'cafe':
      return '☕';
    case 'restaurant':
      return '🍽️';
    case 'hotel':
      return '🏨';
    case 'bar':
      return '🍺';
    case 'fastfood':
      return '🍔';
    default:
      return '🏪';
  }
}

void _handleCreateRestaurant(BuildContext context) {
  final formState = context.read<RestaurantSetupFormCubit>().state;
  final restaurantName = formState.restaurantNameFromProfile;
  final restaurantPhone = formState.restaurantPhoneFromProfile;
  final restaurantAddress = formState.restaurantAddressFromProfile;
  var restaurantLatitude = formState.restaurantLatitudeFromProfile;
  var restaurantLongitude = formState.restaurantLongitudeFromProfile;
  final email = formState.email;

  if (email == null || email.isEmpty) {
    _showErrorSnackBar(context, 'User email not found. Please login again.');
    return;
  }

  if (restaurantName == null || restaurantName.isEmpty) {
    _showErrorSnackBar(
      context,
      'Restaurant name is missing. Please complete profile first.',
    );
    return;
  }

  if (restaurantPhone == null || restaurantPhone.isEmpty) {
    _showErrorSnackBar(
      context,
      'Restaurant phone is missing. Please complete profile first.',
    );
    return;
  }

  if (restaurantAddress == null || restaurantAddress.isEmpty) {
    _showErrorSnackBar(
      context,
      'Restaurant address is missing. Please complete profile first.',
    );
    return;
  }

  if (restaurantLatitude == null || restaurantLongitude == null) {
    // Use default coordinates if not available (for development purposes)
    restaurantLatitude = 0.0;
    restaurantLongitude = 0.0;
  }

  // Create restaurant request with data from profile + setup data
  final request = RestaurantRequest(
    email: email,
    name: restaurantName,
    type: formState.selectedRestaurantTypeId,
    phone: restaurantPhone,
    address: restaurantAddress,
    latitude: restaurantLatitude,
    longitude: restaurantLongitude,
    description: formState.description,
    tablesCapacity: formState.tableCapacity.toInt(),
    operatingHours: _buildOperatingHours(
      formState.openingTime,
      formState.closingTime,
    ),
  );

  // Emit create restaurant event to BLoC
  context.read<RestaurantSetupBloc>().add(CreateRestaurantRequested(request));
}

Map<String, Map<String, String>> _buildOperatingHours(
  TimeOfDay openingTime,
  TimeOfDay closingTime,
) {
  final hours = <String, Map<String, String>>{};
  final days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  for (var day in days) {
    hours[day] = {
      'open': _formatTime12Hour(openingTime),
      'close': _formatTime12Hour(closingTime),
    };
  }

  return hours;
}

String _formatTime12Hour(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
}

void _handleSetupStateChange(BuildContext context, RestaurantSetupState state) {
  if (state is RestaurantSetupSuccess) {
    _showSuccessSnackBar(context, 'Restaurant created successfully!');
    // Notify auth bloc that restaurant setup is completed
    context.read<OnlineAuthBloc>().add(
      RestaurantSetupCompleted(state.response),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        context.go('/dashboard');
      }
    });
  } else if (state is RestaurantSetupFailure) {
    _showErrorSnackBar(context, state.message);
  } else if (state is RestaurantTypesLoaded) {
    context.read<RestaurantSetupFormCubit>().updateRestaurantTypes(state.types);
  } else if (state is RestaurantTypesError) {
    _showErrorSnackBar(
      context,
      'Failed to load restaurant types: ${state.message}',
    );
  }
}

void _showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
}

void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ),
  );
}
