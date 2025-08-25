import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContactItemWidget extends StatelessWidget {
  final Map<String, String> contact;
  final VoidCallback? onMorePressed;

  const ContactItemWidget({
    super.key,
    required this.contact,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final name = contact['name'] ?? '';
    final phone = contact['phone'] ?? '';
    final address = contact['address'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      width: double.infinity, // Ocupa toda a largura disponível
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        onTap: () => context.push('/contact-details', extra: contact),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
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
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: onMorePressed ?? () {},
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
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
