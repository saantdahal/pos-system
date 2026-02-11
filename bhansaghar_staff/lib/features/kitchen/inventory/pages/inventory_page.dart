import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansaghar_staff/features/kitchen/inventory/bloc/inventory_bloc.dart';
import 'package:bhansaghar_staff/features/kitchen/inventory/widgets/inventory_card.dart';

class KitchenInventoryPage extends StatefulWidget {
  const KitchenInventoryPage({super.key});

  @override
  State<KitchenInventoryPage> createState() => _KitchenInventoryPageState();
}

class _KitchenInventoryPageState extends State<KitchenInventoryPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    debugPrint('📱 INVENTORY_PAGE: Initializing...');
    context.read<InventoryBloc>().add(LoadInventory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          debugPrint(
            '📱 INVENTORY_PAGE: Building with state: isLoading=${state.isLoading}, error=${state.error != null}',
          );
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.categories.isEmpty) {
            return const Center(child: Text("No categories found"));
          }

          // Initialize controller only when we have categories
          if (_tabController == null ||
              _tabController!.length != state.categories.length) {
            _tabController?.dispose();
            _tabController = TabController(
              length: state.categories.length,
              vsync: this,
            );
          }

          return Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.orange,
                tabs: state.categories
                    .map((c) => Tab(text: c['name']))
                    .toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: state.categories.map((category) {
                    final categoryId = category['id'];
                    final categoryItems = state.items
                        .where((i) => i['category'] == categoryId)
                        .toList();

                    if (categoryItems.isEmpty) {
                      return const Center(
                        child: Text("No items in this category"),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: categoryItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = categoryItems[index];
                        return InventoryItemCard(item: item);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
