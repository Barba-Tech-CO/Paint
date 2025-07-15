import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/config/app_colors.dart';

class ContactItemWidget extends StatelessWidget {
  final Map<String, String> contact;
  final Color avatarColor;
  final VoidCallback? onMorePressed;

  const ContactItemWidget({
    super.key,
    required this.contact,
    required this.avatarColor,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final name = contact['name'] ?? '';
    final phone = contact['phone'] ?? '';
    final address = contact['address'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: avatarColor,
          radius: 24,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (phone.isNotEmpty)
              Text(
                phone,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (address.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed:
              onMorePressed ??
              () {
                // Menu de opções padrão
              },
        ),
        onTap: () => context.push('/contact-details', extra: contact),
      ),
    );
  }
}
