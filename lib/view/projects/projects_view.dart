import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../viewmodel/navigation_viewmodel.dart';
import '../../viewmodel/projects/projects_viewmodel.dart';
import '../layout/main_layout.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/cards/project_card_widget.dart';
import '../../widgets/form_field/paint_pro_search_field.dart';

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
                return const Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                );
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
                        'Error',
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
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                );
              }

              if (!viewModel.hasProjects) {
                return RefreshIndicator(
                  onRefresh: () => viewModel.loadProjects(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: Center(
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
                              'No projects',
                              style: GoogleFonts.albertSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your projects will appear here',
                              style: GoogleFonts.albertSans(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Pull down to refresh',
                              style: GoogleFonts.albertSans(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                        onChanged: (value) => viewModel.searchQuery = value,
                        onClear: () => viewModel.clearSearch(),
                      ),
                    ),

                  // Projects list
                  if (viewModel.hasProjects)
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => viewModel.loadProjects(),
                        child: viewModel.hasFilteredProjects
                            ? ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                itemCount: viewModel.filteredProjects.length,
                                itemBuilder: (context, index) {
                                  final project =
                                      viewModel.filteredProjects[index];
                                  return ProjectCardWidget(
                                    id: project.id,
                                    projectName: project.projectName,
                                    personName: project.personName,
                                    zonesCount: project.zonesCount,
                                    createdDate: project.createdDate,
                                    image: project.image,
                                    onRename: (newName) {
                                      viewModel.renameProject(
                                        project.id.toString(),
                                        newName,
                                      );
                                    },
                                    onDelete: () {
                                      viewModel.deleteProject(
                                        project.id.toString(),
                                      );
                                    },
                                  );
                                },
                              )
                            : ListView(
                                children: [
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height -
                                        200,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.search_off,
                                            size: 64,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No projects found',
                                            style: GoogleFonts.albertSans(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Try a different search',
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
