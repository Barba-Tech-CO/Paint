import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../viewmodel/viewmodels.dart';
import '../widgets/widgets.dart';
import 'widgets/quote_card_widget.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/try_again_widget.dart';

class QuotesView extends StatefulWidget {
  const QuotesView({super.key});

  @override
  State<QuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends State<QuotesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotesViewModel = Provider.of<QuotesViewModel>(context);

    return Scaffold(
      appBar: PaintProAppBar(title: 'Quotes'),
      body: Column(
        children: [
          // Barra de pesquisa
          quotesViewModel.currentState == QuotesState.loaded
              ? SearchBarWidget(controller: _searchController)
              : SizedBox.shrink(),
          // Lista de quotes
          Expanded(
            child: quotesViewModel.currentState == QuotesState.loading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading quotes...'),
                      ],
                    ),
                  )
                : quotesViewModel.currentState == QuotesState.empty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No Quotes yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Upload your first quote to get started',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 16),
                        PaintProButton(
                          text: 'Upload Quote',
                          minimumSize: Size(130, 42),
                          borderRadius: 16,
                          onPressed: () => quotesViewModel.pickFile(),
                        ),
                      ],
                    ),
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
      floatingActionButton: quotesViewModel.currentState == QuotesState.loaded
          ? FloatingActionButton(
              onPressed: () => quotesViewModel.pickFile(),
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.add,
                color: AppColors.cardDefault,
                size: 40,
              ),
            )
          : null,
    );
  }
}
