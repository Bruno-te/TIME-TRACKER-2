// lib/widgets/add_time_entry_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../theme.dart';

class AddTimeEntrySheet extends StatefulWidget {
  const AddTimeEntrySheet({super.key});

  @override
  State<AddTimeEntrySheet> createState() => _AddTimeEntrySheetState();
}

class _AddTimeEntrySheetState extends State<AddTimeEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _totalTimeController = TextEditingController();

  Project? _selectedProject;
  Task? _selectedTask;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    _totalTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProject == null) {
      _showError('Please select a project');
      return;
    }
    if (_selectedTask == null) {
      _showError('Please select a task');
      return;
    }

    setState(() => _isSaving = true);

    final hours = double.tryParse(_totalTimeController.text) ?? 0;
    final provider = context.read<AppProvider>();

    await provider.addTimeEntry(
      projectId: _selectedProject!.id,
      projectName: _selectedProject!.name,
      taskId: _selectedTask!.id,
      taskName: _selectedTask!.name,
      totalTime: hours,
      notes: _notesController.text.trim(),
      date: _selectedDate,
    );

    if (mounted) Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final projects = provider.projects;
    final tasks = _selectedProject != null
        ? provider.getTasksForProject(_selectedProject!.id)
        : provider.tasks;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_chart_rounded,
                        color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Time Entry',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: AppTheme.onSurfaceMuted,
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total Time
                      _buildLabel('Total Time (hours) *'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _totalTimeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: 'e.g. 2.5 for 2h 30m',
                          prefixIcon: Icon(Icons.timer_outlined, color: AppTheme.onSurfaceMuted),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final n = double.tryParse(v);
                          if (n == null || n <= 0) return 'Enter a valid time';
                          if (n > 24) return 'Cannot exceed 24 hours';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Project Dropdown
                      _buildLabel('Project *'),
                      const SizedBox(height: 6),
                      _buildProjectDropdown(projects),
                      const SizedBox(height: 16),

                      // Task Dropdown
                      _buildLabel('Task *'),
                      const SizedBox(height: 6),
                      _buildTaskDropdown(tasks),
                      const SizedBox(height: 16),

                      // Notes
                      _buildLabel('Notes'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'What did you work on?',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 40),
                            child: Icon(Icons.notes_rounded, color: AppTheme.onSurfaceMuted),
                          ),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date
                      _buildLabel('Date *'),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: AppTheme.onSurfaceMuted, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right,
                                  color: AppTheme.onSurfaceMuted, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 20),
                                    SizedBox(width: 8),
                                    Text('Save Entry'),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppTheme.onSurface,
      letterSpacing: 0.2,
    ),
  );

  Widget _buildProjectDropdown(List<Project> projects) {
    if (projects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.onSurfaceMuted, size: 18),
            const SizedBox(width: 8),
            Text(
              'No projects yet. Add one in the menu.',
              style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<Project>(
      value: _selectedProject,
      isExpanded: true,
      decoration: InputDecoration(
        prefixIcon: _selectedProject != null
            ? Padding(
                padding: const EdgeInsets.all(14),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.hexToColor(_selectedProject!.color),
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : const Icon(Icons.folder_outlined, color: AppTheme.onSurfaceMuted),
        hintText: 'Select a project',
      ),
      items: projects.map((p) => DropdownMenuItem(
        value: p,
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.hexToColor(p.color),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(p.name),
          ],
        ),
      )).toList(),
      onChanged: (p) => setState(() {
        _selectedProject = p;
        _selectedTask = null;
      }),
      validator: (v) => v == null ? 'Select a project' : null,
    );
  }

  Widget _buildTaskDropdown(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.onSurfaceMuted, size: 18),
            const SizedBox(width: 8),
            Text(
              'No tasks yet. Add one in the menu.',
              style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<Task>(
      value: _selectedTask,
      isExpanded: true,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.task_alt_outlined, color: AppTheme.onSurfaceMuted),
        hintText: 'Select a task',
      ),
      items: tasks.map((t) => DropdownMenuItem(
        value: t,
        child: Text(t.name),
      )).toList(),
      onChanged: (t) => setState(() => _selectedTask = t),
      validator: (v) => v == null ? 'Select a task' : null,
    );
  }
}
