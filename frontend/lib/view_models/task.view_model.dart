import 'package:flutter/material.dart';
import 'package:frontend/dtos/request/create_task.dto.dart';
import 'package:frontend/enums/priority.enum.dart';
import 'package:frontend/enums/status.enum.dart';
import 'package:frontend/models/tag.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/repositories/project.repository.dart';
import 'package:frontend/repositories/task.repository.dart';
import 'package:frontend/view_models/base/base.view_model.dart';
import 'package:frontend/view_models/state/project.state.dart';
import 'package:frontend/view_models/state/tag.state.dart';
import 'package:frontend/view_models/state/task.state.dart';
import 'package:frontend/view_models/state/user.state.dart';
import 'package:injectable/injectable.dart';

import '../models/task.dart';

@Injectable()
class TaskViewModel extends BaseViewModel {
  final bool _isEdit;
  final ProjectState _projectState;
  final TaskState _taskState;
  final TagState _tagState;
  final UserState _userState;
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;

  TaskViewModel(
    @factoryParam super.context,
    @factoryParam this._isEdit,
    this._taskRepository,
    this._projectRepository,
    this._projectState,
    this._userState,
    this._taskState,
    this._tagState,
  ) {
    _tagState.entities$.subscribe(defaultSubscriber);
    _userState.entities$.subscribe(defaultSubscriber);
    _taskState.current$.subscribe(_currentTaskSubscriber);

    if (_userState.getEntities().isEmpty) {
      _loadProjectUsers();
    }

    if (_tagState.getEntities().isEmpty) {
      _loadProjectTags();
    }

    if (_isEdit && _taskState.getCurrentOrNull() == null) {
      _loadCurrentTask();
    }

    if (_isEdit && _taskState.getCurrentOrNull() != null) {
      _currentTaskSubscriber(_taskState.getCurrent());
    }
  }

  User? _assignedTo;
  String _title = '';
  String _description = '';
  PriorityEnum _priority = PriorityEnum.normal;
  StatusEnum _status = StatusEnum.todo;
  num? _expectedHours;
  List<String> _tagsIds = [];
  List<String> _blockedByIds = [];

  String getTitle() => _title;
  String getDescription() => _description;
  num? getExpectedHoursOrNull() => _expectedHours;
  PriorityEnum getPriority() => _priority;
  StatusEnum getStatus() => _status;
  User? getAssignedToOrNull() => _assignedTo;
  List<User> getProjectUsers() => _userState.getEntities();
  List<Tag> getProjectTags() => _tagState.getEntities();

  List<Task> getProjectTasks() {
    return _taskState.getCurrentOrNull() == null
        ? _taskState.getEntities()
        : _taskState.getEntities().where((element) => element.id != _taskState.getCurrent().id).toList();
  }

  List<Task> getBlockedByTasks() {
    if (_taskState.getCurrentOrNull() == null) return [];
    return getProjectTasks().where((element) => _taskState.getCurrent().blockedBy.contains(element.id)).toList();
  }

  void _currentTaskSubscriber(Task? task) {
    if (task == null) return;

    _title = task.title;
    _description = task.description;
    _expectedHours = task.expectedHours;
    _status = task.status;
    _priority = task.priority;
    _assignedTo = task.assignedTo;
    _tagsIds = task.tags.map((e) => e.id).toList();
    _blockedByIds = task.blockedBy;

    notifyListeners();
  }

  Future<void> _loadProjectTags() async {
    try {
      _tagState.setEntities(await _projectRepository.getProjectTags(_projectState.getCurrentId()));
    } catch (e) {
      onException(e);
    }
  }

  Future<void> _loadCurrentTask() async {
    try {
      _taskState.setCurrent(await _taskRepository.getById(_taskState.getCurrentId()));
    } catch (e) {
      onException(e);
    }
  }

  Future<void> _loadProjectUsers() async {
    try {
      _userState.setEntities(await _projectRepository.getProjectUsers(_projectState.getCurrentId()));
    } catch (e) {
      onException(e);
    }
  }

  Task? getTaskOrNull() => _taskState.getCurrentOrNull();

  bool isTagAdded(String tagId) {
    return _tagsIds.any((element) => element == tagId);
  }

  bool isBlockedByAdded(String blockedById) {
    return _blockedByIds.any((element) => element == blockedById);
  }

  bool get isValidForCreate {
    return _title.isNotEmpty && _assignedTo != null;
  }

  bool get isInfoValid {
    return _title.isNotEmpty;
  }

  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setPriority(PriorityEnum? value) {
    if (value != null) {
      _priority = value;
      notifyListeners();
    }
  }

  void setStatus(StatusEnum? value) {
    if (value != null) {
      _status = value;
      notifyListeners();
    }
  }

  void setAssignedTo(User? value) {
    _assignedTo = value;
    notifyListeners();
  }

  void setExpectedHours(String value) {
    _expectedHours = num.tryParse(value);
    notifyListeners();
  }

  void Function(bool?) _changeIdHandler(List<String> list, String id) {
    return (bool? checked) {
      if (checked == true) {
        list.add(id);
      } else {
        list.remove(id);
      }

      notifyListeners();
    };
  }

  void Function(bool?) changeTagHandler(String tagId) {
    return _changeIdHandler(_tagsIds, tagId);
  }

  void Function(bool?) changeBlockedByHandler(String blockedById) {
    return _changeIdHandler(_blockedByIds, blockedById);
  }

  Future<void> _updateForDialogs(Future<Task> Function() taskGetter) async {
    try {
      _taskState.setCurrent(await taskGetter());
    } catch (e) {
      onException(e);
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> updateInfoHandler() {
    return _updateForDialogs(
      () async => _taskRepository.updateInfo(
        _taskState.getCurrentId(),
        _title,
        _description,
        _expectedHours,
      ),
    );
  }

  Future<void> Function() _update(Future<Task> Function() taskGetter) {
    return () async {
      try {
        _taskState.setCurrent(await taskGetter());
      } catch (e) {
        onException(e);
      }
    };
  }

  Future<void> Function() updatePriorityHandler(String id, PriorityEnum priority) {
    return _update(() async => _taskRepository.updatePriority(id, priority));
  }

  Future<void> Function() updateStatusHandler(String id, StatusEnum status) {
    return _update(() async => _taskRepository.updateStatus(id, status));
  }

  Future<void> Function() updateAssignedToHandler(String id, User user) {
    return _update(() async => _taskRepository.updateAssignedTo(id, user.id));
  }

  Future<void> updateTagsHandler() {
    return _updateForDialogs(
      () async => _taskRepository.updateTags(_taskState.getCurrentId(), _tagsIds),
    );
  }

  Future<void> updateBlockedByHandler() {
    return _updateForDialogs(
      () async => _taskRepository.updateBlockedBy(_taskState.getCurrentId(), _blockedByIds),
    );
  }

  Future<void> createHandler() async {
    try {
      final dto = CreateTaskDto(
        assignedTo: _assignedTo?.id ?? (throw Exception()),
        title: _title,
        description: _description,
        priority: _priority,
        status: _status,
        tags: _tagsIds,
        blockedBy: _blockedByIds,
        expectedHours: _expectedHours,
      );

      _taskState.addEntity(await _projectRepository.createProjectTask(_projectState.getCurrentId(), dto));
    } catch (e) {
      onException(e);
    } finally {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _tagState.entities$.unsubscribe(defaultSubscriber);
    _userState.entities$.unsubscribe(defaultSubscriber);
    _taskState.current$.unsubscribe(_currentTaskSubscriber);

    super.dispose();
  }
}
