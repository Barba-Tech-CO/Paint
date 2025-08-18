import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../view/layout/main_layout.dart';
import '../../../../view/widgets/appbars/paint_pro_app_bar.dart';
import '../viewmodels/highlights_viewmodel.dart';
import '../../domain/entities/highlights_state.dart';

class HighlightsView extends StatefulWidget {
  const HighlightsView({super.key});

  @override
  State<HighlightsView> createState() => _HighlightsViewState();
}

class _HighlightsViewState extends State<HighlightsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HighlightsViewmodel>().loadHighlights();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/highlights',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const PaintProAppBar(title: 'Go High Level'),
        body: Consumer<HighlightsViewmodel>(
          builder: (context, viewModel, child) {
            final state = viewModel.state;

            switch (state.viewState) {
              case HighlightsViewState.loading:
                return const Center(child: CircularProgressIndicator());
                
              case HighlightsViewState.error:
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
                        'Error loading highlights',
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
                
              case HighlightsViewState.empty:
                return RefreshIndicator(
                  onRefresh: viewModel.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              size: 64,
                              color: AppColors.warning,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No highlights yet',
                              style: GoogleFonts.albertSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your highlights will appear here',
                              style: GoogleFonts.albertSans(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                
              case HighlightsViewState.loaded:
                return RefreshIndicator(
                  onRefresh: viewModel.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.highlights.length,
                    itemBuilder: (context, index) {
                      final highlight = state.highlights[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: highlight.isPriority 
                                ? AppColors.warning.withValues(alpha: 0.2)
                                : AppColors.primary.withValues(alpha: 0.2),
                            child: Icon(
                              highlight.isPriority 
                                  ? Icons.priority_high 
                                  : Icons.lightbulb_outline,
                              color: highlight.isPriority 
                                  ? AppColors.warning 
                                  : AppColors.primary,
                            ),
                          ),
                          title: Text(
                            highlight.title,
                            style: GoogleFonts.albertSans(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(highlight.description),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      highlight.category,
                                      style: GoogleFonts.albertSans(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatDate(highlight.createdAt),
                                    style: GoogleFonts.albertSans(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: highlight.actionUrl != null 
                              ? const Icon(Icons.arrow_forward_ios)
                              : null,
                          onTap: highlight.actionUrl != null 
                              ? () {
                                  // TODO: Navigate to action URL
                                }
                              : null,
                        ),
                      );
                    },
                  ),
                );
            }
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}