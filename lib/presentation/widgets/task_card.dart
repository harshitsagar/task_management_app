// lib/presentation/widgets/task_card.dart (FIXED)
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../screens/task_create_screen.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final bool isBlocked;
  final VoidCallback onUpdate;
  final List<Task> allTasks;

  const TaskCard({
    super.key,
    required this.task,
    required this.isBlocked,
    required this.onUpdate,
    required this.allTasks,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isUpdating = false;

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  Future<void> _updateStatus(TaskStatus newStatus) async {
    setState(() => _isUpdating = true);

    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final repository = TaskRepository(prefs);
    final updatedTask = widget.task.copyWith(status: newStatus);
    await repository.updateTask(updatedTask);

    if (mounted) {
      widget.onUpdate();
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isUpdating = true);

      await Future.delayed(const Duration(seconds: 2));

      final prefs = await SharedPreferences.getInstance();
      final repository = TaskRepository(prefs);
      await repository.deleteTask(widget.task.id);

      if (mounted) {
        widget.onUpdate();
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Opacity(
        opacity: widget.isBlocked ? 0.6 : 1.0,
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(widget.task.status)
                        .withOpacity(0.1),
                    child: Icon(
                      widget.task.status == TaskStatus.done
                          ? Icons.check
                          : widget.task.status == TaskStatus.inProgress
                          ? Icons.hourglass_empty
                          : Icons.circle_outlined,
                      color: _getStatusColor(widget.task.status),
                      size: 20.w,
                    ),
                  ),
                  title: Text(
                    widget.task.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      decoration: widget.task.status == TaskStatus.done
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.task.description.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            widget.task.description,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12.w,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            widget.task.formattedDueDate,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          if (widget.task.isBlocked) ...[
                            SizedBox(width: 12.w),
                            Icon(
                              Icons.block,
                              size: 12.w,
                              color: Colors.red.shade400,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Blocked',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final prefs = await SharedPreferences.getInstance();
                        final repository = TaskRepository(prefs);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskCreateScreen(
                              repository: repository,
                              existingTasks: widget.allTasks,
                              taskToEdit: widget.task,
                            ),
                          ),
                        );
                        if (result == true) {
                          widget.onUpdate();
                        }
                      } else if (value == 'delete') {
                        await _deleteTask();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.task.status != TaskStatus.done)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildStatusButton(
                          TaskStatus.todo,
                          'To-Do',
                          Colors.orange,
                        ),
                        SizedBox(width: 8.w),
                        _buildStatusButton(
                          TaskStatus.inProgress,
                          'In Progress',
                          Colors.blue,
                        ),
                        SizedBox(width: 8.w),
                        _buildStatusButton(
                          TaskStatus.done,
                          'Done',
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(TaskStatus status, String label, Color color) {
    final isSelected = widget.task.status == status;

    return Expanded(
      child: ElevatedButton(
        onPressed: _isUpdating || widget.isBlocked
            ? null
            : () => _updateStatus(status),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.grey.shade100,
          foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: _isUpdating && isSelected
            ? SizedBox(
          height: 16.h,
          width: 16.h,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
            : Text(
          label,
          style: TextStyle(fontSize: 12.sp),
        ),
      ),
    );
  }
}