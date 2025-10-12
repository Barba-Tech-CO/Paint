import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../config/app_colors.dart';
import '../../model/contacts/contact_model.dart';

class ContactDropdownWidget extends StatefulWidget {
  final ContactModel? selectedContact;
  final List<ContactModel> contacts;
  final ValueChanged<ContactModel?> onChanged;
  final String? label;
  final bool isLoading;
  final String? errorText;
  final VoidCallback? onRetry;

  const ContactDropdownWidget({
    super.key,
    this.selectedContact,
    required this.contacts,
    required this.onChanged,
    this.label,
    this.isLoading = false,
    this.errorText,
    this.onRetry,
  });

  @override
  State<ContactDropdownWidget> createState() => _ContactDropdownWidgetState();
}

class _ContactDropdownWidgetState extends State<ContactDropdownWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField2<ContactModel?>(
          isExpanded: true,
          value: widget.selectedContact,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            errorText: widget.errorText,
          ),
          hint: widget.isLoading
              ? const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Loading contacts...'),
                  ],
                )
              : Text(
                  widget.label != null
                      ? 'Select ${widget.label}'
                      : 'Select contact',
                ),
          items: widget.contacts
              .where((contact) => contact.name.trim().isNotEmpty)
              .map((contact) {
                return DropdownMenuItem<ContactModel?>(
                  value: contact,
                  child: Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              })
              .toList(),
          onChanged: widget.isLoading ? null : widget.onChanged,
          dropdownStyleData: DropdownStyleData(
            maxHeight: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            offset: const Offset(0, -5),
            direction: DropdownDirection.textDirection,
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          dropdownSearchData: DropdownSearchData(
            searchController: _searchController,
            searchInnerWidgetHeight: 50,
            searchInnerWidget: Container(
              height: 50,
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 4,
                right: 8,
                left: 8,
              ),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  hintText: 'Search contact...',
                  hintStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.search, size: 20),
                ),
              ),
            ),
            searchMatchFn: (item, searchValue) {
              final contact = item.value;
              if (contact == null) return false;
              return contact.name.toLowerCase().contains(
                searchValue.toLowerCase(),
              );
            },
          ),
        ),
        if (widget.errorText != null && widget.onRetry != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
