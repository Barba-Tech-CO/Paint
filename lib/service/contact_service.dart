import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_urls.dart';
import '../model/contacts/contact_list_response.dart';
import '../model/contacts/contact_model.dart';
import '../utils/result/result.dart';
import 'http_service.dart';
import 'location_service.dart';

class ContactService {
  final HttpService _httpService;
  final LocationService _locationService;
  static const String _baseUrl = AppUrls.contactsBaseUrl;

  ContactService(this._httpService, this._locationService);

  /// Lista contatos com paginação
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

      final response = await _httpService.post(
        _baseUrl,
        queryParameters: {
          'location_id': locationId,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
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
        final contactListResponse = ContactListResponse.fromJson(response.data);
        return Result.ok(contactListResponse);
      } else {
        final errorMessage =
            response.data['message'] ?? 'Error listing contacts';
        return Result.error(
          Exception(errorMessage),
        );
      }
    } on DioException catch (e) {
      return _handleDioException(e, 'listing contacts');
    } catch (e) {
      return Result.error(
        Exception('Error listing contacts: $e'),
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
        _baseUrl,
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
        final contactListResponse = ContactListResponse.fromJson(response.data);
        return Result.ok(contactListResponse);
      } else {
        final errorMessage =
            response.data['message'] ?? 'Error searching contacts';
        return Result.error(
          Exception(errorMessage),
        );
      }
    } on DioException catch (e) {
      return _handleDioException(e, 'searching contacts');
    } catch (e) {
      return Result.error(
        Exception('Error searching contacts: $e'),
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
        final errorMessage =
            response.data['message'] ?? 'Error in advanced search';
        return Result.error(
          Exception(errorMessage),
        );
      }
    } on DioException catch (e) {
      return _handleDioException(e, 'advanced search');
    } catch (e) {
      return Result.error(
        Exception('Error in advanced search: $e'),
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
          return Result.error(
            Exception('Contact data not found in response'),
          );
        }
      } else {
        final errorMessage = response.data['message'] ?? 'Contact not found';
        return Result.error(
          Exception(errorMessage),
        );
      }
    } on DioException catch (e) {
      return _handleDioException(e, 'getting contact');
    } catch (e) {
      return Result.error(
        Exception('Error getting contact: $e'),
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

      // Add required name field (name required)
      if (name != null && name.isNotEmpty) {
        requestData['name'] = name; // API expects name
      }

      // Add optional fields
      if (email != null) requestData['email'] = email;
      if (phone != null) requestData['phone'] = phone;
      if (companyName != null) requestData['companyName'] = companyName;
      if (address != null) {
        requestData['address1'] = address; // API expects address1
      }
      if (city != null) requestData['city'] = city;
      if (state != null) requestData['state'] = state;
      if (postalCode != null) requestData['postalCode'] = postalCode;
      if (country != null) requestData['country'] = country;
      if (tags != null && tags.isNotEmpty) {
        requestData['tags'] = tags;
      }
      if (customFields != null && customFields.isNotEmpty) {
        requestData['customFields'] = customFields;
      }

      // Debug: Log the request details
      if (kDebugMode) {
        log('Debug: Creating contact with URL: $_baseUrl');
        log(
          'Debug: Full URL will be: ${_httpService.dio.options.baseUrl}$_baseUrl',
        );
        log('Debug: Request data: $requestData');
        log('Debug: HTTP Method: POST');
        log(
          'Debug: GHL Token: ${_httpService.ghlToken != null ? "Present" : "Missing"}',
        );
      }

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
          return Result.error(
            Exception('Contact data not found in response'),
          );
        }
      } else {
        final errorMessage =
            response.data['message'] ?? 'Error creating contact';
        return Result.error(
          Exception(errorMessage),
        );
      }
    } on DioException catch (e) {
      return _handleDioException(e, 'creating contact');
    } catch (e) {
      return Result.error(
        Exception('Error creating contact: $e'),
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
        return Result.error(
          Exception('Location ID not available. User not authenticated.'),
        );
      }

      final updateData = <String, dynamic>{};

      // Add name field (API expects name)
      if (name != null && name.isNotEmpty) {
        updateData['name'] = name;
      }

      // Add other fields
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (companyName != null) updateData['companyName'] = companyName;
      if (address != null) {
        updateData['address1'] = address; // API expects address1
      }
      if (city != null) updateData['city'] = city;
      if (state != null) updateData['state'] = state;
      if (postalCode != null) updateData['postalCode'] = postalCode;
      if (country != null) updateData['country'] = country;
      if (additionalEmails != null) {
        updateData['additionalEmails'] = additionalEmails;
      }
      if (additionalPhones != null) {
        updateData['additionalPhones'] = additionalPhones;
      }
      if (tags != null) updateData['tags'] = tags;
      if (customFields != null) updateData['customFields'] = customFields;

      final response = await _httpService.put(
        '$_baseUrl/$contactId',
        data: updateData,
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
          return Result.error(
            Exception('Contact data not found in response'),
          );
        }
      } else {
        final errorMessage =
            response.data['message'] ?? 'Error updating contact';
        return Result.error(
          Exception(errorMessage),
        );
      }
    } on DioException catch (e) {
      return _handleDioException(e, 'updating contact');
    } catch (e) {
      return Result.error(
        Exception('Error updating contact: $e'),
      );
    }
  }

  /// Remove um contato
  Future<Result<bool>> deleteContact(String contactId) async {
    try {
      final locationId = _locationService.currentLocationId;
      if (locationId == null || locationId.isEmpty) {
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
        final errorMessage =
            response.data['message'] ?? 'Error deleting contact';
        return Result.error(
          Exception(errorMessage),
        );
      }
    } on DioException catch (e) {
      return _handleDioException(e, 'deleting contact');
    } catch (e) {
      return Result.error(
        Exception('Error deleting contact: $e'),
      );
    }
  }

  /// Handles DioException with proper error messages based on HTTP status codes
  Result<T> _handleDioException<T>(DioException e, String operation) {
    String errorMessage;

    switch (e.response?.statusCode) {
      case 400:
        errorMessage = 'Bad request. Please check your data.';
        break;
      case 401:
        // Handle OAuth token expiration
        if (e.response?.data != null && e.response?.data['auth_url'] != null) {
          errorMessage = 'Authentication required. Please log in again.';
        } else {
          errorMessage =
              'Token not found or expired. Please authenticate again.';
        }
        break;
      case 403:
        errorMessage =
            'Access denied. You do not have permission for this operation.';
        break;
      case 404:
        errorMessage = 'Contact not found.';
        break;
      case 422:
        // Handle validation errors
        final errors = e.response?.data?['errors'];
        if (errors != null && errors is Map<String, dynamic>) {
          final errorList = errors.values
              .whereType<List>()
              .expand((error) => error)
              .join(', ');
          errorMessage = 'Validation failed: $errorList';
        } else {
          errorMessage = e.response?.data?['message'] ?? 'Validation failed.';
        }
        break;
      case 429:
        // Handle rate limiting
        final retryAfter = e.response?.data?['details']?['retry_after_seconds'];
        if (retryAfter != null) {
          errorMessage =
              'Too many requests. Please try again in $retryAfter seconds.';
        } else {
          errorMessage = 'Too many requests. Please slow down.';
        }
        break;
      case 500:
        errorMessage = 'Internal server error. Please try again later.';
        break;
      case 502:
        errorMessage = 'Unable to communicate with GoHighLevel service.';
        break;
      case 503:
        errorMessage =
            'Service temporarily unavailable. Please try again later.';
        break;
      default:
        errorMessage = 'Error $operation: ${e.message}';
    }

    return Result.error(Exception(errorMessage));
  }
}
