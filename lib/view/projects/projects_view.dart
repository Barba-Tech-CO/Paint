import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../layout/main_layout.dart';
import '../../config/dependency_injection.dart';
import '../../viewmodel/viewmodels.dart';
import '../widgets/widgets.dart';

class ProjectsView extends StatefulWidget {
  const ProjectsView({super.key});

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  late final NavigationViewModel _navigationViewModel;
  late final ProjectsViewModel _projectsViewModel;

  @override
  void initState() {
    super.initState();
    _navigationViewModel = getIt<NavigationViewModel>();
    _projectsViewModel = getIt<ProjectsViewModel>();

    // Initialize the projects view model
    _projectsViewModel.initialize();

    // Update the current route to projects
    _navigationViewModel.updateCurrentRoute('/projects');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _projectsViewModel,
      child: MainLayout(
        currentRoute: '/projects',
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: const PaintProAppBar(title: 'Projects'),
          body: Consumer<ProjectsViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.hasError && viewModel.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro',
                        style: GoogleFonts.albertSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        viewModel.errorMessage!,
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => viewModel.loadProjects(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                );
              }

              if (!viewModel.hasProjects) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.folder_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum projeto',
                        style: GoogleFonts.albertSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seus projetos aparecerão aqui',
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show projects list
              return Column(
                children: [
                  // Search bar
                  if (viewModel.hasProjects)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PaintProSearchField(
                        hintText: 'Search projects',
                        onChanged: (value) =>
                            viewModel.updateSearchQuery(value),
                      ),
                    ),

                  // Projects count
                  if (viewModel.hasProjects)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text(
                            viewModel.isSearching
                                ? '${viewModel.filteredProjectsCount} de ${viewModel.projectsCount} projetos'
                                : '${viewModel.projectsCount} projetos',
                            style: GoogleFonts.albertSans(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Projects list
                  Expanded(
                    child: viewModel.hasFilteredProjects
                        ? ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            itemCount: viewModel.filteredProjects.length,
                            itemBuilder: (context, index) {
                              final project = viewModel.filteredProjects[index];
                              return ZonesCard(
                                title: project.title,
                                image: project.image,
                                valueDimension: project.floorAreaValue,
                                valueArea: project.areaPaintable,
                                valuePaintable: project.areaPaintable,
                              );
                            },
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhum projeto encontrado',
                                  style: GoogleFonts.albertSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tente uma busca diferente',
                                  style: GoogleFonts.albertSans(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
