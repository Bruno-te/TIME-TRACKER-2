// lib/screens/storage_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StorageService _storage = StorageService();

  String _entriesJson = 'Loading...';
  String _projectsJson = 'Loading...';
  String _tasksJson = 'Loading...';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final entries = await _storage.getRawTimeEntries();
    final projects = await _storage.getRawProjects();
    final tasks = await _storage.getRawTasks();

    String _prettyJson(String? raw) {
      if (raw == null || raw.isEmpty) return '[]';
      try {
        final obj = jsonDecode(raw);
        return const JsonEncoder.withIndent('  ').convert(obj);
      } catch (_) {
        return raw;
      }
    }

    setState(() {
      _entriesJson = _prettyJson(entries);
      _projectsJson = _prettyJson(projects);
      _tasksJson = _prettyJson(tasks);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppTheme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Storage'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.onSurfaceMuted,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: 'Entries'),
            Tab(text: 'Projects'),
            Tab(text: 'Tasks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StorageView(
            label: 'time_entries',
            json: _entriesJson,
            onCopy: () => _copyToClipboard(_entriesJson),
            icon: Icons.access_time_rounded,
            color: AppTheme.primary,
          ),
          _StorageView(
            label: 'projects',
            json: _projectsJson,
            onCopy: () => _copyToClipboard(_projectsJson),
            icon: Icons.folder_rounded,
            color: AppTheme.accent,
          ),
          _StorageView(
            label: 'tasks',
            json: _tasksJson,
            onCopy: () => _copyToClipboard(_tasksJson),
            icon: Icons.task_alt_rounded,
            color: AppTheme.secondary,
          ),
        ],
      ),
    );
  }
}

class _StorageView extends StatelessWidget {
  final String label;
  final String json;
  final VoidCallback onCopy;
  final IconData icon;
  final Color color;

  const _StorageView({
    required this.label,
    required this.json,
    required this.onCopy,
    required this.icon,
    required this.color,
  });

  bool get isEmpty => json.trim() == '[]' || json.trim() == 'null';

  int get entryCount {
    try {
      final list = jsonDecode(json) as List;
      return list.length;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          color: AppTheme.surface,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SharedPreferences key:',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                  Text(
                    '"$label"',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isEmpty
                      ? AppTheme.onSurfaceMuted.withOpacity(0.1)
                      : color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isEmpty ? 'Empty' : '$entryCount items',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isEmpty ? AppTheme.onSurfaceMuted : color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, size: 18),
                color: AppTheme.onSurfaceMuted,
                tooltip: 'Copy JSON',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // JSON content
        Expanded(
          child: isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inbox_rounded,
                          size: 44,
                          color: AppTheme.onSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Empty list',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No data stored yet.\nJSON value: []',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.onSurfaceMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      json,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFFCDD6F4),
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
