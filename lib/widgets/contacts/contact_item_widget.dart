import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../model/contacts/contact_model.dart';
import '../dialogs/delete_dialog_widget.dart';

class ContactItemWidget extends StatelessWidget {
  final Map<String, String> contact;
  final VoidCallback? onMorePressed;
  final Function(String)? onRename;
  final VoidCallback? onDelete;
  final ContactModel? contactModel;

  const ContactItemWidget({
    super.key,
    required this.contact,
    this.onMorePressed,
    this.onRename,
    this.onDelete,
    this.contactModel,
  });

  @override
  Widget build(BuildContext context) {
    final name = contact['name'] ?? '';
    final phone = contact['phone'] ?? '';
    final address = contact['address'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 1,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            if (contactModel != null) {
              context.push('/contact-details', extra: contactModel);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: _getAvatarColor(name),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      // Faz o conteúdo ocupar todo espaço restante
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phone,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            address,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 32,
                    ),
                  ],
                ),
              ),
              // IconButton posicionado absoluto
              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  icon: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Colors.grey[700],
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      // Navegar para a tela de edição com os dados do contato
                      if (contactModel != null) {
                        context.push('/edit-contact', extra: contactModel);
                      }
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => DeleteDialog(
                          quoteName: name,
                        ),
                      );
                      if (confirm == true) {
                        onDelete?.call();
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded),
                          SizedBox(width: 8),
                          Text('Excluir'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    // Lista de cores para os avatares baseada no primeiro caractere do nome
    final colors = [
      const Color(0xFFFF9800), // Laranja
      const Color(0xFF9C27B0), // Roxo
      const Color(0xFF4CAF50), // Verde
      const Color(0xFFE91E63), // Rosa
      const Color(0xFF2196F3), // Azul
      const Color(0xFFFF5722), // Vermelho-laranja
      const Color(0xFF795548), // Marrom
      const Color(0xFF607D8B), // Azul-acinzentado
    ];

    final index = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;
    return colors[index];
  }
}
