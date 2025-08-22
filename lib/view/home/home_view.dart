import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../service/auth_persistence_service.dart';
import '../../viewmodel/navigation_viewmodel.dart';
import '../../viewmodel/user/user_viewmodel.dart';
import '../widgets/appbars/paint_pro_app_bar.dart';
import '../widgets/cards/greeting_card_widget.dart';
import '../widgets/cards/project_state_card_widget.dart';
import '../widgets/cards/stats_card_widget.dart';
import '../widgets/navigation/floating_bottom_navigation_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final NavigationViewModel _navigationViewModel;
  late final UserViewModel _userViewModel;
  late final AuthPersistenceService _authPersistenceService;

  @override
  void initState() {
    super.initState();
    _navigationViewModel = getIt<NavigationViewModel>();
    _userViewModel = getIt<UserViewModel>();
    _authPersistenceService = getIt<AuthPersistenceService>();

    // Update the current route to home
    _navigationViewModel.updateCurrentRoute('/home');

    // Check for valid token before fetching user data
    _checkAuthAndFetchUser();
  }

  Future<void> _checkAuthAndFetchUser() async {
    // Check if we have a valid token
    final token = await _authPersistenceService.getSanctumToken();
    if (token != null) {
      // Token exists, fetch user data
      _userViewModel.fetchUser();
    } else {
      // No token, wait a bit and try again (in case OAuth just completed)
      await Future.delayed(const Duration(milliseconds: 1000));
      final retryToken = await _authPersistenceService.getSanctumToken();
      if (retryToken != null && mounted) {
        _userViewModel.fetchUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ListenableBuilder(
              listenable: _userViewModel,
              builder: (context, child) {
                return GreetingCardWidget(
                  greeting: "Good morning!",
                  name: _userViewModel.displayName,
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "See all",
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  ProjectStateCardWidget(
                    title: "No projects yet",
                    description: "Create your first project to get started",
                    buttonText: "Create project",
                    state: ProjectStateType.empty,
                    onButtonPressed: () => context.push('/create-project'),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 120,
            ), // espaço extra para não cobrir a barra
          ],
        ),
      ),
      bottomNavigationBar: FloatingBottomNavigationBar(
        viewModel: _navigationViewModel,
      ),
    );
  }
}
