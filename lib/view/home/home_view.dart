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
import '../../viewmodel/dashboard/dashboard_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/cards/greeting_card_widget.dart';
import '../../widgets/cards/project_state_card_widget.dart';
import '../../widgets/cards/project_card_widget.dart';
import '../../widgets/cards/stats_card_widget.dart';
import '../../widgets/drawer/paint_pro_drawer.dart';
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
  late final DashboardViewModel _dashboardViewModel;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _navigationViewModel = getIt<NavigationViewModel>();
    _userViewModel = getIt<UserViewModel>();
    _homeViewModel = getIt<HomeViewModel>();
    _dashboardViewModel = getIt<DashboardViewModel>();

    // Update the current route to home
    _navigationViewModel.updateCurrentRoute('/home');

    // Initialize home data
    _initializeHomeData();
  }

  Future<void> _initializeHomeData() async {
    await getIt<AuthInitializationService>().checkAuthAndFetchUser();
    // Load current month financial stats for better financial data display
    await _dashboardViewModel.loadCurrentMonthFinancialStats();
    // Load recent projects for home display
    await _homeViewModel.loadRecentProjects();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _userViewModel),
        ChangeNotifierProvider.value(value: _homeViewModel),
        ChangeNotifierProvider.value(value: _dashboardViewModel),
      ],
      child: MainLayout(
        currentRoute: '/home',
        drawer: PaintProDrawer(
          userViewModel: _userViewModel,
          homeViewModel: _homeViewModel,
        ),
        scaffoldKey: _scaffoldKey,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: PaintProAppBar(
            title: 'Home',
            toolbarHeight: 80,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: AppColors.textOnPrimary,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),
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
                      greeting: _homeViewModel.getDynamicGreeting(),
                      name: displayName,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    spacing: 8,
                    children: [
                      Consumer<DashboardViewModel>(
                        builder: (context, dashboardViewModel, child) {
                          if (dashboardViewModel.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (dashboardViewModel.hasError) {
                            return StatsCardWidget(
                              title: "Error",
                              description: "Failed to load stats",
                            );
                          }

                          final statistics = dashboardViewModel.statistics;
                          final currentMonth = dashboardViewModel.currentMonth;
                          final growth = dashboardViewModel.growth;

                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: StatsCardWidget(
                                      title:
                                          "${statistics?.totalEstimates ?? 0}",
                                      description: "total estimates",
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: StatsCardWidget(
                                      title: dashboardViewModel
                                          .getFormattedRevenue(
                                            currentMonth?.totalRevenue,
                                          ),
                                      description: "this month",
                                      backgroundColor: AppColors.primary
                                          .withValues(
                                            alpha: 0.15,
                                          ),
                                      titleColor: AppColors.textPrimary,
                                      descriptionColor: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: StatsCardWidget(
                                      title: dashboardViewModel
                                          .getFormattedRevenue(
                                            currentMonth?.averageEstimateValue,
                                          ),
                                      description: "avg estimate",
                                      backgroundColor: AppColors.primary
                                          .withValues(
                                            alpha: 0.15,
                                          ),
                                      titleColor: AppColors.textPrimary,
                                      descriptionColor: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: StatsCardWidget(
                                      title: dashboardViewModel
                                          .getFormattedPercentage(
                                            growth?.revenuePercentage,
                                          ),
                                      description: "growth value",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
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
                          if (homeViewModel.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (homeViewModel.hasError) {
                            return ProjectStateCardWidget(
                              title: "Error loading projects",
                              description: "Unable to load recent projects",
                              buttonText: "Retry",
                              state: ProjectStateType.error,
                              onButtonPressed: () => homeViewModel.refresh(),
                            );
                          }

                          if (!homeViewModel.hasProjects) {
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

                          return Column(
                            children: homeViewModel.recentProjects.map((
                              project,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ProjectCardWidget(
                                  id: project.id,
                                  projectName: project.projectName,
                                  personName: project.personName,
                                  zonesCount: project.zonesCount,
                                  createdDate: project.createdDate,
                                  image: project.image,
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
