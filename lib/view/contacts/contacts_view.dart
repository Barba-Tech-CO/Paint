import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../helpers/contacts/split_full_name.dart';
import '../../model/contacts/contact_model.dart';
import '../../viewmodel/contacts/contacts_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_fab.dart';
import '../../widgets/contacts/contact_item_widget.dart';
import '../../widgets/states/empty_state_widget.dart';
import '../layout/main_layout.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({super.key});

  @override
  State<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  final TextEditingController _searchController = TextEditingController();
  late final ContactsViewModel _viewModel;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ContactsViewModel>();
    // Use Future.microtask to defer initialization after build
    Future.microtask(() {
      _viewModel.initialize();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _viewModel.searchQuery = _searchController.text;
    });
  }

  Map<String, String> _convertContactModelToMap(ContactModel contact) {
    return _viewModel.convertContactModelToMap(contact);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: MainLayout(
        currentRoute: '/contacts',
        child: GestureDetector(
          onTap: () => ContactsViewModel.dismissKeyboard(context),
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: PaintProAppBar(
              title: 'Contacts',
              toolbarHeight: 90.h,
            ),
            body: Consumer<ContactsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return viewModel.getLoadingWidget();
                }

                if (viewModel.hasError) {
                  return ContactsViewModel.getErrorWidget(
                    viewModel.errorMessage ?? 'Unknown error',
                    () => viewModel.loadContacts(),
                  );
                }

                return Stack(
                  children: [
                    !viewModel.hasContacts
                        ? RefreshIndicator(
                            onRefresh: () async {
                              await _viewModel.refreshContacts();
                            },
                            color: AppColors.primary,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 200,
                                child: EmptyStateWidget(
                                  title: 'No Contacts yet',
                                  subtitle:
                                      'Add your first contact to get started',
                                  buttonText: 'Add Contact',
                                  onButtonPressed: () =>
                                      context.push('/new-contact'),
                                ),
                              ),
                            ),
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
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    await _viewModel.refreshContacts();
                                  },
                                  color: AppColors.primary,
                                  child: ListView.builder(
                                    itemCount:
                                        viewModel.filteredContacts.length,
                                    padding: const EdgeInsets.only(
                                      bottom: 140,
                                      left: 16,
                                      right: 16,
                                    ),
                                    itemBuilder: (context, index) {
                                      final contact =
                                          viewModel.filteredContacts[index];
                                      final contactMap =
                                          _convertContactModelToMap(
                                            contact,
                                          );

                                      return ContactItemWidget(
                                        contact: contactMap,
                                        contactModel: contact,
                                        onRename: (newName) {
                                          // Update the contact name
                                          final nameParts = splitFullName(
                                            newName,
                                          );
                                          final updatedContact = contact
                                              .copyWith(
                                                name: nameParts['name'],
                                                updatedAt: DateTime.now(),
                                              );
                                          _viewModel.updateContact(
                                            updatedContact,
                                          );
                                        },
                                        onDelete: () {
                                          // Deletar o contato
                                          final contactId =
                                              contact.ghlId ??
                                              contact.id?.toString() ??
                                              '';
                                          _viewModel.deleteContact(contactId);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                    // FAB posicionado manualmente
                    if (viewModel.hasContacts)
                      Positioned(
                        bottom: 120,
                        right: 16,
                        child: PaintProFAB(
                          onPressed: () => context.push('/new-contact'),
                          icon: Icons.add,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
