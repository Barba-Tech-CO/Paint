import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../config/app_colors.dart';
import '../../../../view/widgets/appbars/paint_pro_app_bar.dart';
import '../../../../view/widgets/cards/greeting_card_widget.dart';
import '../../../../view/widgets/cards/project_state_card_widget.dart';
import '../../../../view/widgets/cards/stats_card_widget.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../domain/entities/home_state.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewmodel>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaintProAppBar(
        title: 'Home',
        toolbarHeight: 126,
      ),
      body: Consumer<HomeViewmodel>(
        builder: (context, viewModel, child) {
          final state = viewModel.state;

          switch (state.viewState) {
            case HomeViewState.loading:
              return const Center(child: CircularProgressIndicator());
              
            case HomeViewState.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading home data',
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? 'Unknown error',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
              
            case HomeViewState.loaded:
              return RefreshIndicator(
                onRefresh: viewModel.refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 32,
                    children: [
                      const SizedBox(height: 8),
                      
                      if (state.userGreeting != null)
                        GreetingCardWidget(
                          greeting: state.userGreeting!.greeting,
                          name: state.userGreeting!.userName,
                        ),
                      
                      if (state.stats != null)
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
                                      title: state.stats!.activeProjects.toString(),
                                      description: "active projects",
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: StatsCardWidget(
                                      title: state.stats!.monthlyRevenue,
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
                                      title: state.stats!.completedProjects.toString(),
                                      description: "completed",
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: StatsCardWidget(
                                      title: state.stats!.conversionRate,
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
                            const SizedBox(height: 32),
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
                      
                      const SizedBox(height: 120), // espaço extra para não cobrir a barra
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}