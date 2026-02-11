import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/online/core/repositories/restaurant_repository.dart';
import 'package:bhansa_ghar/online/core/api/api_client.dart';
import 'package:bhansa_ghar/online/core/services/dio_service.dart';
import '../bloc/restaurant_bloc.dart';
import 'restaurant_form.dart';

class RestaurantDetailsPage extends StatelessWidget {
  const RestaurantDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RestaurantBloc(
        restaurantRepository: RestaurantRepository(
          apiClient: ApiClient(
            context.read<DioService>().dio,
            baseUrl: context.read<DioService>().baseUrl,
          ),
        ),
      )..add(LoadRestaurantEvent()),
      child: const RestaurantDetailsView(),
    );
  }
}

class RestaurantDetailsView extends StatefulWidget {
  const RestaurantDetailsView({super.key});

  @override
  State<RestaurantDetailsView> createState() => _RestaurantDetailsViewState();
}

class _RestaurantDetailsViewState extends State<RestaurantDetailsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Restaurant Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<RestaurantBloc, RestaurantState>(
        listener: (context, state) {
          if (state is RestaurantUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
          } else if (state is RestaurantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<RestaurantBloc, RestaurantState>(
          builder: (context, state) {
            if (state is RestaurantLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RestaurantError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.r,
                      color: theme.colorScheme.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<RestaurantBloc>().add(
                          LoadRestaurantEvent(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is RestaurantLoaded ||
                state is RestaurantUpdated ||
                state is RestaurantUpdating) {
              final restaurant = state is RestaurantLoaded
                  ? state.restaurant
                  : state is RestaurantUpdated
                  ? state.restaurant
                  : null;

              if (restaurant != null) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant Form
                      RestaurantForm(restaurant: restaurant),
                      SizedBox(height: 20.h),
                    ],
                  ),
                );
              }
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
