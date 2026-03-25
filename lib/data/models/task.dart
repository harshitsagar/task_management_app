import 'package:intl/intl.dart';

enum TaskStatus {
  todo('To-Do'),
  inProgress('In Progress'),
  done('Done');

  final String displayName;
  const TaskStatus(this.displayName);
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final String? blockedBy;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedBy,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'status': status.index,
    'blockedBy': blockedBy,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    dueDate: DateTime.parse(json['dueDate']),
    status: TaskStatus.values[json['status']],
    blockedBy: json['blockedBy'],
  );

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    String? blockedBy,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedBy: blockedBy ?? this.blockedBy,
    );
  }

  bool get isBlocked {
    return blockedBy != null;
  }

  String get formattedDueDate {
    return DateFormat('MMM dd, yyyy').format(dueDate);
  }
}