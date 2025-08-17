import 'package:flutter/material.dart';

import '../../domain/entities/contact_entity.dart';
import '../../domain/repositories/contact_repository.dart';

class ContactDetailViewModel extends ChangeNotifier {
  final IContactRepository _contactRepository;

  ContactDetailViewModel(this._contactRepository);

  ContactModel? _contact;
  bool _isLoading = false;
  String? _errorMessage;

  ContactModel? get contact => _contact;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadContact(String contactId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _contactRepository.getContact(contactId);

      result.when(
        ok: (contact) {
          _contact = contact;
          notifyListeners();
        },
        error: (error) {
          _setError('Erro ao carregar contato: $error');
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateContact({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    if (_contact?.id == null) {
      _setError('ID do contato não encontrado');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _contactRepository.updateContact(
        _contact!.id!,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );

      result.when(
        ok: (updatedContact) {
          _contact = updatedContact;
          notifyListeners();
        },
        error: (error) {
          _setError('Erro ao atualizar contato: $error');
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteContact() async {
    if (_contact?.id == null) {
      _setError('ID do contato não encontrado');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _contactRepository.deleteContact(_contact!.id!);

      result.when(
        ok: (_) {
          _contact = null;
          notifyListeners();
        },
        error: (error) {
          _setError('Erro ao deletar contato: $error');
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
