import 'package:flutter/material.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/appbars/app_bar_widget.dart';

class ContactDetailsView extends StatelessWidget {
  const ContactDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dados mockados - serão substituídos pelo viewmodel posteriormente
    const contactData = {
      'name': 'Sebastião Marcos Ferreira',
      'gender': 'Masculino',
      'email': 'sebastiao_ferreira@live.com.br',
      'phone': '(65) 99268-1400',
      'address': 'Rua Seis',
      'zipCode': '78055-865',
      'city': 'Cuiabá',
      'state': 'Mato Grosso',
      'country': 'Brasil',
      'locationId': 'LocationId',
      'company': 'Pietro e Caroline Ferragens Ltda',
    };

    return Scaffold(
      appBar: AppBarWidget(title: 'Contacts Details'),
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
                      contactData['name']!,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (contactData['gender'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          contactData['gender']!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
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
              _buildInfoCard(
                theme,
                children: [
                  _buildInfoRow(theme, 'Email', contactData['email']),
                  _buildInfoRow(theme, 'Telefone', contactData['phone']),
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
              _buildInfoCard(
                theme,
                children: [
                  _buildInfoRow(theme, 'Logradouro', contactData['address']),
                  _buildInfoRow(theme, 'CEP', contactData['zipCode']),
                  _buildInfoRow(theme, 'Cidade', contactData['city']),
                  _buildInfoRow(theme, 'Estado', contactData['state']),
                  _buildInfoRow(theme, 'País', contactData['country']),
                ],
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.business,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Informações Adicionais',
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
              _buildInfoCard(
                theme,
                children: [
                  _buildInfoRow(
                    theme,
                    'ID de Localização',
                    contactData['locationId'],
                  ),
                  _buildInfoRow(theme, 'Empresa', contactData['company']),
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

  // Constrói o cabeçalho da seção

  // Constrói um card de informações
  Widget _buildInfoCard(ThemeData theme, {required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  // Constrói uma linha de informação
  Widget _buildInfoRow(ThemeData theme, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
