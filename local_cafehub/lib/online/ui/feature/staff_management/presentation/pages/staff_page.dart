import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bhansa_ghar/online/ui/feature/staff_management/presentation/bloc/staff_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/staff_management/presentation/bloc/staff_event.dart';
import 'package:bhansa_ghar/online/ui/feature/staff_management/presentation/bloc/staff_state.dart';
import 'package:bhansa_ghar/online/ui/feature/staff_management/presentation/widgets/add_staff_dialog.dart';
import 'package:bhansa_ghar/online/ui/feature/staff_management/presentation/widgets/staff_card.dart';
import 'package:bhansa_ghar/online/ui/feature/staff_management/presentation/widgets/invitation_card.dart';
import 'package:bhansa_ghar/online/core/models/staff/staff_model.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedRoleFilter; // Add role filter state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<StaffBloc>().add(const FetchStaffList());
    context.read<StaffBloc>().add(const FetchStaffInvitations());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStaffDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: BlocListener<StaffBloc, StaffState>(
        listener: (context, state) {
          if (state is StaffError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is StaffInvitationCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Staff invitation created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh invitations list to show the new invitation
            context.read<StaffBloc>().add(const FetchStaffInvitations());
          } else if (state is StaffRemoved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Staff member removed successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is StaffInvitationDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invitation deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is StaffStatusToggled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Staff ${state.staffMember.statusText.toLowerCase()}',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: innerBoxIsScrolled ? 1 : 0,
              pinned: true,
              leading: BackButton(
                color: Colors.black,
                onPressed: () {
                  context.go('/online-home');
                },
              ),
              title: const Text(
                'Staff Management',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: BlocBuilder<StaffBloc, StaffState>(
                      builder: (context, state) {
                        int count = 0;
                        if (state is StaffLoaded) {
                          count = state.staffCount;
                        }
                        return Text(
                          'Staff ($count)',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.orange,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.orange,
                tabs: const [
                  Tab(text: 'Staff Members'),
                  Tab(text: 'Quick Access'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Staff Members
              _buildStaffListTab(),
              // Tab 2: Quick Access
              _buildQuickAccessTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaffListTab() {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (context, state) {
        if (state is StaffLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StaffLoaded) {
          if (state.staffMembers.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<StaffBloc>().add(const RefreshStaffList());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.staffMembers.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Staff (${state.staffCount}/10)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                final staff = state.staffMembers[index - 1];
                return StaffCard(
                  staff: staff,
                  onEdit: () => _showEditStaffDialog(staff),
                  onToggleStatus: () => _handleToggleStatus(staff),
                  onRemove: () => _handleRemoveStaff(staff),
                );
              },
            ),
          );
        }

        if (state is StaffError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<StaffBloc>().add(const FetchStaffList());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildQuickAccessTab() {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (context, state) {
        if (state is StaffLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StaffLoaded) {
          // Get all pending invites
          var allPendingInvites = state.invitations
              .where((i) => i.isPending)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Pending Staff Invitations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${allPendingInvites.length} pending invite${allPendingInvites.length > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 16),

                // Role Filter Buttons
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All Roles'),
                      selected: _selectedRoleFilter == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRoleFilter = selected
                              ? null
                              : _selectedRoleFilter;
                        });
                      },
                      selectedColor: Colors.teal[100],
                    ),
                    FilterChip(
                      label: const Text('👨‍🍳 Kitchen Staff'),
                      selected: _selectedRoleFilter == 'kitchen',
                      onSelected: (selected) {
                        setState(() {
                          _selectedRoleFilter = selected ? 'kitchen' : null;
                        });
                      },
                      selectedColor: Colors.red[100],
                    ),
                    FilterChip(
                      label: const Text('🧑‍💼 Waiter'),
                      selected: _selectedRoleFilter == 'waiter',
                      onSelected: (selected) {
                        setState(() {
                          _selectedRoleFilter = selected ? 'waiter' : null;
                        });
                      },
                      selectedColor: Colors.blue[100],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Kitchen Staff Section
                _buildRoleSection(
                  'Kitchen Staff',
                  '👨‍🍳',
                  Colors.red,
                  allPendingInvites.where((i) => i.role == 'kitchen').toList(),
                ),
                const SizedBox(height: 20),

                // Waiter Section
                _buildRoleSection(
                  'Waiter',
                  '🧑‍💼',
                  Colors.blue,
                  allPendingInvites.where((i) => i.role == 'waiter').toList(),
                ),
              ],
            ),
          );
        }

        if (state is StaffError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<StaffBloc>().add(
                      const FetchStaffInvitations(),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<StaffBloc>().add(const FetchStaffInvitations());
                },
                child: const Text('Load Invitations'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getRoleEmoji(String role) {
    switch (role.toLowerCase()) {
      case 'kitchen':
        return '👨‍🍳';
      case 'waiter':
        return '🧑‍💼';
      default:
        return '👤';
    }
  }

  Widget _buildRoleSection(
    String title,
    String emoji,
    MaterialColor roleColor,
    List<StaffInvitation> invites,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: roleColor.withValues(alpha: 0.2), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: roleColor[700],
                      ),
                    ),
                    Text(
                      '${invites.length} pending',
                      style: TextStyle(fontSize: 12, color: roleColor[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          if (invites.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: roleColor.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No pending $title invitations',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: invites.length,
                itemBuilder: (context, index) {
                  final invite = invites[index];
                  return InvitationCard(
                    invite: invite,
                    roleEmoji: _getRoleEmoji(invite.role),
                    roleColor: roleColor,
                    onCopy: () => _copyToClipboard(invite.qrCodeUrl ?? ''),
                    onShare: () => _shareQR(invite.qrCodeUrl ?? ''),
                    onDelete: () => _handleDeleteInvitation(invite),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            const Text(
              'No Staff Members',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Add staff members to manage your restaurant',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddStaffDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add First Staff Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStaffDialog() {
    showDialog(
      context: context,
      builder: (context) => AddStaffDialog(
        onAdd: (email, role) {
          context.read<StaffBloc>().add(
            CreateStaffInvitation(email: email, role: role),
          );
        },
      ),
    );
  }

  void _showEditStaffDialog(dynamic staff) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
    );
  }

  void _handleToggleStatus(dynamic staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(staff.isActive ? 'Deactivate Staff' : 'Activate Staff'),
        content: Text(
          'Are you sure you want to ${staff.isActive ? 'deactivate' : 'activate'} ${staff.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<StaffBloc>().add(
                ToggleStaffStatus(staffId: staff.id, isActive: !staff.isActive),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: staff.isActive ? Colors.red : Colors.green,
            ),
            child: Text(staff.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _handleRemoveStaff(dynamic staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Staff'),
        content: Text(
          'Are you sure you want to permanently remove ${staff.displayName} from the system?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<StaffBloc>().add(RemoveStaff(staffId: staff.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteInvitation(StaffInvitation invite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invitation'),
        content: Text(
          'Are you sure you want to delete the invitation for ${invite.email}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<StaffBloc>().add(
                DeleteStaffInvitation(inviteId: invite.id),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  void _shareQR(String qrUrl) {
    if (qrUrl.isNotEmpty) {
      SharePlus.instance.share(
        ShareParams(
          text:
              'Scan this QR code to access the restaurant staff login: $qrUrl',
          subject: 'Restaurant Staff QR Code',
        ),
      );
    }
  }
}
