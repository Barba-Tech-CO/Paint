import 'package:flutter/material.dart';

class ContactDetailsView extends StatelessWidget {
  const ContactDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Contato'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),
            Text('Sebastião'),
            Text('Marcos Ferreira'),
            Text('Masculino'),
            SizedBox(height: 32),
            Text("sebastiao_ferreira@live.com.br"),
            Text("(65) 99268-1400"),
            SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rua Seis"),
                Text("78055-865"),
              ],
            ),
            Text("Cuiabá"),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Mato Grosso"),
                Text("Brasil"),
              ],
            ),
            SizedBox(height: 24),
            Text("LocationId"),
            Text("Pietro e Caroline Ferragens Ltda"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar ação de edição ou outra funcionalidade
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
