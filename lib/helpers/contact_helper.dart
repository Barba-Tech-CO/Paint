import '../../model/contacts/contact_model.dart';
import '../../service/contact_database_service.dart';
import '../../service/contact_service.dart';
import '../../utils/result/result.dart';

class ContactHelper {
  /// Carrega contatos do banco local e API
  static Future<List<ContactModel>> loadContacts({
    required ContactService contactService,
    required ContactDatabaseService contactDatabaseService,
  }) async {
    try {
      // Primeiro tenta carregar do banco local
      final localContacts = await contactDatabaseService.getAllContacts();

      if (localContacts.isNotEmpty) {
        // Depois tenta sincronizar com a API
        final result = await contactService.getContacts();

        if (result is Ok) {
          final apiContacts = result.asOk.value.contacts;

          // Salva os contatos no banco local para uso offline
          for (final contact in apiContacts) {
            await contactDatabaseService.insertContact(contact);
          }

          return apiContacts;
        } else {
          // Se a API falhar, usa os contatos locais se existirem
          return localContacts;
        }
      } else {
        // Se não há contatos locais, tenta carregar da API
        final result = await contactService.getContacts();

        if (result is Ok) {
          final apiContacts = result.asOk.value.contacts;

          // Salva os contatos no banco local para uso offline
          for (final contact in apiContacts) {
            await contactDatabaseService.insertContact(contact);
          }

          return apiContacts;
        } else {
          // Se a API falhar, retorna contatos mock
          return _getMockContacts();
        }
      }
    } catch (e) {
      // Se houver qualquer erro, retorna contatos mock
      return _getMockContacts();
    }
  }

  /// Retorna contatos mock para teste
  static List<ContactModel> _getMockContacts() {
    return [
      ContactModel(
        ghlId: 'mock_1',
        locationId: 'mock_location',
        name: 'João Silva',
        email: 'joao.silva@email.com',
        phone: '(11) 99999-1111',
        address: 'Rua das Flores, 123',
        city: 'São Paulo',
        state: 'SP',
        postalCode: '01234-567',
        country: 'Brasil',
        companyName: 'Silva Construções LTDA',
      ),
      ContactModel(
        ghlId: 'mock_2',
        locationId: 'mock_location',
        name: 'Maria Santos',
        email: 'maria.santos@email.com',
        phone: '(11) 99999-2222',
        address: 'Av. Paulista, 456',
        city: 'São Paulo',
        state: 'SP',
        postalCode: '01310-100',
        country: 'Brasil',
        companyName: 'Santos & Associados',
      ),
      ContactModel(
        ghlId: 'mock_3',
        locationId: 'mock_location',
        name: 'Pedro Oliveira',
        email: 'pedro.oliveira@email.com',
        phone: '(11) 99999-3333',
        address: 'Rua Augusta, 789',
        city: 'São Paulo',
        state: 'SP',
        postalCode: '01305-000',
        country: 'Brasil',
        companyName: 'Oliveira Imóveis',
      ),
      ContactModel(
        ghlId: 'mock_4',
        locationId: 'mock_location',
        name: 'Ana Costa',
        email: 'ana.costa@email.com',
        phone: '(11) 99999-4444',
        address: 'Rua Oscar Freire, 321',
        city: 'São Paulo',
        state: 'SP',
        postalCode: '01426-001',
        country: 'Brasil',
        companyName: 'Costa Design Studio',
      ),
      ContactModel(
        ghlId: 'mock_5',
        locationId: 'mock_location',
        name: 'Carlos Ferreira',
        email: 'carlos.ferreira@email.com',
        phone: '(11) 99999-5555',
        address: 'Rua Haddock Lobo, 654',
        city: 'São Paulo',
        state: 'SP',
        postalCode: '01414-000',
        country: 'Brasil',
        companyName: 'Ferreira Consultoria',
      ),
      ContactModel(
        ghlId: 'mock_6',
        locationId: 'mock_location',
        name: 'Lucia Rodrigues',
        email: 'lucia.rodrigues@email.com',
        phone: '(11) 99999-6666',
        address: 'Av. Faria Lima, 987',
        city: 'São Paulo',
        state: 'SP',
        postalCode: '04538-132',
        country: 'Brasil',
        companyName: 'Rodrigues Arquitetura',
      ),
    ];
  }
}
