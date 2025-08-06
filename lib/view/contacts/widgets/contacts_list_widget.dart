import 'package:flutter/material.dart';
import 'contact_item_widget.dart';

class ContactsListWidget extends StatelessWidget {
  final List<Map<String, String>> contacts;
  final List<Map<String, String>> allContacts;
  final List<Color> avatarColors;

  const ContactsListWidget({
    super.key,
    required this.contacts,
    required this.allContacts,
    required this.avatarColors,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final originalIndex = allContacts.indexOf(contact);
        final color = avatarColors[originalIndex % avatarColors.length];

        return ContactItemWidget(
          contact: contact,
          avatarColor: color,
        );
      },
    );
  }
}
