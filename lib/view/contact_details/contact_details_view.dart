import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/contact/contact_detail_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/contacts/info_card_widget.dart';
import '../../widgets/contacts/info_row_widget.dart';
import '../../widgets/contacts/section_header_widget.dart';

class ContactDetailsView extends StatelessWidget {
  const ContactDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final vm = context.watch<ContactDetailViewModel>();
    final contact = vm.selectedContact;

    final hasCompanyName = contact.companyName?.isNotEmpty ?? false;
    final hasBusinessName = contact.businessName?.isNotEmpty ?? false;
    final showAdditionalInfo = hasCompanyName || hasBusinessName;

    return Scaffold(
      appBar: PaintProAppBar(
        title: 'Contact Details',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome e informação de tipo
              Center(
                child: Column(
                  children: [
                    Text(
                      contact.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (contact.type != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          contact.type!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const SectionHeaderWidget(
                icon: Icons.contact_phone,
                title: 'Contact',
              ),
              InfoCardWidget(
                children: [
                  InfoRowWidget(label: 'Email', value: contact.email),
                  InfoRowWidget(label: 'Phone', value: contact.phone),
                ],
              ),

              const SizedBox(height: 16),

              const SectionHeaderWidget(icon: Icons.home, title: 'Address'),
              InfoCardWidget(
                children: [
                  InfoRowWidget(label: 'Street', value: contact.address),
                  InfoRowWidget(label: 'ZIP Code', value: contact.postalCode),
                  InfoRowWidget(label: 'City', value: contact.city),
                  InfoRowWidget(label: 'State', value: contact.state),
                  InfoRowWidget(label: 'Country', value: contact.country),
                ],
              ),

              if (showAdditionalInfo) ...[
                const SizedBox(height: 16),

                const SectionHeaderWidget(
                  icon: Icons.business,
                  title: 'Additional Info',
                ),
                InfoCardWidget(
                  children: [
                    if (hasCompanyName)
                      InfoRowWidget(
                        label: 'Company',
                        value: contact.companyName,
                      ),
                    if (hasBusinessName)
                      InfoRowWidget(
                        label: 'Business Name',
                        value: contact.businessName,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(
            '/edit-contact',
            extra: contact,
          );
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
    );
  }
}
