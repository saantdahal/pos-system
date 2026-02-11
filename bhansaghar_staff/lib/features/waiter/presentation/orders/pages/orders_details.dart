import 'package:bhansaghar_staff/features/waiter/presentation/orders/bloc/order_details/order_details_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/orders/widgets/order_details/kitchen_notes_section.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/orders/widgets/order_details/items_served_progress.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/orders/widgets/order_details_action_buttons.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/orders/widgets/order_details/order_details_header.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/orders/widgets/order_details/order_item_card.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late OrderDetailsBloc _orderDetailsBloc;

  @override
  void initState() {
    super.initState();
    _orderDetailsBloc = context.read<OrderDetailsBloc>();
    _orderDetailsBloc.add(LoadOrderDetailsEvent(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: BlocListener<OrderDetailsBloc, OrderDetailsState>(
        listener: (context, state) {
          if (state is OrderDetailsUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF22C55E),
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is OrderDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red[400],
              ),
            );
          }
        },
        child: BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
          builder: (context, state) {
            if (state is OrderDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF22C55E)),
              );
            }

            if (state is OrderDetailsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[400],
                      size: 48.sp,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (state is OrderDetailsLoaded ||
                state is OrderDetailsUpdating ||
                state is OrderDetailsUpdated) {
              final order = (state is OrderDetailsLoaded)
                  ? state.order
                  : (state is OrderDetailsUpdating)
                  ? state.order
                  : (state as OrderDetailsUpdated).order;

              final isUpdating = state is OrderDetailsUpdating;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    OrderDetailsHeader(
                      tableName: order.tableName,
                      status: order.status,
                      onBackPressed: () => context.pop(),
                      onMenuPressed: () {
                        // Handle menu press
                      },
                    ),
                    ItemsServedProgress(
                      servedItems: order.servedItems,
                      totalItems: order.totalItems,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ORDER ITEMS',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    ...order.items.map(
                      (item) => OrderItemCard(
                        item: item,
                        onTap: () {
                          context.read<OrderDetailsBloc>().add(
                            MarkItemServedEvent(item.id),
                          );
                        },
                      ),
                    ),
                    KitchenNotesSection(notes: order.kitchenNotes),
                    SizedBox(height: 16.h),
                    OrderDetailsActionButtons(
                      isLoading: isUpdating,
                      onPickupAll: () {
                        context.read<OrderDetailsBloc>().add(
                          const PickupAllEvent(),
                        );
                      },
                      onMarkServed: () {
                        context.read<OrderDetailsBloc>().add(
                          const MarkAllServedEvent(),
                        );
                      },
                      onAddNote: () {
                        _showAddNoteDialog(context);
                      },
                      onCallKitchen: () {
                        context.read<OrderDetailsBloc>().add(
                          const CallKitchenEvent(),
                        );
                      },
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(
            'Add Kitchen Note',
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
          content: TextField(
            controller: noteController,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your note here...',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
              ),
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  context.read<OrderDetailsBloc>().add(
                    AddNoteEvent(noteController.text),
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(
                'Add Note',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
