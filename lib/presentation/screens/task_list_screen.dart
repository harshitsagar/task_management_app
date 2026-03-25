// lib/presentation/screens/task_list_screen.dart (COMPLETE FIXED VERSION)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../services/draft_service.dart';
import '../widgets/task_card.dart';
import 'task_create_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  String _searchQuery = '';
  TaskStatus? _selectedStatus;
  bool _isLoading = true;
  late TaskRepository _repository;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _repository = TaskRepository(prefs);
    final tasks = await _repository.getTasks();
    setState(() {
      _tasks = tasks;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    _filteredTasks = _tasks.where((task) {
      final matchesSearch = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == null ||
          task.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
    setState(() {});
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _applyFilters();
  }

  Future<void> _onTaskUpdated() async {
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'My Tasks',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                final isBlocked = task.isBlocked &&
                    !_isBlockerTaskCompleted(task.blockedBy!);
                return TaskCard(
                  task: task,
                  isBlocked: isBlocked,
                  onUpdate: _onTaskUpdated,
                  allTasks: _tasks,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskCreateScreen(
                repository: _repository,
                existingTasks: _tasks,
              ),
            ),
          );
          if (result == true) {
            await _loadTasks();
          }
        },
        icon: const Icon(Icons.add),
        label: Text('New Task', style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'All'),
                ...TaskStatus.values.map((status) =>
                    _buildFilterChip(status, status.displayName)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(TaskStatus? status, String label) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = selected ? status : null;
            _applyFilters();
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_outlined,
            size: 80.w,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the + button to create your first task',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Handle case where blocker task doesn't exist without returning null
  bool _isBlockerTaskCompleted(String blockerId) {
    // Find the blocker task, return null if not found
    Task? blockerTask;
    try {
      blockerTask = _tasks.firstWhere(
            (t) => t.id == blockerId,
        orElse: () => Task(
          id: '',
          title: '',
          description: '',
          dueDate: DateTime.now(),
          status: TaskStatus.done,
          blockedBy: null,
        ),
      );
    } catch (e) {
      // If any error occurs, return true
      return true;
    }

    // If blocker task has empty ID (meaning not found), treat as completed
    if (blockerTask.id.isEmpty) {
      return true;
    }

    return blockerTask.status == TaskStatus.done;
  }
}