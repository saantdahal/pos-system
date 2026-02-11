import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/presentation/bloc/menu_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/presentation/bloc/menu_event.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/presentation/bloc/menu_state.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/presentation/pages/menu_form_page.dart';
import '../widgets/menu_item_card.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      context.read<MenuBloc>().add(const MenuInitialized());
      _isInitialized = true;
    }
  }

  void _refreshMenu() {
    context.read<MenuBloc>().add(const MenuInitialized());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(
    BuildContext context,
    int itemId,
    String itemName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<MenuBloc>().add(MenuItemDeleted(itemId));
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Refresh menu when returning from form page
          _refreshMenu();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Menu Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          centerTitle: true,
        ),
        body: BlocListener<MenuBloc, MenuState>(
          listener: (context, state) {
            if (state is MenuItemCreatedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menu item created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is MenuItemUpdatedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menu item updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is MenuItemDeletedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menu item deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is MenuError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<MenuBloc, MenuState>(
            builder: (context, state) {
              if (state is MenuLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                );
              }

              if (state is MenuError) {
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 64,
                                color: Colors.grey.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1A1A1A),
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 220,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Check if error is about no restaurant
                              if (state.message.contains('Restaurant')) {
                                // Navigate to restaurant setup
                                Navigator.of(
                                  context,
                                ).pushNamed('/restaurant-setup');
                              } else {
                                // Retry loading menu
                                context.read<MenuBloc>().add(
                                  const MenuInitialized(),
                                );
                              }
                            },
                            icon: Icon(
                              state.message.contains('Restaurant')
                                  ? Icons.add
                                  : Icons.refresh,
                            ),
                            label: Text(
                              state.message.contains('Restaurant')
                                  ? 'Create Restaurant'
                                  : 'Retry',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Handle success states by extracting the MenuLoaded state
              MenuLoaded? loadedState;
              if (state is MenuLoaded) {
                loadedState = state;
              } else if (state is MenuItemCreatedSuccess ||
                  state is MenuItemUpdatedSuccess ||
                  state is MenuItemDeletedSuccess) {
                // For success states, try to get the previous MenuLoaded state
                final previousState = context.read<MenuBloc>().state;
                if (previousState is MenuLoaded) {
                  loadedState = previousState;
                }
              }

              if (loadedState != null) {
                final state = loadedState;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              context.read<MenuBloc>().add(MenuSearched(value));
                            },
                            decoration: InputDecoration(
                              hintText: 'Search for momo, drinks...',
                              hintStyle: TextStyle(
                                color: Colors.grey.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFFB8A0A0),
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Color(0xFFB8A0A0),
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        context.read<MenuBloc>().add(
                                          const MenuFilterCleared(),
                                        );
                                      },
                                    )
                                  : null,

                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Category Filter Buttons
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: state.selectedCategoryId == null
                                    ? null
                                    : () {
                                        context.read<MenuBloc>().add(
                                          const MenuFilterCleared(),
                                        );
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: state.selectedCategoryId == null
                                        ? const Color(0xFFFF6B35)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFFF6B35),
                                    ),
                                  ),
                                  child: Text(
                                    'All Items',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: state.selectedCategoryId == null
                                          ? Colors.white
                                          : const Color(0xFFFF6B35),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ...state.categories.map((category) {
                                final isSelected =
                                    state.selectedCategoryId == category.id;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      context.read<MenuBloc>().add(
                                        MenuCategoryFiltered(category.id),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFFF6B35)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFFF6B35)
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Menu Items List
                        if (state.filteredItems.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.restaurant_menu,
                                    size: 64,
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No menu items found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try adjusting your search or filters',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = state.filteredItems[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: MenuItemCard(
                                  item: item,
                                  onEdit: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MenuFormPage(
                                          menuItem: item,
                                          categories: state.categories,
                                        ),
                                      ),
                                    );
                                  },
                                  onDelete: () {
                                    _showDeleteConfirmation(
                                      context,
                                      item.id!,
                                      item.name,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              }

              return const Center(child: Text('Unknown state'));
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (context.read<MenuBloc>().state is MenuLoaded) {
              final state = context.read<MenuBloc>().state as MenuLoaded;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MenuFormPage(categories: state.categories),
                ),
              );
            }
          },
          backgroundColor: const Color(0xFFFF6B35),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
