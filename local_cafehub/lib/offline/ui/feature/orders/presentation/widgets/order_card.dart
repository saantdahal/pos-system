import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/offline/core/utils/snackbar.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/data/models/order_item.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/widgets/status_button.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isNew =
        order.id == '102'; // Hardcoded for design match, logic can be dynamic

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.getSubtitleColor(context).withValues(alpha: 0.2),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isNew)
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              )
            else if (order.status == 'Ready')
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              )
            else if (order.status == 'Preparing')
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              )
            else if (order.status == 'Needs Confirmation')
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              )
            else if (order.status == 'Cancelled')
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              )
            else
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.orderHash(order.id),
                          style: TextStyle(
                            color: AppColors.getTextColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.newBadge,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _getTimeAgo(order.createdAt),
                          style: TextStyle(
                            color: AppColors.getSubtitleColor(context),
                            fontSize: 12,
                          ),
                        ),
                        if (order.tableNumber != null) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: AppColors.getSubtitleColor(context),
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.table_restaurant,
                            size: 14,
                            color: AppColors.getSubtitleColor(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.tableNumber!,
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 2,
                              height: 16,
                              color: AppColors.getSubtitleColor(context),
                              margin: const EdgeInsets.only(right: 8),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.quantity}× ${item.name}',
                                    style: TextStyle(
                                      color: AppColors.getTextColor(context),
                                      fontSize: 14,
                                      decoration: item.proposedQuantity != null
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  if (item.proposedQuantity != null)
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.proposed(item.proposedQuantity!),
                                      style: const TextStyle(
                                        color: Colors.purple,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              'Rs. ${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppColors.getTextColor(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.total,
                          style: TextStyle(
                            color: AppColors.getTextColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rs. ${order.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.getTextColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (order.status == 'Needs Confirmation')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.purple),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.needsConfirmation,
                              style: const TextStyle(
                                color: Colors.purple,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (order.status == 'Cancelled')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.cancelled,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (order.notes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              right: 8.0,
                            ),
                            child: Text(
                              order
                                  .notes
                                  .last, // Show the last note (e.g., cancellation reason)
                              style: TextStyle(
                                color: AppColors.getSubtitleColor(context),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        if (order.status == 'Received' ||
                            order.status == 'Needs Confirmation')
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppColors.getCardBackground(
                                    context,
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!.cancelOrder,
                                    style: TextStyle(
                                      color: AppColors.getTextColor(context),
                                    ),
                                  ),
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.cancelOrderConfirm,
                                    style: TextStyle(
                                      color: AppColors.getSubtitleColor(
                                        context,
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        AppLocalizations.of(context)!.no,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.read<OrderBloc>().add(
                                          UpdateOrderStatus(
                                            order.id,
                                            'Cancelled',
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.yesCancel,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.cancel_outlined, size: 16),
                            label: Text(
                              AppLocalizations.of(context)!.cancelOrder,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        if (order.status == 'Received' ||
                            order.status == 'Needs Confirmation')
                          TextButton.icon(
                            onPressed: () =>
                                _showNegotiateDialog(context, order),
                            icon: const Icon(Icons.handshake, size: 16),
                            label: const Text('Negotiate'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        if (order.status != 'Cancelled')
                          StatusButton(
                            label: 'Received',
                            isActive: order.status == 'Received',
                            activeColor: Colors.blue,
                            onTap: _canChangeToStatus(order.status, 'Received')
                                ? () => context.read<OrderBloc>().add(
                                    UpdateOrderStatus(order.id, 'Received'),
                                  )
                                : null,
                          ),
                        // Status Buttons
                        if (order.status != 'Cancelled') ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              StatusButton(
                                label: 'Preparing',
                                isActive: order.status == 'Preparing',
                                activeColor: Colors.orange,
                                onTap:
                                    (order.status == 'Received' ||
                                        order.status == 'Preparing')
                                    ? () => context.read<OrderBloc>().add(
                                        UpdateOrderStatus(
                                          order.id,
                                          'Preparing',
                                        ),
                                      )
                                    : null,
                              ),
                              StatusButton(
                                label: 'Ready',
                                isActive: order.status == 'Ready',
                                activeColor: Colors.green,
                                onTap:
                                    (order.status == 'Preparing' ||
                                        order.status == 'Ready')
                                    ? () => context.read<OrderBloc>().add(
                                        UpdateOrderStatus(order.id, 'Ready'),
                                      )
                                    : null,
                              ),
                              StatusButton(
                                label: 'Completed',
                                isActive: order.status == 'Completed',
                                activeColor: Colors.grey,
                                onTap:
                                    (order.status == 'Ready' ||
                                        order.status == 'Completed')
                                    ? () => context.read<OrderBloc>().add(
                                        UpdateOrderStatus(
                                          order.id,
                                          'Completed',
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canChangeToStatus(String currentStatus, String newStatus) {
    // Define status hierarchy
    const statuses = ['Received', 'Preparing', 'Ready', 'Completed'];

    // If cancelled, cannot change status
    if (currentStatus == 'Cancelled') return false;

    final currentIndex = statuses.indexOf(currentStatus);
    final newIndex = statuses.indexOf(newStatus);

    // Can only move forward (or stay at completed)
    if (currentStatus == 'Completed') {
      return false; // Can't change from completed
    }

    return newIndex >= currentIndex;
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes == 1) return '1 min ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours == 1) return '1 hour ago';
    return '${diff.inHours} hours ago';
  }

  void _showNegotiateDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => NegotiateOrderDialog(order: order),
    );
  }
}

class NegotiateOrderDialog extends StatefulWidget {
  final Order order;

  const NegotiateOrderDialog({super.key, required this.order});

  @override
  State<NegotiateOrderDialog> createState() => _NegotiateOrderDialogState();
}

class _NegotiateOrderDialogState extends State<NegotiateOrderDialog> {
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (var item in widget.order.items)
        item.id: TextEditingController(text: item.quantity.toString()),
    };
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitProposal() async {
    final items = widget.order.items.map((item) {
      final proposedQty =
          int.tryParse(_controllers[item.id]!.text) ?? item.quantity;
      // Only send proposal if different from requested
      return {
        'id': item.id,
        'proposedQuantity': proposedQty != item.quantity ? proposedQty : null,
      };
    }).toList();

    // Call API
    // Note: In a real app, use a Repository/Bloc. Here using http for simplicity as per existing pattern
    try {
      // Assuming we have access to the server URL, or use a relative path if this was web.
      // For Flutter app, we need the actual IP.
      // Since we don't have the IP easily here without extra state,
      // we will dispatch an event to the Bloc which handles the API call.
      // However, the Bloc currently only handles status updates.
      // I will add a new event to OrderBloc for negotiation.

      context.read<OrderBloc>().add(NegotiateOrder(widget.order.id, items));
      Navigator.pop(context);
    } catch (e) {
      snackBar(message: 'Error: $e', messageType: MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.getDialogBackground(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Negotiate Order',
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Propose new quantities for items:',
              style: TextStyle(color: AppColors.getSubtitleColor(context)),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.name,
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          'Req: ${item.quantity}',
                          style: TextStyle(
                            color: AppColors.getSubtitleColor(context),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _controllers[item.id],
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Prop',
                              filled: true,
                              fillColor: AppColors.getTextField(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _submitProposal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Propose'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
