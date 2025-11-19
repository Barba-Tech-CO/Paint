import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        DropdownButtonFormField2<ContactModel?>(
          isExpanded: true,
          value: widget.selectedContact,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 16.h,
            ),
            errorText: widget.errorText,
          ),
          hint: widget.isLoading
              ? Row(
                  children: [
                    SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(strokeWidth: 2.w),
                    ),
                    SizedBox(width: 8.w),
                    const Text('Loading contacts...'),
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
                    style: TextStyle(
                      fontSize: 14.sp,
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
            maxHeight: 300.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
            ),
            offset: Offset(0, -5.h),
            direction: DropdownDirection.textDirection,
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
          ),
          dropdownSearchData: DropdownSearchData(
            searchController: _searchController,
            searchInnerWidgetHeight: 50.h,
            searchInnerWidget: Container(
              height: 50.h,
              padding: EdgeInsets.only(
                top: 8.h,
                bottom: 4.h,
                right: 8.w,
                left: 8.w,
              ),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  hintText: 'Search contact...',
                  hintStyle: TextStyle(fontSize: 14.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  prefixIcon: Icon(Icons.search, size: 20.sp),
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
            padding: EdgeInsets.only(top: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.onRetry,
                  icon: Icon(Icons.refresh, size: 16.sp),
                  label: const Text('Retry'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    minimumSize: Size(0, 32.h),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
