import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/task.dart';

class DraftService {
  static const String _draftKey = 'task_draft';

  Future<void> saveDraft(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> draftToSave = {};

    if (draft['title'] != null) draftToSave['title'] = draft['title'];
    if (draft['description'] != null) draftToSave['description'] = draft['description'];
    if (draft['dueDate'] != null) draftToSave['dueDate'] = draft['dueDate'].toIso8601String();
    if (draft['status'] != null) draftToSave['status'] = (draft['status'] as TaskStatus).index;
    if (draft['blockedBy'] != null) draftToSave['blockedBy'] = draft['blockedBy'];

    prefs.setString(_draftKey, json.encode(draftToSave));
  }

  Future<Map<String, dynamic>?> getDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final String? draftJson = prefs.getString(_draftKey);
    if (draftJson == null) return null;

    final Map<String, dynamic> decoded = json.decode(draftJson);
    final Map<String, dynamic> draft = {};

    if (decoded['title'] != null) draft['title'] = decoded['title'];
    if (decoded['description'] != null) draft['description'] = decoded['description'];
    if (decoded['dueDate'] != null) draft['dueDate'] = DateTime.parse(decoded['dueDate']);
    if (decoded['status'] != null) draft['status'] = TaskStatus.values[decoded['status']];
    if (decoded['blockedBy'] != null) draft['blockedBy'] = decoded['blockedBy'];

    return draft;
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }
}