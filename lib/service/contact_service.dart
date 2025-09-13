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

      // Usar a rota de busca para listar todos os contatos
      // Esta rota não tem validação restritiva como a rota POST principal
      final response = await _httpService.post(
        '$_baseUrl/search',
        data: {
          'locationId': locationId,
          if (limit != null) 'pageLimit': limit,
          // Converter offset para page
          if (offset != null && limit != null && limit > 0)
            'page': (offset / limit).floor() + 1,
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

      // Add name field as expected by API
      if (name != null && name.trim().isNotEmpty) {
        requestData['name'] = name.trim();
      }

      // Add optional fields
      if (email != null) requestData['email'] = email;
      if (phone != null) requestData['phone'] = phone;
      if (companyName != null && companyName.trim().isNotEmpty) {
        requestData['companyName'] = companyName.trim();
      }
      if (address != null) {
        requestData['address1'] = address;
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
        log('❌ UPDATE CONTACT: Location ID not available');
        return Result.error(
          Exception('Location ID not available. User not authenticated.'),
        );
      }

      log('🔄 UPDATE CONTACT: Starting update process');
      log('📋 Contact ID: $contactId');
      log('📍 Location ID: $locationId');

      final updateData = <String, dynamic>{};

      // Add name field as expected by API
      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
        log('✅ Added name: "$name"');
      } else if (name != null) {
        log('👤 Skipping empty name');
      }

      // Add other fields with detailed logging
      if (email != null && email.trim().isNotEmpty) {
        updateData['email'] = email.trim();
        log('📧 Added email: "$email"');
      } else if (email != null) {
        log('📧 Skipping empty email');
      }
      if (phone != null && phone.trim().isNotEmpty) {
        updateData['phone'] = phone.trim();
        log('📱 Added phone: "$phone"');
      } else if (phone != null) {
        log('📱 Skipping empty phone');
      }
      if (companyName != null && companyName.trim().isNotEmpty) {
        updateData['companyName'] = companyName.trim();
        log('🏢 Added companyName: "$companyName"');
      } else {
        log('🏢 Skipping empty companyName (API rejects empty strings)');
      }
      if (address != null && address.trim().isNotEmpty) {
        updateData['address1'] = address
            .trim(); // API expects address1 for updates
        log('🏠 Added address1: "$address"');
      } else if (address != null) {
        log('🏠 Skipping empty address');
      }
      if (city != null && city.trim().isNotEmpty) {
        updateData['city'] = city.trim();
        log('🏙️ Added city: "$city"');
      } else if (city != null) {
        log('🏙️ Skipping empty city');
      } else {
        log('🏙️ City is null, not including in update');
      }
      if (state != null && state.trim().isNotEmpty) {
        updateData['state'] = state.trim();
        log('🗺️ Added state: "$state"');
      } else if (state != null) {
        log('🗺️ Skipping empty state');
      }
      if (postalCode != null && postalCode.trim().isNotEmpty) {
        updateData['postalCode'] = postalCode.trim();
        log('📮 Added postalCode: "$postalCode"');
      } else if (postalCode != null) {
        log('📮 Skipping empty postalCode');
      }
      if (country != null && country.trim().isNotEmpty) {
        updateData['country'] = country.trim();
        log('🌍 Added country: "$country"');
      } else if (country != null) {
        log('🌍 Skipping empty country');
      }
      if (additionalEmails != null) {
        updateData['additionalEmails'] = additionalEmails;
        log('📧+ Added additionalEmails: $additionalEmails');
      }
      if (additionalPhones != null) {
        updateData['additionalPhones'] = additionalPhones;
        log('📱+ Added additionalPhones: $additionalPhones');
      }
      if (tags != null) {
        updateData['tags'] = tags;
        log('🏷️ Added tags: $tags');
      }
      if (customFields != null) {
        updateData['customFields'] = customFields;
        log('⚙️ Added customFields: $customFields');
      }

      // Log the complete payload
      log('📦 COMPLETE UPDATE PAYLOAD:');
      log('   Method: PUT');
      log('   URL: ${_httpService.dio.options.baseUrl}$_baseUrl/$contactId');
      log(
        '   Headers: {X-GHL-Location-ID: $locationId, Accept: application/json, Content-Type: application/json}',
      );
      log('   Body Data: $updateData');
      log('   Body Data Keys: ${updateData.keys.toList()}');
      log('   Body Data Size: ${updateData.length} fields');

      // Check for required fields according to API docs
      if (updateData['name'] == null || updateData['name'].toString().isEmpty) {
        log('⚠️ WARNING: name is missing but may be required by API');
      }

      log('🚀 Making PUT request to update contact...');

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

      log('📨 RESPONSE RECEIVED:');
      log('   Status Code: ${response.statusCode}');
      log('   Headers: ${response.headers}');
      log('   Data: ${response.data}');

      // Handle successful response (200 OK)
      if (response.statusCode == 200) {
        log('✅ UPDATE SUCCESS: Status 200 received');

        if (response.data['success'] == true &&
            response.data['contactDetails'] != null) {
          log('📄 Found contactDetails with success=true');
          final contact = ContactModel.fromJson(
            response.data['contactDetails'],
          );
          log('🎉 Contact successfully parsed and updated');
          return Result.ok(contact);
        } else if (response.data['contactDetails'] != null) {
          log('📄 Found contactDetails without success flag');
          final contact = ContactModel.fromJson(
            response.data['contactDetails'],
          );
          log('🎉 Contact successfully parsed and updated');
          return Result.ok(contact);
        } else if (response.data['data'] != null) {
          log('📄 Found data field');
          final contact = ContactModel.fromJson(response.data['data']);
          log('🎉 Contact successfully parsed and updated');
          return Result.ok(contact);
        } else {
          log('❌ No contact data found in response structure');
          log('   Available keys: ${response.data?.keys?.toList()}');
          return Result.error(
            Exception('Contact data not found in response'),
          );
        }
      } else {
        log('❌ NON-200 RESPONSE: Status ${response.statusCode}');
        log('   Response data: ${response.data}');
        final errorMessage =
            response.data['message'] ?? 'Error updating contact';
        return Result.error(
          Exception(errorMessage),
        );
      }
    } on DioException catch (e) {
      log('❌ DIO EXCEPTION CAUGHT:');
      log('   Type: ${e.type}');
      log('   Message: ${e.message}');
      log('   Status Code: ${e.response?.statusCode}');
      log('   Response Headers: ${e.response?.headers}');
      log('   Response Data: ${e.response?.data}');
      log('   Request Data: ${e.requestOptions.data}');
      log('   Request Headers: ${e.requestOptions.headers}');
      log('   Request URL: ${e.requestOptions.uri}');

      // Special handling for 422 validation errors
      if (e.response?.statusCode == 422) {
        log('🔍 DETAILED 422 VALIDATION ERROR ANALYSIS:');
        final responseData = e.response?.data;
        if (responseData != null) {
          log('   Full Response: $responseData');

          if (responseData is Map<String, dynamic>) {
            if (responseData['errors'] != null) {
              log('   Validation Errors: ${responseData['errors']}');
            }
            if (responseData['message'] != null) {
              log('   Error Message: ${responseData['message']}');
            }
          }
        }
      }

      return _handleDioException(e, 'updating contact');
    } catch (e) {
      log('❌ GENERAL EXCEPTION: $e');
      log('   Type: ${e.runtimeType}');
      log('   Stack trace: ${StackTrace.current}');

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
