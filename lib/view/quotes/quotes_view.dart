import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/viewmodels.dart';
import '../widgets/widgets.dart';
import 'widgets/quote_card_widget.dart';

class QuotesView extends StatefulWidget {
  const QuotesView({super.key});

  @override
  State<QuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends State<QuotesView> {
  @override
  Widget build(BuildContext context) {
    final quotesViewModel = Provider.of<QuotesViewModel>(context);

    return Scaffold(
      appBar: PaintProAppBar(title: 'Quotes'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: quotesViewModel.currentState == QuotesState.loading
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading quotes...'),
                        ],
                      )
                    : quotesViewModel.currentState == QuotesState.empty
                    ? Consumer<QuotesViewModel>(
                        builder: (context, quotesViewModel, child) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                onPressed: () {
                                  quotesViewModel.pickFile();
                                },
                              ),
                            ],
                          );
                        },
                      )
                    : quotesViewModel.currentState == QuotesState.loaded
                    ? Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: quotesViewModel.quotes.length,
                            itemBuilder: (context, index) {
                              final quote = quotesViewModel.quotes[index];
                              return Align(
                                alignment: Alignment.center,
                                child: QuoteCardWidget(
                                  id: quote.id,
                                  titulo: quote.titulo,
                                  dateUpload: quote.dateUpload,
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error to load quotes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Check your connection and try again',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 16),
                          PaintProButton(
                            text: 'Try Again',
                            minimumSize: Size(130, 42),
                            borderRadius: 16,
                            onPressed: () {
                              quotesViewModel.clearError();
                            },
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
