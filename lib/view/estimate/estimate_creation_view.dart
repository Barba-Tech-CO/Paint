import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/estimate_creation_viewmodel.dart';
import '../widgets/widgets.dart';

class EstimateCreationView extends StatefulWidget {
  const EstimateCreationView({super.key});

  @override
  State<EstimateCreationView> createState() => _EstimateCreationViewState();
}

class _EstimateCreationViewState extends State<EstimateCreationView> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _additionalNotesController = TextEditingController();
  final _contactIdController = TextEditingController();

  @override
  void dispose() {
    _projectNameController.dispose();
    _additionalNotesController.dispose();
    _contactIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EstimateCreationViewModel>(
      create: (_) => GetIt.instance<EstimateCreationViewModel>(),
      child: Scaffold(
        appBar: const PaintProAppBar(
          title: 'Criar Orçamento',
        ),
        body: Consumer<EstimateCreationViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: LoadingWidget(),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (viewModel.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.error!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Basic Information Section
                    _buildSectionTitle('Informações Básicas'),
                    const SizedBox(height: 16),

                    PaintProTextField(
                      controller: _contactIdController,
                      label: 'ID do Contato',
                      hintText: 'Digite o ID do contato',
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'ID do contato é obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    PaintProTextField(
                      controller: _projectNameController,
                      label: 'Nome do Projeto',
                      hintText: 'Digite o nome do projeto',
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Nome do projeto é obrigatório';
                        }
                        if (value!.trim().length < 3) {
                          return 'Nome deve ter pelo menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    PaintProTextField(
                      controller: _additionalNotesController,
                      label: 'Notas Adicionais (Opcional)',
                      hintText: 'Digite observações sobre o projeto',
                    ),
                    const SizedBox(height: 24),

                    // Zones Section
                    _buildSectionTitle('Zonas (${viewModel.zones.length})'),
                    const SizedBox(height: 8),
                    if (viewModel.zones.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.home_work_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Nenhuma zona adicionada',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...viewModel.zones.asMap().entries.map((entry) {
                        final index = entry.key;
                        final zone = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.room, color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      zone.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (zone.zoneType != null)
                                      Text(
                                        'Tipo: ${zone.zoneType!.name}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    Text(
                                      '${zone.photos.length} fotos',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => viewModel.removeZone(index),
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 16),

                    // Materials Section
                    _buildSectionTitle(
                      'Materiais (${viewModel.materials.length})',
                    ),
                    const SizedBox(height: 8),
                    if (viewModel.materials.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.build_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Nenhum material adicionado',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...viewModel.materials.asMap().entries.map((entry) {
                        final index = entry.key;
                        final material = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.build, color: Colors.green),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      material.name ?? material.id,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${material.quantity} ${material.unit}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'R\$ ${material.unitPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    viewModel.removeMaterial(index),
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 24),

                    // Totals Section
                    _buildSectionTitle('Totais'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Custo dos Materiais:'),
                              Text(
                                'R\$ ${viewModel.totals.materialsCost.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Geral:'),
                              Text(
                                'R\$ ${viewModel.totals.grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: PaintProButton(
                            text: 'Criar Orçamento',
                            onPressed: viewModel.isFormValid
                                ? () => _createEstimate(context, viewModel)
                                : null,
                            isLoading: viewModel.isLoading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Future<void> _createEstimate(
    BuildContext context,
    EstimateCreationViewModel viewModel,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    viewModel.setBasicInfo(
      contactId: _contactIdController.text.trim(),
      projectName: _projectNameController.text.trim(),
      additionalNotes: _additionalNotesController.text.trim(),
    );

    await viewModel.createEstimate();

    if (viewModel.createdEstimate != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Orçamento criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(viewModel.createdEstimate);
      }
    }
  }
}
