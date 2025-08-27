import 'package:flutter/material.dart';
import '../../model/models.dart';

enum ProjectsState { initial, loading, loaded, error }

class ProjectsViewModel extends ChangeNotifier {
  // State
  final ProjectsState _state = ProjectsState.initial;
  ProjectsState get state => _state;

  // Data
  List<ProjectCardModel> _projects = [];
  List<ProjectCardModel> get projects => _projects;

  set projects(List<ProjectCardModel> value) {
    _projects = value;
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  ProjectCardModel? _selectedProject;
  ProjectCardModel? get selectedProject => _selectedProject;

  set selectedProject(ProjectCardModel? value) {
    _selectedProject = value;
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  // Search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  set searchQuery(String value) {
    if (_searchQuery != value) {
      _searchQuery = value;
      // Use Future.microtask to defer the filtering and notification
      Future.microtask(() {
        // _filterProjectsByQuery(value);
        notifyListeners();
      });
    }
  }

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  set errorMessage(String? value) {
    _errorMessage = value;
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }
}
