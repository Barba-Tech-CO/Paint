import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../model/contacts/contact_model.dart';
import '../../service/contact_loading_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_button.dart';
import '../../widgets/cards/input_card_widget.dart';
import '../../widgets/form_field/contact_dropdown_widget.dart';
import '../../widgets/form_field/project_type_row_widget.dart';

class CreateProjectView extends StatefulWidget {
  const CreateProjectView({super.key});

  @override
  State<CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<CreateProjectView> {
  final _projectDetailsController = TextEditingController();
  final _zoneNameController = TextEditingController();
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
    _zoneNameController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _selectedClient != null &&
        _projectDetailsController.text.trim().isNotEmpty &&
        _zoneNameController.text.trim().isNotEmpty &&
        _selectedProjectType.isNotEmpty;
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _loadContacts() async {
    if (_isLoadingContacts) return;

    setState(() {
      _isLoadingContacts = true;
      _contactsError = null;
    });

    try {
      final contacts = await getIt<ContactLoadingService>().loadContacts();

      setState(() {
        _contacts = contacts;
        // If we got contacts, clear any previous error
        if (contacts.isNotEmpty) {
          _contactsError = null;
        }
      });
    } catch (e) {
      setState(() {
        _contactsError =
            'Failed to load contacts. Please check your connection and try again.';
      });

      // Log the error for debugging
      try {
        final logger = getIt<AppLogger>();
        logger.error('CreateProjectView: Error loading contacts: $e');
      } catch (loggerError) {
        final logger = getIt<AppLogger>();
        logger.error('CreateProjectView: Error loading contacts: $e');
      }
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
      body: GestureDetector(
        onTap: _dismissKeyboard,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              spacing: 12,
              children: [
                const SizedBox.shrink(),

                // Client Information Card with Dropdown
                InputCardWidget(
                  title: 'Client Information',
                  description: 'Client Name: *',
                  widget: Column(
                    children: [
                      ContactDropdownWidget(
                        // label: 'Client Name: *',
                        selectedContact: _selectedClient,
                        contacts: _contacts,
                        isLoading: _isLoadingContacts,
                        errorText: _contactsError,
                        onChanged: (contact) {
                          setState(() {
                            _selectedClient = contact;
                          });
                        },
                        onRetry: _loadContacts,
                      ),
                    ],
                  ),
                ),

                InputCardWidget(
                  title: 'Project Details',
                  description: 'Project Name *',
                  controller: _projectDetailsController,
                  hintText: 'Enter project name',
                ),

                InputCardWidget(
                  title: 'Zone Details',
                  description: 'Zone Name *',
                  controller: _zoneNameController,
                  hintText: 'Enter zone name',
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
                      ProjectTypeRowWidget(
                        selectedType: _selectedProjectType,
                        onTypeChanged: (value) {
                          setState(() {
                            _selectedProjectType = value;
                          });
                        },
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
                  onPressed: !_isFormValid
                      ? null
                      : () {
                          // Pass project data including zone name to camera
                          final projectData = {
                            'projectName': _projectDetailsController.text
                                .trim(),
                            'zoneName': _zoneNameController.text.trim(),
                            'projectType': _selectedProjectType,
                            'clientId': _selectedClient?.id,
                            'additionalNotes': _additionalNotesController.text
                                .trim(),
                          };
                          context.push('/camera', extra: projectData);
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
