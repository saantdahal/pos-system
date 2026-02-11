import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:bhansaghar_staff/features/kitchen/orders/bloc/orders_bloc.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/bloc/orders_event.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/models/kitchen_order_model.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/widgets/bargain_dialog.dart';

class KitchenOrderCard extends StatelessWidget {
  final KitchenOrder order;

  const KitchenOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, statusColor.withValues(alpha: 0.05)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Table & Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Table ${order.tableNumber}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    timeago.format(order.createdAt, locale: 'en_short'),
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Items List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.qty}x',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            if (item.notes.isNotEmpty)
                              Text(
                                '"${item.notes}"',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.red[400],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Bargain Button for Item (Only if not ready/served)
                      if (order.status == 'pending' ||
                          order.status == 'preparing')
                        IconButton(
                          icon: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 20,
                          ),
                          tooltip: 'Low Stock / Bargain',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  BargainDialog(order: order, item: item),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),

              if (order.customerNotes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow[200]!),
                  ),
                  child: Text(
                    '📝 Note: ${order.customerNotes}',
                    style: GoogleFonts.inter(
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              const Spacer(),
              const Divider(),
              const SizedBox(height: 8),

              // Actions
              if (order.status == 'pending')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.read<KitchenOrdersBloc>().add(
                      StartPrep(order.id),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'START PREPARING 🔥',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

              if (order.status == 'preparing')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.read<KitchenOrdersBloc>().add(
                      MarkReady(order.id),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'MARK READY ✅',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

              if (order.status == 'bargain')
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'NEGOTIATION ACTIVE ⏳',
                      style: GoogleFonts.inter(
                        color: Colors.purple[700],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'bargain':
        return Colors.purple;
      case 'served':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
