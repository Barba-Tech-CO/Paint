import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/dependency_injection.dart';
import '../../helpers/contacts/contact_details_helper.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contact = _currentContact ?? widget.contact;

    final showAdditionalInfo = ContactDetailsHelper.hasAdditionalBusinessInfo(
      contact,
    );

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
                      style: ContactDetailsHelper.getContactNameStyle(theme),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SectionHeaderWidget(
                icon:
                    ContactDetailsHelper.getContactSectionData()['icon']
                        as IconData,
                title:
                    ContactDetailsHelper.getContactSectionData()['title']
                        as String,
              ),
              InfoCardWidget(
                children: ContactDetailsHelper.getContactInfoRows(contact)
                    .map(
                      (row) => InfoRowWidget(
                        label: row['label']!,
                        value: row['value']!,
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 16),
              SectionHeaderWidget(
                icon:
                    ContactDetailsHelper.getAddressSectionData()['icon']
                        as IconData,
                title:
                    ContactDetailsHelper.getAddressSectionData()['title']
                        as String,
              ),
              InfoCardWidget(
                children: ContactDetailsHelper.getAddressInfoRows(contact)
                    .map(
                      (row) => InfoRowWidget(
                        label: row['label']!,
                        value: row['value']!,
                      ),
                    )
                    .toList(),
              ),

              if (showAdditionalInfo) ...[
                const SizedBox(height: 16),

                SectionHeaderWidget(
                  icon:
                      ContactDetailsHelper.getAdditionalInfoSectionData()['icon']
                          as IconData,
                  title:
                      ContactDetailsHelper.getAdditionalInfoSectionData()['title']
                          as String,
                ),
                InfoCardWidget(
                  children: ContactDetailsHelper.getAdditionalInfoRows(contact)
                      .map(
                        (row) => InfoRowWidget(
                          label: row['label']!,
                          value: row['value']!,
                        ),
                      )
                      .toList(),
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
