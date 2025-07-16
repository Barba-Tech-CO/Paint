import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'package:paintpro/view/layout/main_layout.dart';

class ContactsView extends StatelessWidget {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final mockContacts = [
      {
        'name': 'Sebastião Marcos Ferreira',
        'phone': '(65) 99268-1400',
      },
      {
        'name': 'Amanda Oliveira',
        'phone': '(11) 98765-4321',
      },
      {
        'name': 'Carlos Eduardo Santos',
        'phone': '(21) 97654-3210',
      },
    ];

    return MainLayout(
      currentRoute: '/contacts',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const PaintProAppBar(
          title: 'Contacts',
          toolbarHeight: 90,
        ),
        body: ListView.builder(
          itemCount: mockContacts.length,
          itemBuilder: (context, index) {
            final contact = mockContacts[index];
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
