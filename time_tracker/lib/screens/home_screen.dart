// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../widgets/add_time_entry_sheet.dart';
import '../widgets/time_entry_card.dart';
import '../widgets/empty_state.dart';
import '../models/time_entry.dart';
import '../theme.dart';
import 'projects_screen.dart';
import 'tasks_screen.dart';
import 'storage_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTimeEntrySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('Time Tracker'),
        actions: [
          Consumer<AppProvider>(
            builder: (_, provider, __) => IconButton(
              icon: Icon(
                provider.groupByProject
                    ? Icons.view_list_rounded
                    : Icons.account_tree_outlined,
                color: provider.groupByProject
                    ? AppTheme.primary
                    : AppTheme.onSurfaceMuted,
              ),
              tooltip: provider.groupByProject
                  ? 'Show all entries'
                  : 'Group by project',
              onPressed: provider.toggleGroupByProject,
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.onSurfaceMuted,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Projects', icon: Icon(Icons.folder_outlined, size: 20)),
            Tab(text: 'All Entries', icon: Icon(Icons.list_alt_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ProjectsTab(onAddEntry: _openAddEntry),
          _AllEntriesTab(onAddEntry: _openAddEntry),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEntry,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.access_time_filled_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time Tracker',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Manage your time',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Menu items
            _DrawerItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.folder_rounded,
              label: 'Projects',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProjectsScreen()));
              },
            ),
            _DrawerItem(
              icon: Icons.task_alt_rounded,
              label: 'Tasks',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TasksScreen()));
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(),
            ),
            _DrawerItem(
              icon: Icons.storage_rounded,
              label: 'Local Storage',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StorageScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppTheme.onSurface,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.onSurfaceMuted),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// ── Projects Tab ──────────────────────────────────────────────────────────────
class _ProjectsTab extends StatelessWidget {
  final VoidCallback onAddEntry;
  const _ProjectsTab({required this.onAddEntry});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.timeEntries.isEmpty) {
          return EmptyState(
            icon: Icons.folder_open_rounded,
            title: 'No time entries yet',
            subtitle: 'Start tracking your time by\nadding your first entry.',
            actionLabel: 'Add Entry',
            onAction: onAddEntry,
          );
        }

        final grouped = provider.getEntriesGroupedByProject();

        return ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 100),
          itemCount: grouped.length,
          itemBuilder: (_, i) {
            final projectName = grouped.keys.elementAt(i);
            final entries = grouped[projectName]!;
            final totalHours = provider.getTotalHoursForProject(projectName);

            return _ProjectGroup(
              projectName: projectName,
              entries: entries,
              totalHours: totalHours,
              onDelete: (id) => provider.deleteTimeEntry(id),
            );
          },
        );
      },
    );
  }
}

class _ProjectGroup extends StatefulWidget {
  final String projectName;
  final List<TimeEntry> entries;
  final double totalHours;
  final Function(String) onDelete;

  const _ProjectGroup({
    required this.projectName,
    required this.entries,
    required this.totalHours,
    required this.onDelete,
  });

  @override
  State<_ProjectGroup> createState() => _ProjectGroupState();
}

class _ProjectGroupState extends State<_ProjectGroup> {
  bool _expanded = true;

  String _formatHours(double h) {
    final hours = h.floor();
    final mins = ((h - hours) * 60).round();
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Header
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.projectName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatHours(widget.totalHours),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppTheme.onSurfaceMuted,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.entries.map(
            (e) => TimeEntryCard(
              entry: e,
              onDelete: () => widget.onDelete(e.id),
            ),
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── All Entries Tab ──────────────────────────────────────────────────────────
class _AllEntriesTab extends StatelessWidget {
  final VoidCallback onAddEntry;
  const _AllEntriesTab({required this.onAddEntry});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.timeEntries.isEmpty) {
          return EmptyState(
            icon: Icons.access_time_rounded,
            title: 'No time entries',
            subtitle: 'You haven\'t logged any time yet.\nTap the + button to get started.',
            actionLabel: 'Log Time',
            onAction: onAddEntry,
          );
        }

        if (provider.groupByProject) {
          return _GroupedList(provider: provider);
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: provider.timeEntries.length,
          itemBuilder: (_, i) {
            final entry = provider.timeEntries[i];
            return TimeEntryCard(
              entry: entry,
              onDelete: () => provider.deleteTimeEntry(entry.id),
            );
          },
        );
      },
    );
  }
}

class _GroupedList extends StatelessWidget {
  final AppProvider provider;
  const _GroupedList({required this.provider});

  @override
  Widget build(BuildContext context) {
    final grouped = provider.getEntriesGroupedByProject();
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 100),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final projectName = grouped.keys.elementAt(i);
        final entries = grouped[projectName]!;
        final totalHours = provider.getTotalHoursForProject(projectName);
        return _ProjectGroup(
          projectName: projectName,
          entries: entries,
          totalHours: totalHours,
          onDelete: (id) => provider.deleteTimeEntry(id),
        );
      },
    );
  }
}
