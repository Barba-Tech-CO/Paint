import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      ),
      body: Column(
        children: [
          // Materials List (com busca incluída)
          Expanded(
            child: AnimatedBuilder(
              animation: _viewModel,
              builder: (context, _) {
                if (_viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (_viewModel.error != null) {
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
                          _viewModel.error!,
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _viewModel.refresh,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                return CustomScrollView(
                  slivers: [
                    // Search Header que rola junto
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 32,
                          right: 32,
                          top: 24,
                          bottom: 16,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.tune,
                                color: _viewModel.hasFilters
                                    ? AppColors.primary
                                    : Colors.grey,
                              ),
                              onPressed: _showFilterBottomSheet,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Lista de materiais
                    if (_viewModel.materials.isEmpty)
                      SliverFillRemaining(
                        child: Center(
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
                              if (_viewModel.hasFilters) ...[
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: _viewModel.clearFilters,
                                  child: const Text('Clear Filters'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final material = _viewModel.materials[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: MaterialCardWidget(
                                material: material,
                                isSelected: _viewModel.isMaterialSelected(
                                  material,
                                ),
                                onTap: () {
                                  if (_viewModel.isMaterialSelected(material)) {
                                    _viewModel.unselectMaterial(material);
                                  } else {
                                    _viewModel.selectMaterial(material);
                                  }
                                },
                              ),
                            );
                          },
                          childCount: _viewModel.materials.length,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Bottom Section
          Container(
            padding: const EdgeInsets.only(left: 32, right: 32, bottom: 16),
            child: AnimatedBuilder(
              animation: _viewModel,
              builder: (context, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_viewModel.selectedCount} Materials Selected',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    PaintProButton(
                      text: "Next",
                      onPressed: _viewModel.selectedCount == 0
                          ? null
                          : () => context.push('/overview-measurements'),
                    ),
                    // ElevatedButton(
                    //   onPressed: _viewModel.selectedCount == 0
                    //       ? null
                    //       : () => context.push('/overview-measurements'),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.grey[600],
                    //     foregroundColor: Colors.white,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 32,
                    //       vertical: 12,
                    //     ),
                    //   ),
                    //   child: const Text('Next'),
                    // ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
