import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../model/contacts/contact_model.dart';
import '../dialogs/delete_quote_dialog.dart';

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
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 1.r,
              spreadRadius: 1.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            if (contactModel != null) {
              context.push('/contact-details', extra: contactModel);
            }
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: _getAvatarColor(name),
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      // Faz o conteúdo ocupar todo espaço restante
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phone,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            address,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 32.w,
                    ),
                  ],
                ),
              ),
              // IconButton posicionado absoluto
              Positioned(
                top: 8.h,
                right: 8.w,
                child: PopupMenuButton(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  tooltip: '',
                  icon: Icon(
                    Icons.more_vert,
                    size: 20.sp,
                    color: Colors.grey[700],
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      // Navegar para a tela de edição com os dados do contato
                      if (contactModel != null) {
                        context.push('/edit-contact', extra: contactModel);
                      }
                    } else if (value == 'delete') {
                      final confirm = await DeleteQuoteDialog.show(
                        context,
                        quoteName: name,
                      );
                      if (confirm == true) {
                        onDelete?.call();
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded),
                          SizedBox(width: 8.w),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded),
                          SizedBox(width: 8.w),
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
