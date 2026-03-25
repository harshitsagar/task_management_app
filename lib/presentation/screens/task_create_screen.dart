import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../services/draft_service.dart';

class TaskCreateScreen extends StatefulWidget {
  final TaskRepository repository;
  final List<Task> existingTasks;
  final Task? taskToEdit;

  const TaskCreateScreen({
    super.key,
    required this.repository,
    required this.existingTasks,
    this.taskToEdit,
  });

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TaskStatus _status = TaskStatus.todo;
  String? _blockedBy;
  bool _isLoading = false;
  late DraftService _draftService;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _draftService = DraftService();
    _isEditing = widget.taskToEdit != null;

    if (_isEditing) {
      _loadTaskData();
    } else {
      _loadDraft();
    }
  }

  void _loadTaskData() {
    final task = widget.taskToEdit!;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _dueDate = task.dueDate;
    _status = task.status;
    _blockedBy = task.blockedBy;
  }

  Future<void> _loadDraft() async {
    final draft = await _draftService.getDraft();
    if (draft != null) {
      _titleController.text = draft['title'] ?? '';
      _descriptionController.text = draft['description'] ?? '';
      if (draft['dueDate'] != null) {
        _dueDate = draft['dueDate'] as DateTime;
      }
      if (draft['status'] != null) {
        _status = draft['status'] as TaskStatus;
      }
      _blockedBy = draft['blockedBy'];
      setState(() {});
    }
  }

  void _saveDraft() {
    if (!_isEditing) {
      _draftService.saveDraft({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'dueDate': _dueDate,
        'status': _status,
        'blockedBy': _blockedBy,
      });
    }
  }

  void _clearDraft() {
    if (!_isEditing) {
      _draftService.clearDraft();
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _dueDate = DateTime.now().add(const Duration(days: 1));
        _status = TaskStatus.todo;
        _blockedBy = null;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    try {
      if (_isEditing) {
        final updatedTask = widget.taskToEdit!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _dueDate,
          status: _status,
          blockedBy: _blockedBy,
        );
        await widget.repository.updateTask(updatedTask);
      } else {
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _dueDate,
          status: _status,
          blockedBy: _blockedBy,
        );
        await widget.repository.addTask(newTask);
        _clearDraft();
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving task: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Create New Task'),
        actions: [
          if (!_isEditing && _titleController.text.isNotEmpty)
            TextButton(
              onPressed: _clearDraft,
              child: const Text('Clear Draft'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            TextFormField(
              controller: _titleController,
              onChanged: (_) => _saveDraft(),
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _descriptionController,
              onChanged: (_) => _saveDraft(),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            SizedBox(height: 16.h),
            _buildDueDatePicker(),
            SizedBox(height: 16.h),
            _buildStatusDropdown(),
            SizedBox(height: 16.h),
            _buildBlockedByDropdown(),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                _isEditing ? 'Update Task' : 'Create Task',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueDatePicker() {
    return InkWell(
      onTap: _isLoading ? null : () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dueDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _dueDate = date;
            _saveDraft();
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            SizedBox(width: 12.w),
            Text(
              'Due Date: ${DateFormat('MMM dd, yyyy').format(_dueDate)}',
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<TaskStatus>(
      value: _status,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        prefixIcon: const Icon(Icons.flag),
      ),
      items: TaskStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status.displayName),
        );
      }).toList(),
      onChanged: _isLoading
          ? null
          : (value) {
        setState(() {
          _status = value!;
          _saveDraft();
        });
      },
    );
  }

  Widget _buildBlockedByDropdown() {
    final availableTasks = widget.existingTasks
        .where((task) => task.id != widget.taskToEdit?.id)
        .toList();

    return DropdownButtonFormField<String?>(
      value: _blockedBy,
      decoration: InputDecoration(
        labelText: 'Blocked By (Optional)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        prefixIcon: const Icon(Icons.block),
      ),
      hint: const Text('Select a task that blocks this'),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('None'),
        ),
        ...availableTasks.map((task) {
          return DropdownMenuItem(
            value: task.id,
            child: Text(task.title),
          );
        }),
      ],
      onChanged: _isLoading
          ? null
          : (value) {
        setState(() {
          _blockedBy = value;
          _saveDraft();
        });
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}