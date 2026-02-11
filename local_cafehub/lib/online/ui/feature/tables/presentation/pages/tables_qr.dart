import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/tables/presentation/bloc/table_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/tables/presentation/bloc/table_event.dart';
import 'package:go_router/go_router.dart';
import '../widgets/tables_list.dart';
import '../widgets/create_table_dialog.dart';

class TablesQRPage extends StatefulWidget {
  const TablesQRPage({super.key});

  @override
  State<TablesQRPage> createState() => _TablesQRPageState();
}

class _TablesQRPageState extends State<TablesQRPage> {
  @override
  void initState() {
    super.initState();
    context.read<TableBloc>().add(const TablesInitialized());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => context.go('/online-home'),
        ),
        title: const Text(
          'Tables Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1A1A1A)),
            onPressed: () {
              context.read<TableBloc>().add(const TablesRefreshed());
            },
          ),
        ],
      ),
      body: const TablesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTableDialog,
        backgroundColor: const Color(0xFF1A1A1A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateTableDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateTableDialog(),
    );
  }
}
