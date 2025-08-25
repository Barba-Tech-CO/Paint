import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import '../layout/main_layout.dart';
import '../widgets/widgets.dart';
import 'widgets/contact_item_widget.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({super.key});

  @override
  State<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase().trim();
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
    return MainLayout(
      currentRoute: '/contacts',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const PaintProAppBar(
          title: 'Contacts',
          toolbarHeight: 90,
        ),
        body: Stack(
          children: [
            allContacts.isEmpty
                ? EmptyStateWidget(
                    title: 'No Contacts yet',
                    subtitle: 'Add your first contact to get started',
                    buttonText: 'Add Contact',
                    onButtonPressed: () => context.push('/contact-details'),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 32,
                          right: 32,
                          top: 24,
                          bottom: 16,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: allContacts.length,
                          padding: const EdgeInsets.only(
                            bottom: 140,
                            left: 16,
                            right: 16,
                          ),
                          itemBuilder: (context, index) {
                            final contact = allContacts[index];
                            return ContactItemWidget(
                              contact: contact,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
            // FAB posicionado manualmente
            if (allContacts.isNotEmpty)
              Positioned(
                bottom: 140, // 120px do bottom navigation + 20px de margem
                right: 16,
                child: PaintProFAB(
                  onPressed: () => context.push('/new-contact'),
                  icon: Icons.add,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
