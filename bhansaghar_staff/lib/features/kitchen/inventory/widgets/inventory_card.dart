import 'package:bhansaghar_staff/features/kitchen/inventory/bloc/inventory_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryItemCard extends StatelessWidget {
  final dynamic item;
  const InventoryItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final stock = item['stock_quantity'];
    final isUnlimited = stock == null;
    final stockVal = int.tryParse(stock?.toString() ?? '0') ?? 0;

    final itemId = int.tryParse(item['id']?.toString() ?? '0') ?? 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image Placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: item['image'] != null
                    ? DecorationImage(
                        image: NetworkImage(item['image']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item['image'] == null
                  ? const Icon(Icons.fastfood, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'NPR ${item['base_price']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    const Text('Unlimited'),
                    Switch(
                      value: isUnlimited,
                      onChanged: (val) {
                        context.read<InventoryBloc>().add(
                          UpdateStock(itemId, val ? null : 0),
                        );
                      },
                      activeThumbColor: Colors.green,
                    ),
                  ],
                ),
                if (!isUnlimited)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            if (stockVal > 0) {
                              context.read<InventoryBloc>().add(
                                UpdateStock(itemId, stockVal - 1),
                              );
                            }
                          },
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        Text(
                          '$stockVal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            context.read<InventoryBloc>().add(
                              UpdateStock(itemId, stockVal + 1),
                            );
                          },
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
