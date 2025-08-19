import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

enum QuotesState { loading, empty, loaded, error }

class QuotesView extends StatefulWidget {
  const QuotesView({super.key});

  @override
  State<QuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends State<QuotesView> {
  QuotesState _currentState = QuotesState.empty;

  // Lista de exemplo para o estado loaded
  final List<String> _quotes = [
    'Quote 1: A vida é como pintar uma tela',
    'Quote 2: Cada cor tem sua importância',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(title: 'Quotes'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: _currentState == QuotesState.loading
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Carregando quotes...'),
                        ],
                      )
                    : _currentState == QuotesState.empty
                    ? Column(
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
                              setState(() {
                                _currentState = QuotesState.loading;
                              });
                              Future.delayed(Duration(seconds: 2), () {
                                setState(() {
                                  _currentState = QuotesState.loaded;
                                });
                              });
                            },
                          ),
                        ],
                      )
                    : _currentState == QuotesState.loaded
                    ? Column(
                        children: [
                          Text(
                            'Suas Quotes',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _quotes.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  title: Text(_quotes[index]),
                                  trailing: Icon(Icons.format_quote),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                          PaintProButton(
                            text: 'Adicionar Quote',
                            minimumSize: Size(130, 42),
                            borderRadius: 16,
                            onPressed: () {
                              // Ação para adicionar nova quote
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
                            'Erro ao carregar quotes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Verifique sua conexão e tente novamente',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 16),
                          PaintProButton(
                            text: 'Tentar Novamente',
                            minimumSize: Size(130, 42),
                            borderRadius: 16,
                            onPressed: () {
                              setState(() {
                                _currentState = QuotesState.loading;
                              });
                              Future.delayed(Duration(seconds: 1), () {
                                setState(() {
                                  _currentState = QuotesState.loaded;
                                });
                              });
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
