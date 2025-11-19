import 'package:flutter/foundation.dart';

import '../../domain/repository/contact_repository.dart';
import '../../model/contacts/contact_model.dart';
import '../../utils/command/command.dart';
import '../../utils/result/result.dart';

enum ContactListState { initial, loading, loaded, error }

class ContactListViewModel extends ChangeNotifier {
  final IContactRepository _contactRepository;

  ContactListViewModel(this._contactRepository) {
    // Listen to repository changes (source of truth)
    _contactRepository.addListener(_onRepositoryChanged);
    _initializeCommands();
  }

  @override
  void dispose() {
    _contactRepository.removeListener(_onRepositoryChanged);
    super.dispose();
  }

  void _onRepositoryChanged() {
    // Repository is the source of truth, update UI when it changes
    notifyListeners();
  }

  // State
  ContactListState _state = ContactListState.initial;
  ContactListState get state => _state;

  // Data - Repository is the source of truth
  List<ContactModel> get contacts => _contactRepository.contacts;
  int get contactsCount => _contactRepository.contactsCount;

  // Pagination
  int _currentPage = 0;
  int get currentPage => _currentPage;
  int get totalContacts => _contactRepository.contactsCount;
  static const int _pageSize = 20;

  // Search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Sync status
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  // Commands
  late final Command0<void> _loadContactsCommand;
  late final Command0<void> _loadMoreContactsCommand;
  late final Command1<void, String> _searchContactsCommand;
  late final Command0<void> _syncPendingContactsCommand;

  Command0<void> get loadContactsCommand => _loadContactsCommand;
  Command0<void> get loadMoreContactsCommand => _loadMoreContactsCommand;
  Command1<void, String> get searchContactsCommand => _searchContactsCommand;
  Command0<void> get syncPendingContactsCommand => _syncPendingContactsCommand;

  // Computed properties
  bool get isLoading =>
      _state == ContactListState.loading || _loadContactsCommand.running;
  bool get hasError =>
      _state == ContactListState.error || _errorMessage != null;
  bool get hasMoreContacts => contacts.length < totalContacts;
  bool get hasPendingContacts =>
      contacts.any((c) => c.syncStatus == SyncStatus.pending);
  bool get hasErrorContacts =>
      contacts.any((c) => c.syncStatus == SyncStatus.error);

  void _initializeCommands() {
    _loadContactsCommand = Command0(() async {
      _setState(ContactListState.loading);
      _clearError();
      _currentPage = 0;

      try {
        final result = await _contactRepository.getContacts(
          limit: _pageSize,
          offset: _currentPage * _pageSize,
        );

        if (result is Ok) {
          _currentPage++;
          _setState(ContactListState.loaded);
          return Result.ok(null);
        } else {
          _setError(result.asError.error.toString());
          _setState(ContactListState.error);
          return result;
        }
      } catch (e) {
        _setError(e.toString());
        _setState(ContactListState.error);
        return Result.error(Exception(e.toString()));
      }
    });

    _loadMoreContactsCommand = Command0(() async {
      if (!hasMoreContacts || _state == ContactListState.loading) {
        return Result.ok(null);
      }

      try {
        final result = await _contactRepository.getContacts(
          limit: _pageSize,
          offset: _currentPage * _pageSize,
        );

        if (result is Ok) {
          _currentPage++;
          notifyListeners();
          return Result.ok(null);
        } else {
          _setError(result.asError.error.toString());
          return result;
        }
      } catch (e) {
        _setError(e.toString());
        return Result.error(Exception(e.toString()));
      }
    });

    _searchContactsCommand = Command1((String query) async {
      _searchQuery = query;
      _setState(ContactListState.loading);
      _clearError();
      _currentPage = 0;

      try {
        final result = await _contactRepository.searchContacts(query);

        if (result is Ok) {
          _currentPage = 1;
          _setState(ContactListState.loaded);
          return Result.ok(null);
        } else {
          _setError(result.asError.error.toString());
          _setState(ContactListState.error);
          return result;
        }
      } catch (e) {
        _setError(e.toString());
        _setState(ContactListState.error);
        return Result.error(Exception(e.toString()));
      }
    });

    _syncPendingContactsCommand = Command0(() async {
      _setSyncing(true);
      _clearError();

      try {
        final result = await _contactRepository.syncPendingContacts();

        if (result is Ok) {
          // Refresh the contact list after sync
          _refreshAfterSync();
          return Result.ok(null);
        } else {
          _setError(result.asError.error.toString());
          return result;
        }
      } catch (e) {
        _setError(e.toString());
        return Result.error(Exception(e.toString()));
      } finally {
        _setSyncing(false);
      }
    });
  }

  void _setState(ContactListState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setSyncing(bool syncing) {
    _isSyncing = syncing;
    notifyListeners();
  }

  void _refreshAfterSync() {
    // Reload contacts to show updated sync status
    loadContacts();
  }

  // Public methods
  Future<void> loadContacts() async {
    _initializeCommands();
    await _loadContactsCommand.execute();
  }

  Future<void> loadMoreContacts() async {
    await _loadMoreContactsCommand.execute();
  }

  Future<void> searchContacts(String query) async {
    await _searchContactsCommand.execute(query);
  }

  Future<void> syncPendingContacts() async {
    await _syncPendingContactsCommand.execute();
  }

  void clearSearch() {
    _searchQuery = '';
    _currentPage = 0;
    _clearError();
    loadContacts();
  }

  void refresh() {
    loadContacts();
  }

  /// Obtém contatos por status de sincronização
  List<ContactModel> getContactsBySyncStatus(SyncStatus status) {
    return contacts.where((contact) => contact.syncStatus == status).toList();
  }

  /// Obtém contatos pendentes
  List<ContactModel> get pendingContacts =>
      getContactsBySyncStatus(SyncStatus.pending);

  /// Obtém contatos com erro
  List<ContactModel> get errorContacts =>
      getContactsBySyncStatus(SyncStatus.error);

  /// Obtém contatos sincronizados
  List<ContactModel> get syncedContacts =>
      getContactsBySyncStatus(SyncStatus.synced);
}
