import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/bloc/orders_bloc.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/bloc/orders_event.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/models/kitchen_order_model.dart';

class BargainDialog extends StatefulWidget {
  final KitchenOrder order;
  final KitchenOrderItem item;

  const BargainDialog({super.key, required this.order, required this.item});

  @override
  State<BargainDialog> createState() => _BargainDialogState();
}

class _BargainDialogState extends State<BargainDialog> {
  final _qtyController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messageController.text = "We only have limited quantity left.";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Start Bargain',
        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item: ${widget.item.name}',
            style: GoogleFonts.inter(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Requested Qty: ${widget.item.qty}',
            style: GoogleFonts.inter(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Available Quantity',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Message to Customer',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_qtyController.text.isEmpty) return;

            final availableQty = int.tryParse(_qtyController.text) ?? 0;

            context.read<KitchenOrdersBloc>().add(
              CreateBargain(
                orderId: widget.order.id,
                itemId: widget.item.itemId,
                originalQty: widget.item.qty,
                availableQty: availableQty,
                message: _messageController.text,
              ),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Send Offer'),
        ),
      ],
    );
  }
}
