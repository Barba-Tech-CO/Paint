import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/viewmodel/contact/contact_detail_viewmodel.dart';
import 'package:provider/provider.dart';

class ContactDetailsView extends StatelessWidget {
  const ContactDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ContactDetailViewModel>(
      builder: (context, viewModel, child) {
        final contact = viewModel.selectedContact;

        if (viewModel.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalhes do Contato')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (contact == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalhes do Contato')),
            body: const Center(child: Text('Contato não encontrado')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do Contato'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmation(context, viewModel);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar e nome
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: theme.primaryColor,
                          child: Text(
                            viewModel.initials,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          viewModel.fullName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Informações Pessoais
                  _buildSectionHeader(
                    theme,
                    'Informações Pessoais',
                    Icons.person,
                  ),
                  _buildInfoCard(
                    theme,
                    children: [
                      _buildInfoRow(theme, 'Nome', 'Sebastião'),
                      _buildInfoRow(theme, 'Sobrenome', 'Marcos Ferreira'),
                      _buildInfoRow(theme, 'Gênero', 'Masculino'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Contato
                  _buildSectionHeader(theme, 'Contato', Icons.contact_phone),
                  _buildInfoCard(
                    theme,
                    children: [
                      _buildInfoRow(
                        theme,
                        'Email',
                        'sebastiao_ferreira@live.com.br',
                      ),
                      _buildInfoRow(theme, 'Telefone', '(65) 99268-1400'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Endereço
                  _buildSectionHeader(theme, 'Endereço', Icons.home),
                  _buildInfoCard(
                    theme,
                    children: [
                      _buildInfoRow(theme, 'Logradouro', 'Rua Seis'),
                      _buildInfoRow(theme, 'CEP', '78055-865'),
                      _buildInfoRow(theme, 'Cidade', 'Cuiabá'),
                      _buildInfoRow(theme, 'Estado', 'Mato Grosso'),
                      _buildInfoRow(theme, 'País', 'Brasil'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Informações Adicionais
                  _buildSectionHeader(
                    theme,
                    'Informações Adicionais',
                    Icons.info,
                  ),
                  _buildInfoCard(
                    theme,
                    children: [
                      _buildInfoRow(theme, 'ID de Localização', 'LocationId'),
                      _buildInfoRow(
                        theme,
                        'Empresa',
                        'Pietro e Caroline Ferragens Ltda',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _navigateToEditContact(context, viewModel);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
          ),
        );
      },
    );
  }

  // Constrói o cabeçalho da seção
  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Constrói um card de informações
  Widget _buildInfoCard(ThemeData theme, {required List<Widget> children}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label + ':',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navega para a tela de edição
  void _navigateToEditContact(
    BuildContext context,
    ContactDetailViewModel viewModel,
  ) {
    // Implementar navegação para a tela de edição
    // Navigator.push(context, MaterialPageRoute(builder: (context) => EditContactView()));

    // Por enquanto, vamos apenas mostrar um snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de edição a ser implementada'),
      ),
    );
  }

  // Mostra diálogo de confirmação para exclusão
  void _showDeleteConfirmation(
    BuildContext context,
    ContactDetailViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Contato'),
        content: const Text('Tem certeza que deseja excluir este contato?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (viewModel.selectedContact != null &&
                  viewModel.selectedContact!.id != null) {
                final contactId = viewModel.selectedContact!.id;
                // Garantir que o ID não é nulo antes de chamar deleteContact
                if (contactId!.isNotEmpty) {
                  final success = await viewModel.deleteContact(contactId);
                  if (success) {
                    context.pop(); // Volta para a lista de contatos
                  }
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
