import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import '../layout/main_layout.dart';
import '../widgets/appbars/paint_pro_app_bar.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({super.key});

  @override
  State<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  final TextEditingController searchController = TextEditingController();

  // Lista de contatos mockados
  List<Map<String, String>> allContacts = [
    {
      'name': 'Ana Tessendre',
      'phone': '+1 75 385-85605',
      'address': '1243 New orlando, Texas, USA',
    },
    {
      'name': 'Leonardo Martins',
      'phone': '+1 51 332-71890',
      'address': '77 Grove S, New York, USA',
    },
    {
      'name': 'Camila Rocha',
      'phone': '+1 33 918-45673',
      'address': '503 Main St, Florida, USA',
    },
    {
      'name': 'Diego Alvarez',
      'phone': '+1 48 762-90123',
      'address': '21 Broadway, Ohio, USA',
    },
    {
      'name': 'Fernanda Lopes',
      'phone': '+1 27 388-11456',
      'address': '1098 Pine Road, New Jersey, USA',
    },
    {
      'name': 'Beatriz Alcantra',
      'phone': '+1 75 385-85605',
      'address': '1243 New orlando, Texas, USA',
    },
    {
      'name': 'Fernanda Lopes',
      'phone': '+1 27 388-11456',
      'address': '1098 Pine Road, New Jersey, USA',
    },
  ];

  List<Map<String, String>> filteredContacts = [];

  // Cores para os avatares
  final List<Color> avatarColors = [
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    filteredContacts = List.from(allContacts);
    searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    final query = searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredContacts = List.from(allContacts);
      } else {
        filteredContacts = allContacts.where((contact) {
          final name = contact['name']?.toLowerCase() ?? '';
          return name.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Para testar estado vazio, descomente a linha abaixo:
    // allContacts = [];

    return MainLayout(
      currentRoute: '/contacts',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const PaintProAppBar(
          title: 'Contacts',
          toolbarHeight: 90,
        ),
        body: ListView.builder(
          itemCount: allContacts.length,
          itemBuilder: (context, index) {
            final contact = allContacts[index];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(contact['name']!),
              subtitle: Text(contact['phone']!),
              onTap: () => context.push('/contact-details'),
            );
          },
        ),
      ),
    );
  }
}
