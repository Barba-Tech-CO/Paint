import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../service/auth_initialization_service.dart';
import '../../viewmodel/navigation_viewmodel.dart';
import '../../viewmodel/user/user_viewmodel.dart';
import '../../viewmodel/home/home_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/cards/greeting_card_widget.dart';
import '../../widgets/cards/project_state_card_widget.dart';
import '../../widgets/cards/project_card_widget.dart';
import '../../widgets/cards/stats_card_widget.dart';
import '../layout/main_layout.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final NavigationViewModel _navigationViewModel;
  late final UserViewModel _userViewModel;
  late final HomeViewModel _homeViewModel;

  @override
  void initState() {
    super.initState();
    log('[HOME_VIEW] Initializing HomeView...');

    _navigationViewModel = getIt<NavigationViewModel>();
    _userViewModel = getIt<UserViewModel>();
    _homeViewModel = getIt<HomeViewModel>();

    log('[HOME_VIEW] ViewModels initialized');

    // Update the current route to home
    _navigationViewModel.updateCurrentRoute('/home');

    // Initialize home data
    _initializeHomeData();
  }

  Future<void> _initializeHomeData() async {
    try {
      log('[HOME_VIEW] Starting home data initialization...');

      // Initialize user data
      log('[HOME_VIEW] Checking auth and fetching user...');
      await getIt<AuthInitializationService>().checkAuthAndFetchUser();
      log('[HOME_VIEW] User data initialized');

      // Initialize recent projects
      log('[HOME_VIEW] Initializing home view model...');
      await _homeViewModel.initialize();
      log('[HOME_VIEW] Home data initialization completed');
    } catch (e) {
      log('[HOME_VIEW] Error initializing home data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _userViewModel),
        ChangeNotifierProvider.value(value: _homeViewModel),
      ],
      child: MainLayout(
        currentRoute: '/home',
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: PaintProAppBar(
            title: 'Home',
            toolbarHeight: 80,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 32,
              children: [
                SizedBox(
                  height: 8,
                ),
                Consumer<UserViewModel>(
                  builder: (context, userViewModel, child) {
                    // Show loading state or actual name
                    String displayName;
                    if (userViewModel.isLoading) {
                      displayName = 'Loading...';
                    } else if (userViewModel.displayName.isNotEmpty) {
                      displayName = userViewModel.displayName;
                    } else {
                      displayName = 'User';
                    }

                    return GreetingCardWidget(
                      greeting: "Good morning!",
                      name: displayName,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    spacing: 8,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: StatsCardWidget(
                              title: "2",
                              description: "active projects",
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: StatsCardWidget(
                              title: "\$30,050",
                              description: "this month",
                              backgroundColor: AppColors.cardDark,
                              titleColor: AppColors.success,
                              descriptionColor: AppColors.textOnDark,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: StatsCardWidget(
                              title: "6",
                              description: "completed",
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: StatsCardWidget(
                              title: "85%",
                              description: "conversion",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Projects",
                            style: GoogleFonts.albertSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/projects'),
                            child: Text(
                              "See all",
                              style: GoogleFonts.albertSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Consumer<HomeViewModel>(
                        builder: (context, homeViewModel, child) {
                          log(
                            '[HOME_VIEW] Building Consumer - State: ${homeViewModel.state}',
                          );
                          log(
                            '[HOME_VIEW] IsLoading: ${homeViewModel.isLoading}',
                          );
                          log(
                            '[HOME_VIEW] HasError: ${homeViewModel.hasError}',
                          );
                          log(
                            '[HOME_VIEW] HasProjects: ${homeViewModel.hasProjects}',
                          );
                          log(
                            '[HOME_VIEW] Projects count: ${homeViewModel.recentProjects.length}',
                          );

                          if (homeViewModel.isLoading) {
                            log('[HOME_VIEW] Showing loading state');
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (homeViewModel.hasError) {
                            log('[HOME_VIEW] Showing error state');
                            return ProjectStateCardWidget(
                              title: "Error loading projects",
                              description: "Unable to load recent projects",
                              buttonText: "Retry",
                              state: ProjectStateType.error,
                              onButtonPressed: () => homeViewModel.refresh(),
                            );
                          }

                          if (!homeViewModel.hasProjects) {
                            log('[HOME_VIEW] Showing empty state');
                            return ProjectStateCardWidget(
                              title: "No projects yet",
                              description:
                                  "Create your first project to get started",
                              buttonText: "Create project",
                              state: ProjectStateType.empty,
                              onButtonPressed: () =>
                                  context.push('/create-project'),
                            );
                          }

                          log(
                            '[HOME_VIEW] Showing projects list with ${homeViewModel.recentProjects.length} projects',
                          );
                          return Column(
                            children: homeViewModel.recentProjects.map((
                              project,
                            ) {
                              log(
                                '[HOME_VIEW] Rendering project: ${project.projectName} - ${project.personName}',
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ProjectCardWidget(
                                  projectName: project.projectName,
                                  personName: project.personName,
                                  zonesCount: project.zonesCount,
                                  createdDate: project.createdDate,
                                  image: project.image,
                                  onTap: () {
                                    // Navigate to project details or zones
                                    context.push(
                                      '/zones-details',
                                      extra: project,
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
