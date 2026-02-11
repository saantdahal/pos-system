import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bhansaghar_staff/features/kitchen/orders/bloc/orders_bloc.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/bloc/orders_event.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/bloc/orders_state.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/widgets/kitchen_order_card.dart';

class KitchenOrdersPage extends StatefulWidget {
  const KitchenOrdersPage({super.key});

  @override
  State<KitchenOrdersPage> createState() => _KitchenOrdersPageState();
}

class _KitchenOrdersPageState extends State<KitchenOrdersPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('📱 KITCHEN_ORDERS_PAGE: Initializing...');
    context.read<KitchenOrdersBloc>().add(LoadKitchenOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: Text(
          'Live Kitchen Orders',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () =>
                context.read<KitchenOrdersBloc>().add(LoadKitchenOrders()),
          ),
        ],
      ),
      body: BlocConsumer<KitchenOrdersBloc, KitchenOrdersState>(
        listener: (context, state) {
          if (state.status == KitchenStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.errorMessage}')),
            );
          }
        },
        builder: (context, state) {
          debugPrint(
            '📱 KITCHEN_ORDERS_PAGE: Building with status: ${state.status}, orders: ${state.orders.length}',
          );
          if (state.status == KitchenStatus.loading && state.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All caught up!',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              // Responsive Grid
              int crossAxisCount = 1;
              if (constraints.maxWidth > 900) {
                crossAxisCount = 3;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 2;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.65, // Adjust based on card content
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  return KitchenOrderCard(order: state.orders[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
