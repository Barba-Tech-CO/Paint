import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/quotes/quotes_viewmodel.dart';
import '../layout/main_layout.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_fab.dart';
import '../../widgets/states/empty_state_widget.dart';
import '../../widgets/states/loading_widget.dart';
import '../../widgets/quotes/quote_card_widget.dart';
import '../../widgets/quotes/search_bar_widget.dart';
import '../../widgets/quotes/try_again_widget.dart';

class QuotesView extends StatefulWidget {
  const QuotesView({super.key});

  @override
  State<QuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends State<QuotesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final quotesViewModel = Provider.of<QuotesViewModel>(
      context,
      listen: false,
    );
    quotesViewModel.searchQuotes(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotesViewModel = Provider.of<QuotesViewModel>(context);

    return MainLayout(
      currentRoute: '/quotes',
      child: Scaffold(
        appBar: PaintProAppBar(title: 'Quotes'),
        body: Padding(
          padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
          child: Column(
            children: [
              quotesViewModel.currentState == QuotesState.loaded
                  ? SearchBarWidget(controller: _searchController)
                  : const SizedBox.shrink(),
              if (quotesViewModel.isUploading)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[600]!,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Uploading PDF... Please wait',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    quotesViewModel.currentState == QuotesState.loading
                        ? const LoadingWidget(
                            message: 'Loading quotes...',
                          )
                        : quotesViewModel.currentState == QuotesState.empty
                        ? EmptyStateWidget(
                            title: 'No Quotes yet',
                            subtitle: 'Upload your first quote to get started',
                            buttonText: 'Upload Quote',
                            onButtonPressed: () => quotesViewModel.pickFile(),
                          )
                        : quotesViewModel.currentState == QuotesState.loaded
                        ? RefreshIndicator(
                            onRefresh: () async {
                              await quotesViewModel.refresh();
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                bottom: 140.h,
                                left: 16.w,
                                right: 16.w,
                              ),
                              itemCount: quotesViewModel.quotes.length,
                              itemBuilder: (context, index) {
                                final quote = quotesViewModel.quotes[index];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: QuoteCardWidget(
                                    id: quote.id,
                                    titulo: quote.titulo,
                                    dateUpload: quote.dateUpload,
                                    status: quote.status?.value,
                                    errorMessage: quote.errorMessage,
                                    isDeleting: quotesViewModel
                                        .isQuoteBeingDeleted(
                                          quote.id,
                                        ), // Use specific quote state
                                    onRename: (newName) {
                                      quotesViewModel.renameQuote(
                                        quote.id,
                                        newName,
                                      );
                                    },
                                    onDelete: () {
                                      quotesViewModel.removeQuote(quote.id);
                                    },
                                  ),
                                );
                              },
                            ),
                          )
                        : TryAgainWidget(
                            onPressed: () => quotesViewModel.clearError(),
                          ),
                    // FAB posicionado manualmente
                    if (quotesViewModel.currentState == QuotesState.loaded)
                      Positioned(
                        bottom: 120.h,
                        right: 16.w,
                        child: PaintProFAB(
                          onPressed: () => quotesViewModel.pickFile(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
