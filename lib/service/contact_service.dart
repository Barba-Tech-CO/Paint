import 'package:dio/dio.dart';

import '../config/app_urls.dart';
import '../model/contacts/contact_list_response.dart';
import '../model/contacts/contact_model.dart';
import '../utils/logger/app_logger.dart';
import '../utils/result/result.dart';
import 'http_service.dart';
import 'location_service.dart';

class ContactService {
  final HttpService _httpService;
  final LocationService _locationService;
  final AppLogger _logger;
  static const String _baseUrl = AppUrls.contactsBaseUrl;

  ContactService(
    this._httpService,
    this._locationService,
    this._logger,
  );

  /// Dispara sincronização completa de contatos no backend (GHL -> DB API)
  Future<Result<Map<String, dynamic>>> syncContacts({int limit = 100}) async {
    try {
      final locationId = _locationService.currentLocationId;
      if (locationId == null || locationId.isEmpty) {
        return Result.error(
          Exception('Location ID not available. User not authenticated.'),
        );
      }

      _logger.info(
        'ContactService: Triggering /contacts/sync (limit=$limit, location=$locationId)',
      );
      final response = await _httpService.post(
        '$_baseUrl/sync',
        data: {'limit': limit},
        options: Options(
          headers: {
            'X-GHL-Location-ID': locationId,
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final stats = data['stats'];
        if (stats is Map) {
          _logger.info(
            'ContactService: Sync completed — total=${stats['total']}, created=${stats['created']}, updated=${stats['updated']}, pages=${stats['pages']}',
          );
        } else {
          _logger.info('ContactService: Sync completed — no stats payload');
        }
        return Result.ok(data);
      }
      return Result.error(
        Exception('Failed to sync contacts: ${response.statusCode}'),
      );
    } on DioException catch (e) {
      _logger.error('ContactService: Error syncing contacts', e);
      return _handleDioException(e, 'syncing contacts');
    } catch (e) {
      _logger.error('ContactService: Error syncing contacts', e);
      return Result.error(
        Exception('Error syncing contacts'),
      );
    }
  }

  /// Lista contatos com paginação (via POST /contacts sem body => lista DB+GHL)
  Future<Result<ContactListResponse>> getContacts({
    int? limit,
    int? offset,
  }) async {
    try {
      final locationId = _locationService.currentLocationId;
      if (locationId == null || locationId.isEmpty) {
        return Result.error(
          Exception('Location ID not available. User not authenticated.'),
        );
      }

      final effLimit = limit ?? 100;
      final page = (offset != null && effLimit > 0)
          ? ((offset / effLimit).floor() + 1)
          : 1;

      // POST sem body cai na listagem (ver controller store -> listContacts)
      final response = await _httpService.get(
        _baseUrl,
        queryParameters: {
          'limit': effLimit,
          'page': page,
        },
        options: Options(
          headers: {
            'X-GHL-Location-ID': locationId,
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        try {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            _logger.error(
              'ContactService: Unexpected response structure when listing contacts',
            );
            return Result.error(
              Exception('Unexpected response while listing contacts'),
            );
          }

          final contactListResponse = ContactListResponse.fromJson(data);
          return Result.ok(contactListResponse);
        } catch (e) {
          _logger.error('ContactService: Error parsing response: $e');
          _logger.error(
            'ContactService: Response data structure: ${response.data}',
          );
          return Result.error(
            Exception('Error parsing contact response: $e'),
          );
        }
      }

      final errorMessage = response.data is Map
          ? (response.data['message'] ?? 'Unknown error')
          : 'Unknown error';
      _logger.error('Error listing contacts', errorMessage);
      return Result.error(
        Exception('Error listing contacts'),
      );
    } on DioException catch (e) {
      _logger.error('Error listing contacts', e);
      return _handleDioException(e, 'listing contacts');
    } catch (e) {
      _logger.error('Error listing contacts', e);
      return Result.error(
        Exception('Error listing contacts'),
      );
    }
  }

  /// Busca contatos por nome, email ou telefone
  Future<Result<ContactListResponse>> searchContacts(String query) async {
    try {
      final locationId = _locationService.currentLocationId;
      if (locationId == null || locationId.isEmpty) {
        return Result.error(
          Exception('Location ID not available. User not authenticated.'),
        );
      }

      final response = await _httpService.post(
        '$_baseUrl/search',
        data: {
          'locationId': locationId,
          'query': query,
        },
        options: Options(
          headers: {
            'X-GHL-Location-ID': locationId,
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Handle successful response (200 OK)
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          _logger.error(
            'ContactService: Unexpected response structure on search',
          );
          return Result.error(
            Exception('Unexpected response while searching contacts'),
          );
        }
        final contactListResponse = ContactListResponse.fromJson(data);
        return Result.ok(contactListResponse);
      } else {
        final errorMessage = response.data['message'];
        _logger.error('Error searching contacts', errorMessage);
        return Result.error(
          Exception('Error searching contacts'),
        );
      }
    } on DioException catch (e) {
      _logger.error('Error searching contacts', e);
      return _handleDioException(e, 'searching contacts');
    } catch (e) {
      _logger.error('Error searching contacts', e);
      return Result.error(
        Exception('Error searching contacts'),
      );
    }
  }

  /// Busca avançada de contatos
  Future<Result<ContactListResponse>> advancedSearch({
    String? locationId,
    int? pageLimit,
    int? page,
    String? query,
    List<Map<String, dynamic>>? filters,
    List<Map<String, dynamic>>? sort,
  }) async {
    try {
      final currentLocationId =
          locationId ?? _locationService.currentLocationId;
      if (currentLocationId == null || currentLocationId.isEmpty) {
        return Result.error(
          Exception('Location ID not available. User not authenticated.'),
        );
      }

      final response = await _httpService.post(
        '$_baseUrl/search',
        data: {
          'locationId': currentLocationId,
          if (pageLimit != null) 'pageLimit': pageLimit,
          if (page != null) 'page': page,
          if (query != null) 'query': query,
          if (filters != null) 'filters': filters,
          if (sort != null) 'sort': sort,
        },
        options: Options(
          headers: {
            'X-GHL-Location-ID': currentLocationId,
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Handle successful response (200 OK)
      if (response.statusCode == 200) {
        final contactListResponse = ContactListResponse.fromJson(response.data);
        return Result.ok(contactListResponse);
      } else {
        final errorMessage = response.data['message'];
        _logger.error('Error in advanced search', errorMessage);
        return Result.error(
          Exception('Error in advanced search'),
        );
      }
    } on DioException catch (e) {
      _logger.error('Error in advanced search', e);
      return _handleDioException(e, 'advanced search');
    } catch (e) {
      _logger.error('Error in advanced search', e);
      return Result.error(
        Exception('Error in advanced search'),
      );
    }
  }

  /// Obtém um contato específico
  Future<Result<ContactModel>> getContact(String contactId) async {
    try {
      final locationId = _locationService.currentLocationId;
      if (locationId == null || locationId.isEmpty) {
        return Result.error(
          Exception('Location ID not available. User not authenticated.'),
        );
      }

      final response = await _httpService.get(
        '$_baseUrl/$contactId',
        queryParameters: {
          'location_id': locationId,
        },
        options: Options(
          headers: {
            'X-GHL-Location-ID': locationId,
            'Accept': 'application/json',
          },
        ),
      );

      // Handle successful response (200 OK)
      if (response.statusCode == 200) {
        if (response.data['success'] == true &&
            response.data['contactDetails'] != null) {
          final contact = ContactModel.fromJson(
            response.data['contactDetails'],
          );
          return Result.ok(contact);
        } else if (response.data['contactDetails'] != null) {
          final contact = ContactModel.fromJson(
            response.data['contactDetails'],
          );
          return Result.ok(contact);
        } else if (response.data['data'] != null) {
          final contact = ContactModel.fromJson(response.data['data']);
          return Result.ok(contact);
        } else {
          _logger.error('Contact data not found in response');
          return Result.error(
            Exception('Contact data not found'),
          );
        }
      } else {
        final errorMessage = response.data['message'];
        _logger.error('Contact not found', errorMessage);
        return Result.error(
          Exception('Contact not found'),
        );
      }
    } on DioException catch (e) {
      _logger.error('Error getting contact', e);
      return _handleDioException(e, 'getting contact');
    } catch (e) {
      _logger.error('Error getting contact', e);
      return Result.error(
        Exception('Error getting contact'),
      );
    }
  }

  /// Cria um novo contato
  Future<Result<ContactModel>> createContact({
    String? name,
    String? email,
    String? phone,
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    List<String>? additionalEmails,
    List<String>? additionalPhones,
    List<Map<String, dynamic>>? customFields,
    List<String>? tags,
  }) async {
    try {
      final locationId = _locationService.currentLocationId;
      if (locationId == null || locationId.isEmpty) {
        return Result.error(
          Exception('Location ID not available. User not authenticated.'),
        );
      }

      final requestData = <String, dynamic>{};

      // Add name fields as expected by API
      if (name != null && name.trim().isNotEmpty) {
        final nameParts = name.trim().split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1
            ? nameParts.skip(1).join(' ')
            : '';

        requestData['firstName'] = firstName;
        if (lastName.isNotEmpty) {
          requestData['lastName'] = lastName;
        }
      }

      // Add optional fields
      if (email != null && email.trim().isNotEmpty) {
        requestData['email'] = email.trim();
      }
      if (phone != null && phone.trim().isNotEmpty) {
        requestData['phone'] = phone.trim();
      }
      if (companyName != null && companyName.trim().isNotEmpty) {
        requestData['companyName'] = companyName.trim();
      }
      if (address != null) {
        requestData['address1'] = address;
      }
      if (city != null) requestData['city'] = city;
      if (state != null) requestData['state'] = state;
      if (postalCode != null) requestData['postalCode'] = postalCode;
      if (country != null &&
          country.trim().isNotEmpty &&
          country.toLowerCase() != 'any') {
        requestData['country'] = country.trim();
      }
      if (tags != null && tags.isNotEmpty) {
        requestData['tags'] = tags;
      }
      if (customFields != null && customFields.isNotEmpty) {
        _logger.info('Adding customFields: $customFields');
        requestData['customFields'] = customFields;
      }

      // Log the request data for debugging
      _logger.info('Creating contact with data: $requestData');
      _logger.info('Location ID: $locationId');

      // Use the correct endpoint for creating contacts (POST /api/contacts)
      final response = await _httpService.post(
        _baseUrl,
        data: requestData,
        queryParameters: {
          'location_id': locationId,
        },
        options: Options(
          headers: {
            'X-GHL-Location-ID': locationId,
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Handle successful response (201 Created)
      if (response.statusCode == 201) {
        if (response.data['success'] == true &&
            response.data['contactDetails'] != null) {
          final contact = ContactModel.fromJson(
            response.data['contactDetails'],
          );
          return Result.ok(contact);
        } else if (response.data['contactDetails'] != null) {
          final contact = ContactModel.fromJson(
            response.data['contactDetails'],
          );
          return Result.ok(contact);
        } else if (response.data['data'] != null) {
          final contact = ContactModel.fromJson(response.data['data']);
          return Result.ok(contact);
        } else {
          _logger.error('Contact data not found in response');
          return Result.error(
            Exception('Contact data not found'),
          );
        }
      } else {
        final errorMessage = response.data['message'];
        final errors = response.data['errors'];
        _logger.error('Error creating contact - Message: $errorMessage');
        if (errors != null) {
          _logger.error('Validation errors: $errors');
        }
        return Result.error(
          Exception('Validation failed. $errorMessage'),
        );
      }
    } on DioException catch (e) {
      _logger.error('Error creating contact', e);
      return _handleDioException(e, 'creating contact');
    } catch (e) {
      _logger.error('Error creating contact', e);
      return Result.error(
        Exception('Error creating contact'),
      );
    }
  }

  /// Atualiza um contato
  Future<Result<ContactModel>> updateContact(
    String contactId, {
    String? name,
    String? email,
    String? phone,
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    List<String>? additionalEmails,
    List<String>? additionalPhones,
    List<Map<String, dynamic>>? customFields,
    List<String>? tags,
  }) async {
    try {
      final locationId = _locationService.currentLocationId;
      if (locationId == null || locationId.isEmpty) {
        _logger.error('Location ID not available. User not authenticated.');
        return Result.error(
          Exception('Location ID not available. User not authenticated.'),
        );
      }

      final updateData = <String, dynamic>{};

      // Add name field as expected by API
      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }

      // Add other fields with detailed logging
      if (email != null && email.trim().isNotEmpty) {
        updateData['email'] = email.trim();
      }
      if (phone != null && phone.trim().isNotEmpty) {
        updateData['phone'] = phone.trim();
      }
      if (companyName != null && companyName.trim().isNotEmpty) {
        updateData['companyName'] = companyName.trim();
      }
      if (address != null && address.trim().isNotEmpty) {
        updateData['address1'] = address.trim();
      }
      if (city != null && city.trim().isNotEmpty) {
        updateData['city'] = city.trim();
      }
      if (state != null && state.trim().isNotEmpty) {
        updateData['state'] = state.trim();
      }
      if (postalCode != null && postalCode.trim().isNotEmpty) {
        updateData['postalCode'] = postalCode.trim();
      }
      if (country != null && country.trim().isNotEmpty) {
        updateData['country'] = country.trim();
      }
      if (additionalEmails != null) {
        updateData['additionalEmails'] = additionalEmails;
      }
      if (additionalPhones != null) {
        updateData['additionalPhones'] = additionalPhones;
      }
      if (tags != null) {
        updateData['tags'] = tags;
      }
      if (customFields != null) {
        updateData['customFields'] = customFields;
      }

      final response = await _httpService.put(
        '$_baseUrl/$contactId',
        data: updateData,
        options: Options(
          headers: {
            'X-GHL-Location-ID': locationId,
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Handle successful response (200 OK)
      if (response.statusCode == 200) {
        if (response.data['success'] == true &&
            response.data['contactDetails'] != null) {
          final contact = ContactModel.fromJson(
            response.data['contactDetails'],
          );
          return Result.ok(contact);
        } else if (response.data['contactDetails'] != null) {
          final contact = ContactModel.fromJson(
            response.data['contactDetails'],
          );
          return Result.ok(contact);
        } else if (response.data['data'] != null) {
          final contact = ContactModel.fromJson(response.data['data']);
          return Result.ok(contact);
        } else {
          _logger.error('Contact data not found in response');
          return Result.error(
            Exception('Contact data not found in response'),
          );
        }
      } else {
        final errorMessage = response.data['message'];
        _logger.error('Error updating contact', errorMessage);
        return Result.error(
          Exception('Error updating contact'),
        );
      }
    } on DioException catch (e) {
      _logger.error('Error updating contact', e);
      return _handleDioException(e, 'updating contact');
    } catch (e) {
      _logger.error('Error updating contact', e);
      return Result.error(
        Exception('Error updating contact'),
      );
    }
  }

  /// Remove um contato
  Future<Result<bool>> deleteContact(String contactId) async {
    try {
      final locationId = _locationService.currentLocationId;
      if (locationId == null || locationId.isEmpty) {
        _logger.error('Location ID not available. User not authenticated.');
        return Result.error(
          Exception('Location ID not available. User not authenticated.'),
        );
      }

      final response = await _httpService.delete(
        '$_baseUrl/$contactId',
        queryParameters: {
          'location_id': locationId,
        },
        options: Options(
          headers: {
            'X-GHL-Location-ID': locationId,
            'Accept': 'application/json',
          },
        ),
      );

      // Handle successful response (200 OK)
      if (response.statusCode == 200) {
        return Result.ok(true);
      } else {
        final errorMessage = response.data['message'];
        _logger.error('Error deleting contact', errorMessage);
        return Result.error(
          Exception('Error deleting contact'),
        );
      }
    } on DioException catch (e) {
      _logger.error('Error deleting contact', e);
      return _handleDioException(e, 'deleting contact');
    } catch (e) {
      _logger.error('Error deleting contact', e);
      return Result.error(
        Exception('Error deleting contact'),
      );
    }
  }

  /// Handles DioException with proper error messages based on HTTP status codes
  Result<T> _handleDioException<T>(DioException e, String operation) {
    _logger.error('DioException in $operation', e);

    String errorMessage;

    switch (e.response?.statusCode) {
      case 400:
        errorMessage = 'Bad request. Please check your data.';
        break;
      case 401:
        errorMessage = 'Authentication required. Please log in again.';
        break;
      case 403:
        errorMessage =
            'Access denied. You do not have permission for this operation.';
        break;
      case 404:
        errorMessage = 'Contact not found.';
        break;
      case 422:
        errorMessage = 'Validation failed.';
        break;
      case 429:
        errorMessage = 'Too many requests. Please try again later.';
        break;
      case 500:
        errorMessage = 'Internal server error. Please try again later.';
        break;
      case 502:
        errorMessage = 'Unable to communicate with service.';
        break;
      case 503:
        errorMessage =
            'Service temporarily unavailable. Please try again later.';
        break;
      default:
        errorMessage = 'Error occurred while $operation';
    }

    return Result.error(
      Exception(errorMessage),
    );
  }
}
