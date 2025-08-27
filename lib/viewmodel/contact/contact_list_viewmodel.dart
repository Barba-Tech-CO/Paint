import 'package:flutter/foundation.dart';

import '../../model/contacts/contact_model.dart';
import '../../use_case/contacts/contact_operations_use_case.dart';
import '../../utils/command/command.dart';
import '../../utils/result/result.dart';

enum ContactListState { initial, loading, loaded, error }

class ContactListViewModel extends ChangeNotifier {
  final ContactOperationsUseCase _contactUseCase;

  ContactListViewModel(this._contactUseCase);

  // State
  ContactListState _state = ContactListState.initial;
  ContactListState get state => _state;

  // Data
  List<ContactModel> _contacts = [];
  List<ContactModel> get contacts => _contacts;

  // Pagination
  int _currentPage = 0;
  int get currentPage => _currentPage;
  int _totalContacts = 0;
  int get totalContacts => _totalContacts;
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
  bool get hasMoreContacts => _contacts.length < _totalContacts;
  bool get hasPendingContacts =>
      _contacts.any((c) => c.syncStatus == SyncStatus.pending);
  bool get hasErrorContacts =>
      _contacts.any((c) => c.syncStatus == SyncStatus.error);

  void _initializeCommands() {
    _loadContactsCommand = Command0(() async {
      _setState(ContactListState.loading);
      _clearError();
      _currentPage = 0;

      try {
        final result = await _contactUseCase.getContacts(
          limit: _pageSize,
          offset: _currentPage * _pageSize,
        );
        return result.when(
          ok: (response) {
            _contacts = response.contacts;
            _totalContacts = response.total ?? 0;
            _currentPage++;
            _setState(ContactListState.loaded);
            return Result.ok(null);
          },
          error: (error) {
            _setError(error.toString());
            _setState(ContactListState.error);
            return Result.error(error);
          },
        );
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
        final result = await _contactUseCase.getContacts(
          limit: _pageSize,
          offset: _currentPage * _pageSize,
        );
        return result.when(
          ok: (response) {
            _contacts.addAll(response.contacts);
            _totalContacts = response.total ?? 0;
            _currentPage++;
            notifyListeners();
            return Result.ok(null);
          },
          error: (error) {
            _setError(error.toString());
            return Result.error(error);
          },
        );
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
        final result = await _contactUseCase.searchContacts(query);
        return result.when(
          ok: (response) {
            _contacts = response.contacts;
            _totalContacts = response.total ?? 0;
            _currentPage = 1;
            _setState(ContactListState.loaded);
            return Result.ok(null);
          },
          error: (error) {
            _setError(error.toString());
            _setState(ContactListState.error);
            return Result.error(error);
          },
        );
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
        final result = await _contactUseCase.syncPendingContacts();
        return result.when(
          ok: (_) {
            // Refresh the contact list after sync
            _refreshAfterSync();
            return Result.ok(null);
          },
          error: (error) {
            _setError(error.toString());
            return Result.error(error);
          },
        );
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
    loadContacts();
  }

  void refresh() {
    loadContacts();
  }

  /// Adiciona um novo contato à lista
  void addContact(ContactModel contact) {
    _contacts.insert(0, contact);
    _totalContacts++;
    notifyListeners();
  }

  /// Atualiza um contato na lista
  void updateContact(ContactModel contact) {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _contacts[index] = contact;
      notifyListeners();
    }
  }

  /// Remove um contato da lista
  void removeContact(String contactId) {
    _contacts.removeWhere((c) => c.id == contactId);
    _totalContacts--;
    notifyListeners();
  }

  /// Limpa a lista de contatos
  void clearContacts() {
    _contacts.clear();
    _totalContacts = 0;
    _currentPage = 0;
    _clearError();
    notifyListeners();
  }

  /// Obtém contatos por status de sincronização
  List<ContactModel> getContactsBySyncStatus(SyncStatus status) {
    return _contacts.where((contact) => contact.syncStatus == status).toList();
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
