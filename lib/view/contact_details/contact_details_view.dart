import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/dependency_injection.dart';
import '../../model/contacts/contact_model.dart';
import '../../utils/result/result.dart';
import '../../viewmodel/contact/contact_detail_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/contacts/info_card_widget.dart';
import '../../widgets/contacts/info_row_widget.dart';
import '../../widgets/contacts/section_header_widget.dart';

class ContactDetailsView extends StatefulWidget {
  final ContactModel contact;

  const ContactDetailsView({
    super.key,
    required this.contact,
  });

  @override
  State<ContactDetailsView> createState() => _ContactDetailsViewState();
}

class _ContactDetailsViewState extends State<ContactDetailsView> {
  late final ContactDetailViewModel _viewModel;
  ContactModel? _currentContact;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ContactDetailViewModel>();
    _currentContact = widget.contact;
    _loadContactDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarregar dados quando a tela for exibida novamente (ex: voltando da edição)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContactDetails();
    });
  }

  Future<void> _loadContactDetails() async {
    final result = await _viewModel.getContactDetails(widget.contact.id!);
    if (result is Ok && mounted) {
      setState(() {
        _currentContact = result.asOk.value;
      });
    }
  }

  String _getDisplayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'N/A';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contact = _currentContact ?? widget.contact;

    final hasCompanyName = contact.companyName?.isNotEmpty ?? false;
    final hasBusinessName = contact.businessName?.isNotEmpty ?? false;
    final hasType = contact.type?.isNotEmpty ?? false;
    final showAdditionalInfo = hasCompanyName || hasBusinessName || hasType;

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
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
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
                  InfoRowWidget(
                    label: 'Email',
                    value: _getDisplayValue(contact.email),
                  ),
                  InfoRowWidget(
                    label: 'Phone',
                    value: _getDisplayValue(contact.phone),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const SectionHeaderWidget(icon: Icons.home, title: 'Address'),
              InfoCardWidget(
                children: [
                  InfoRowWidget(
                    label: 'Street',
                    value: _getDisplayValue(contact.address),
                  ),
                  InfoRowWidget(
                    label: 'ZIP Code',
                    value: _getDisplayValue(contact.postalCode),
                  ),
                  InfoRowWidget(
                    label: 'City',
                    value: _getDisplayValue(contact.city),
                  ),
                  InfoRowWidget(
                    label: 'State',
                    value: _getDisplayValue(contact.state),
                  ),
                  InfoRowWidget(
                    label: 'Country',
                    value: _getDisplayValue(contact.country),
                  ),
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
                    if (hasType)
                      InfoRowWidget(
                        label: 'Type',
                        value: _getDisplayValue(contact.type),
                      ),
                    if (hasCompanyName)
                      InfoRowWidget(
                        label: 'Company',
                        value: _getDisplayValue(contact.companyName),
                      ),
                    if (hasBusinessName)
                      InfoRowWidget(
                        label: 'Business Name',
                        value: _getDisplayValue(contact.businessName),
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

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
