import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_urls.dart';
import '../model/models.dart';
import '../utils/result/result.dart';
import 'http_service.dart';

class ContactService {
  final HttpService _httpService;
  static const String _baseUrl = AppUrls.contactsBaseUrl;

  ContactService(this._httpService);

  /// Lista contatos com paginação
  Future<Result<ContactListResponse>> getContacts({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _httpService.get(
        _baseUrl,
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      // Handle the API response structure with success and data fields
      if (response.data['success'] == true) {
        // The API returns the contacts directly in the response when success is true
        final contactListResponse = ContactListResponse.fromJson(response.data);
        return Result.ok(contactListResponse);
      } else {
        final errorMessage =
            response.data['message'] ?? 'Error listing contacts';
        return Result.error(
          Exception(errorMessage),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Error listing contacts: $e'),
      );
    }
  }

  /// Busca contatos por nome, email ou telefone
  Future<Result<ContactListResponse>> searchContacts(String query) async {
    try {
      final response = await _httpService.get(
        _baseUrl,
        queryParameters: {'query': query},
      );

      // Handle the API response structure with success and data fields
      if (response.data['success'] == true) {
        // The API returns the contacts directly in the response when success is true
        final contactListResponse = ContactListResponse.fromJson(response.data);
        return Result.ok(contactListResponse);
      } else {
        final errorMessage =
            response.data['message'] ?? 'Error searching contacts';
        return Result.error(
          Exception(errorMessage),
        );
      }
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
      final response = await _httpService.post(
        '$_baseUrl/search',
        data: {
          if (locationId != null) 'locationId': locationId,
          if (pageLimit != null) 'pageLimit': pageLimit,
          if (page != null) 'page': page,
          if (query != null) 'query': query,
          if (filters != null) 'filters': filters,
          if (sort != null) 'sort': sort,
        },
      );

      // Handle the API response structure with success and data fields
      if (response.data['success'] == true) {
        // The API returns the contacts directly in the response when success is true
        final contactListResponse = ContactListResponse.fromJson(response.data);
        return Result.ok(contactListResponse);
      } else {
        final errorMessage =
            response.data['message'] ?? 'Error in advanced search';
        return Result.error(
          Exception(errorMessage),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Error in advanced search: $e'),
      );
    }
  }

  /// Obtém um contato específico
  Future<Result<ContactModel>> getContact(String contactId) async {
    try {
      final response = await _httpService.get('$_baseUrl/$contactId');

      // Handle the specific response structure from the API
      if (response.data['success'] == true) {
        if (response.data['contactDetails'] != null) {
          final contact = ContactModel.fromJson(
            response.data['contactDetails'],
          );
          return Result.ok(contact);
        } else if (response.data['data'] != null) {
          final contact = ContactModel.fromJson(response.data['data']);
          return Result.ok(contact);
        } else if (response.data['contact'] != null) {
          final contact = ContactModel.fromJson(response.data['contact']);
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
  }) async {
    try {
      final requestData = <String, dynamic>{};

      // Add name field
      if (name != null && name.isNotEmpty) {
        requestData['name'] = name;
      }

      // Add other fields
      if (email != null) requestData['email'] = email;
      if (phone != null) requestData['phone'] = phone;
      if (companyName != null) requestData['companyName'] = companyName;
      if (address != null) requestData['address'] = address;
      if (city != null) requestData['city'] = city;
      if (state != null) requestData['state'] = state;
      if (postalCode != null) requestData['postalCode'] = postalCode;
      if (country != null) requestData['country'] = country;
      if (additionalEmails != null && additionalEmails.isNotEmpty) {
        requestData['additionalEmails'] = additionalEmails;
      }
      if (additionalPhones != null && additionalPhones.isNotEmpty) {
        requestData['additionalPhones'] = additionalPhones;
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

      // Use the correct endpoint for creating contacts (POST /v1/contacts)
      final response = await _httpService.post(
        _baseUrl,
        data: requestData,
      );

      // Handle the specific response structure from the API
      if (response.data['success'] == true) {
        if (response.data['contactDetails'] != null) {
          final contact = ContactModel.fromJson(
            response.data['contactDetails'],
          );
          return Result.ok(contact);
        } else if (response.data['data'] != null) {
          final contact = ContactModel.fromJson(response.data['data']);
          return Result.ok(contact);
        } else if (response.data['contact'] != null) {
          final contact = ContactModel.fromJson(response.data['contact']);
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
      // Handle specific HTTP status codes for GET requests
      String errorMessage;
      switch (e.response?.statusCode) {
        case 404:
          errorMessage =
              'Contact sync endpoint not found. Please check the API configuration.';
          break;
        case 401:
          errorMessage = 'Authentication required. Please log in again.';
          break;
        case 403:
          errorMessage =
              'Access denied. You do not have permission to sync contacts.';
          break;
        case 422:
          errorMessage =
              'Invalid sync parameters. Please check your information.';
          break;
        case 500:
          errorMessage = 'Server error. Please try again later.';
          break;
        default:
          errorMessage = 'Error syncing contact: ${e.message}';
      }
      return Result.error(Exception(errorMessage));
    } catch (e) {
      return Result.error(
        Exception('Error syncing contact: $e'),
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
  }) async {
    try {
      final updateData = <String, dynamic>{};

      // Add name field
      if (name != null && name.isNotEmpty) {
        updateData['name'] = name;
      }

      // Add other fields
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (companyName != null) updateData['companyName'] = companyName;
      if (address != null) updateData['address'] = address;
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
      if (customFields != null) updateData['customFields'] = customFields;

      final response = await _httpService.put(
        '$_baseUrl/$contactId',
        data: updateData,
      );

      // Handle the specific response structure from the API
      if (response.data['success'] == true) {
        if (response.data['contactDetails'] != null) {
          final contact = ContactModel.fromJson(
            response.data['contactDetails'],
          );
          return Result.ok(contact);
        } else if (response.data['data'] != null) {
          final contact = ContactModel.fromJson(response.data['data']);
          return Result.ok(contact);
        } else if (response.data['contact'] != null) {
          final contact = ContactModel.fromJson(response.data['contact']);
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
    } catch (e) {
      return Result.error(
        Exception('Error updating contact: $e'),
      );
    }
  }

  /// Remove um contato
  Future<Result<bool>> deleteContact(String contactId) async {
    try {
      final response = await _httpService.delete('$_baseUrl/$contactId');

      // Handle the specific response structure from the API
      if (response.data['success'] == true) {
        return Result.ok(true);
      } else {
        final errorMessage =
            response.data['message'] ?? 'Error deleting contact';
        return Result.error(
          Exception(errorMessage),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Error deleting contact: $e'),
      );
    }
  }
}
