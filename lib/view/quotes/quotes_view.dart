import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/viewmodels.dart';
import '../layout/main_layout.dart';
import '../widgets/widgets.dart';
import 'widgets/widgets.dart';

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
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Column(
            children: [
              quotesViewModel.currentState == QuotesState.loaded
                  ? SearchBarWidget(controller: _searchController)
                  : SizedBox.shrink(),
              Expanded(
                child: quotesViewModel.currentState == QuotesState.loading
                    ? const LoadingWidget(message: 'Loading quotes...')
                    : quotesViewModel.currentState == QuotesState.empty
                    ? EmptyStateWidget(
                        title: 'No Quotes yet',
                        subtitle: 'Upload your first quote to get started',
                        buttonText: 'Upload Quote',
                        onButtonPressed: () => quotesViewModel.pickFile(),
                      )
                    : quotesViewModel.currentState == QuotesState.loaded
                    ? ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: quotesViewModel.quotes.length,
                        itemBuilder: (context, index) {
                          final quote = quotesViewModel.quotes[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: QuoteCardWidget(
                              id: quote.id,
                              titulo: quote.titulo,
                              dateUpload: quote.dateUpload,
                              onRename: (newName) {
                                quotesViewModel.renameQuote(quote.id, newName);
                              },
                              onDelete: () {
                                quotesViewModel.removeQuote(quote.id);
                              },
                            ),
                          );
                        },
                      )
                    : TryAgainWidget(
                        onPressed: () => quotesViewModel.clearError(),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: quotesViewModel.currentState != QuotesState.loaded
            ? null
            : PaintProFAB(
                onPressed: () => quotesViewModel.pickFile(),
              ),
      ),
    );
  }
}
