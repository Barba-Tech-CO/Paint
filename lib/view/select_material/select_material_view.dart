import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:paintpro/view/widgets/widgets.dart';
import 'package:paintpro/viewmodel/material/material_list_viewmodel.dart';
import 'package:paintpro/service/material_service.dart';
import 'package:paintpro/config/app_colors.dart';
import 'widgets/material_card_widget.dart';
import 'widgets/material_filter_widget.dart';

class SelectMaterialView extends StatefulWidget {
  const SelectMaterialView({super.key});

  @override
  State<SelectMaterialView> createState() => _SelectMaterialViewState();
}

class _SelectMaterialViewState extends State<SelectMaterialView> {
  late MaterialListViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = MaterialListViewModel(MaterialService());
    _searchController.addListener(_onSearchChanged);

    // Inicializa os dados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initialize();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final searchTerm = _searchController.text;
    if (searchTerm.isEmpty) {
      _viewModel.clearFilters();
    } else {
      _viewModel.searchMaterials(searchTerm);
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => MaterialFilterWidget(
          currentFilter: _viewModel.currentFilter,
          availableBrands: _viewModel.availableBrands,
          onFilterChanged: (filter) {
            _viewModel.applyFilter(filter);
          },
          onClearFilters: () {
            _viewModel.clearFilters();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(
        title: 'Select Materials',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          Consumer<MaterialListViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.selectedCount > 0) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${viewModel.selectedCount} Selected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search materials...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter and Sort Row
                Row(
                  children: [
                    Expanded(
                      child: Consumer<MaterialListViewModel>(
                        builder: (context, viewModel, _) {
                          return OutlinedButton.icon(
                            onPressed: _showFilterBottomSheet,
                            icon: Icon(
                              Icons.filter_list,
                              color: viewModel.hasFilters
                                  ? AppColors.primary
                                  : Colors.grey[600],
                            ),
                            label: Text(
                              viewModel.hasFilters
                                  ? 'Filters Applied'
                                  : 'Filter by:',
                              style: TextStyle(
                                color: viewModel.hasFilters
                                    ? AppColors.primary
                                    : Colors.grey[600],
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: viewModel.hasFilters
                                    ? AppColors.primary
                                    : Colors.grey[300]!,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Clear Selection Button
                    Consumer<MaterialListViewModel>(
                      builder: (context, viewModel, _) {
                        if (viewModel.selectedCount > 0) {
                          return TextButton(
                            onPressed: viewModel.clearSelection,
                            child: const Text('Clear All'),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Materials List
          Expanded(
            child: Consumer<MaterialListViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (viewModel.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading materials',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          viewModel.error!,
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: viewModel.refresh,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.materials.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No materials found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                        if (viewModel.hasFilters) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: viewModel.clearFilters,
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: viewModel.refresh,
                  child: ListView.builder(
                    itemCount: viewModel.materials.length,
                    itemBuilder: (context, index) {
                      final material = viewModel.materials[index];
                      return MaterialCardWidget(
                        material: material,
                        isSelected: viewModel.isMaterialSelected(material),
                        onTap: () {
                          if (viewModel.isMaterialSelected(material)) {
                            viewModel.unselectMaterial(material);
                          } else {
                            viewModel.selectMaterial(material);
                          }
                        },
                        onLongPress: () {
                          // Implementar visualização de detalhes se necessário
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Bottom Action Bar
          Consumer<MaterialListViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.selectedCount == 0) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${viewModel.selectedCount} Materials Selected',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\$${viewModel.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PaintProButton(
                      text: 'Next',
                      onPressed: () {
                        // Navegar para próxima tela ou salvar seleção
                        context.push('/overview-measurements');
                      },
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                      borderRadius: 12,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
