import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/view/widgets/widgets.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';

class ContactDetailsView extends StatelessWidget {
  final Map<String, String>? contact;

  const ContactDetailsView({super.key, this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Usa os dados do contato passado como parâmetro
    final contactData = contact ?? {};
    
    // Dados padrão caso não sejam fornecidos
    final name = contactData['name'] ?? 'Nome não informado';
    final phone = contactData['phone'] ?? 'Telefone não informado';
    final address = contactData['address'] ?? 'Endereço não informado';

    return Scaffold(
      appBar: PaintProAppBar(
        title: 'Contacts Details',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome e informação de gênero
              Center(
                child: Column(
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.contact_phone,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Contato',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InfoCardWidget(
                children: [
                  InfoRowWidget(label: 'Telefone', value: phone),
                ],
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.home,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Endereço',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InfoCardWidget(
                children: [
                  InfoRowWidget(
                    label: 'Logradouro',
                    value: address,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // A ser implementado com o viewmodel para edição
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Funcionalidade de edição em breve'),
            ),
          );
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
    );
  }
}
