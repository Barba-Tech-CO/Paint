import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../helpers/contact_helper.dart';
import '../../model/contacts/contact_model.dart';
import '../../service/contact_database_service.dart';
import '../../service/contact_service.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_button.dart';
import '../../widgets/cards/input_card_widget.dart';
import '../../widgets/form_field/contact_dropdown_widget.dart';

class CreateProjectView extends StatefulWidget {
  const CreateProjectView({super.key});

  @override
  State<CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<CreateProjectView> {
  final _projectDetailsController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  // Estado para controlar a seleção do tipo de projeto
  String _selectedProjectType = '';

  // Estado para contatos
  List<ContactModel> _contacts = [];
  ContactModel? _selectedClient;
  bool _isLoadingContacts = false;
  String? _contactsError;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _additionalNotesController.dispose();
    _projectDetailsController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _selectedClient != null &&
        _projectDetailsController.text.trim().isNotEmpty &&
        _selectedProjectType.isNotEmpty;
  }

  Future<void> _loadContacts() async {
    if (_isLoadingContacts) return;

    setState(() {
      _isLoadingContacts = true;
      _contactsError = null;
    });

    try {
      final contactService = context.read<ContactService>();
      final contactDatabaseService = context.read<ContactDatabaseService>();

      final contacts = await ContactHelper.loadContacts(
        contactService: contactService,
        contactDatabaseService: contactDatabaseService,
      );

      setState(() {
        _contacts = contacts;
      });
    } catch (e) {
      setState(() {
        _contactsError = 'Failed to load contacts';
      });
    } finally {
      setState(() {
        _isLoadingContacts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaintProAppBar(
        title: 'New Project',
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 12,
            children: [
              const SizedBox.shrink(),

              // Client Information Card with Dropdown
              InputCardWidget(
                title: 'Client Information',
                description: 'Client Name*',
                widget: ContactDropdownWidget(
                  label: 'Client Name',
                  selectedContact: _selectedClient,
                  contacts: _contacts,
                  isLoading: _isLoadingContacts,
                  errorText: _contactsError,
                  onChanged: (contact) {
                    setState(() {
                      _selectedClient = contact;
                    });
                  },
                ),
              ),

              InputCardWidget(
                title: 'Project Details',
                description: 'Project Name *',
                controller: _projectDetailsController,
                hintText: 'Enter project name',
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Project Type *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Radio(
                          value: 'Interior',
                          groupValue: _selectedProjectType,
                          onChanged: (value) {
                            setState(() {
                              _selectedProjectType = value.toString();
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        Text('Interior'),

                        const SizedBox(width: 16),

                        Radio(
                          value: 'Exterior',
                          groupValue: _selectedProjectType,
                          onChanged: (value) {
                            setState(() {
                              _selectedProjectType = value.toString();
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        Text('Exterior'),

                        const SizedBox(width: 16),

                        Radio(
                          value: 'Both',
                          groupValue: _selectedProjectType,
                          onChanged: (value) {
                            setState(() {
                              _selectedProjectType = value.toString();
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        Text('Both'),
                      ],
                    ),
                  ],
                ),
              ),

              InputCardWidget(
                title: 'Additional Notes',
                controller: _additionalNotesController,
                hintText: 'Enter additional notes',
                maxLines: 6,
                multiline: true,
              ),

              PaintProButton(
                text: 'Next',
                onPressed: !_isFormValid ? null : () => context.push('/camera'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
