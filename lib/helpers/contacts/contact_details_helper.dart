import 'package:flutter/material.dart';

import '../../model/contacts/contact_model.dart';

class ContactDetailsHelper {
  /// Gets display value for contact fields, showing 'N/A' for empty values
  static String getDisplayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'N/A';
    }
    return value;
  }

  /// Checks if contact has additional business information
  static bool hasAdditionalBusinessInfo(ContactModel contact) {
    final hasCompanyName = contact.companyName?.isNotEmpty ?? false;
    final hasBusinessName = contact.businessName?.isNotEmpty ?? false;
    final hasType = contact.type?.isNotEmpty ?? false;
    return hasCompanyName || hasBusinessName || hasType;
  }

  /// Gets contact name display style
  static TextStyle getContactNameStyle(ThemeData theme) {
    return theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ) ??
        const TextStyle();
  }

  /// Gets section header data for contact information
  static Map<String, dynamic> getContactSectionData() {
    return {
      'icon': Icons.contact_phone,
      'title': 'Contact',
    };
  }

  /// Gets section header data for address information
  static Map<String, dynamic> getAddressSectionData() {
    return {
      'icon': Icons.home,
      'title': 'Address',
    };
  }

  /// Gets section header data for additional business information
  static Map<String, dynamic> getAdditionalInfoSectionData() {
    return {
      'icon': Icons.business,
      'title': 'Additional Info',
    };
  }

  /// Gets contact information rows
  static List<Map<String, String>> getContactInfoRows(ContactModel contact) {
    return [
      {
        'label': 'Email',
        'value': getDisplayValue(contact.email),
      },
      {
        'label': 'Phone',
        'value': getDisplayValue(contact.phone),
      },
    ];
  }

  /// Gets address information rows
  static List<Map<String, String>> getAddressInfoRows(ContactModel contact) {
    return [
      {
        'label': 'Street',
        'value': getDisplayValue(contact.address),
      },
      {
        'label': 'ZIP Code',
        'value': getDisplayValue(contact.postalCode),
      },
      {
        'label': 'City',
        'value': getDisplayValue(contact.city),
      },
      {
        'label': 'State',
        'value': getDisplayValue(contact.state),
      },
      {
        'label': 'Country',
        'value': getDisplayValue(contact.country),
      },
    ];
  }

  /// Gets additional business information rows
  static List<Map<String, String>> getAdditionalInfoRows(ContactModel contact) {
    final rows = <Map<String, String>>[];

    if (contact.type?.isNotEmpty ?? false) {
      rows.add({
        'label': 'Type',
        'value': getDisplayValue(contact.type),
      });
    }

    if (contact.companyName?.isNotEmpty ?? false) {
      rows.add({
        'label': 'Company',
        'value': getDisplayValue(contact.companyName),
      });
    }

    if (contact.businessName?.isNotEmpty ?? false) {
      rows.add({
        'label': 'Business Name',
        'value': getDisplayValue(contact.businessName),
      });
    }

    return rows;
  }
}
