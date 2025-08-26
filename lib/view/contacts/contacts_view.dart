import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../model/contact_model.dart';
import '../../viewmodel/viewmodels.dart';
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
  late final ContactsViewModel _viewModel;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ContactsViewModel>();
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
      final query = _searchController.text.trim();
      _viewModel.searchQuery = query;
    });
  }

  Map<String, String> _convertContactModelToMap(ContactModel contact) {
    return {
      'name': '${contact.firstName ?? ''} ${contact.lastName ?? ''}'.trim(),
      'phone': contact.phone ?? '',
      'address':
          '${contact.address ?? ''}, ${contact.city ?? ''}, ${contact.country ?? ''}'
              .replaceAll(RegExp(r',\s*,'), ',')
              .replaceAll(RegExp(r'^,\s*|,\s*$'), ''),
    };
  }

  // Helper method to split full name into first and last name
  Map<String, String> _splitFullName(String fullName) {
    final trimmedName = fullName.trim();
    if (trimmedName.isEmpty) {
      return {'firstName': '', 'lastName': ''};
    }

    final parts = trimmedName.split(' ');
    if (parts.length == 1) {
      return {'firstName': parts[0], 'lastName': ''};
    }

    final firstName = parts.first;
    final lastName = parts.skip(1).join(' ');
    return {'firstName': firstName, 'lastName': lastName};
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: MainLayout(
        currentRoute: '/contacts',
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: const PaintProAppBar(
            title: 'Contacts',
            toolbarHeight: 90,
          ),
          body: Consumer<ContactsViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (viewModel.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.errorMessage ?? 'Erro desconhecido',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => viewModel.loadContacts(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  !viewModel.hasContacts
                      ? EmptyStateWidget(
                          title: 'No Contacts yet',
                          subtitle: 'Add your first contact to get started',
                          buttonText: 'Add Contact',
                          onButtonPressed: () => context.push('/new-contact'),
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
                                itemCount: viewModel.filteredContacts.length,
                                padding: const EdgeInsets.only(
                                  bottom: 140,
                                  left: 16,
                                  right: 16,
                                ),
                                itemBuilder: (context, index) {
                                  final contact =
                                      viewModel.filteredContacts[index];
                                  final contactMap = _convertContactModelToMap(
                                    contact,
                                  );

                                  return ContactItemWidget(
                                    contact: contactMap,
                                    onRename: (newName) {
                                      // Split the full name into first and last name
                                      final nameParts = _splitFullName(newName);
                                      final updatedContact = contact.copyWith(
                                        firstName: nameParts['firstName'],
                                        lastName: nameParts['lastName'],
                                        updatedAt: DateTime.now(),
                                      );
                                      _viewModel.updateContact(updatedContact);
                                    },
                                    onDelete: () {
                                      // Deletar o contato
                                      _viewModel.deleteContact(contact.id!);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                  // FAB posicionado manualmente
                  if (viewModel.hasContacts)
                    Positioned(
                      bottom:
                          140, // 120px do bottom navigation + 20px de margem
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
    );
  }
}
