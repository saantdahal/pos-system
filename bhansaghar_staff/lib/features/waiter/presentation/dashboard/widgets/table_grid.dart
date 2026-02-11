import 'package:flutter/material.dart' hide Table;
import 'package:bhansaghar_staff/features/waiter/domain/models/table_model.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/widgets/table_card.dart';

class TableGrid extends StatelessWidget {
  final List<WaiterTable> tables;
  final Function(WaiterTable table) onTableTap;

  const TableGrid({super.key, required this.tables, required this.onTableTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        return TableCard(
          table: tables[index],
          onTap: () => onTableTap(tables[index]),
        );
      },
    );
  }
}
