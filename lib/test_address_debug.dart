import 'core/models/user_model.dart';
import 'utils/logger.dart';

void main() {
  // Teste 1: Endereço correto
  AppLogger.info('=== TESTE 1: Endereço correto ===');
  final address1 = AddressModel(
    street: 'Avenida Dom José Newton de Almeida Batista',
    number: 0,
    complement: null,
    neighborhood: 'Santo Hilário',
    city: 'Goiânia',
    state: 'GO',
    zipCode: '74780-170',
  );
  AppLogger.info('Endereço 1 - fullAddress: ${address1.fullAddress}');
  AppLogger.info('Endereço 1 - street: ${address1.street}');
  AppLogger.info('Endereço 1 - city: ${address1.city}');
  AppLogger.info('Endereço 1 - state: ${address1.state}');

  // Teste 2: Endereço problemático
  AppLogger.info('\n=== TESTE 2: Endereço problemático ===');
  final address2 = AddressModel(
    street: 'Endereço não informado',
    number: 0,
    complement: null,
    neighborhood: '',
    city: '',
    state: '',
    zipCode: '',
  );
  AppLogger.info('Endereço 2 - fullAddress: ${address2.fullAddress}');
  AppLogger.info('Endereço 2 - street: ${address2.street}');
  AppLogger.info('Endereço 2 - city: ${address2.city}');
  AppLogger.info('Endereço 2 - state: ${address2.state}');

  // Teste 3: Endereço parcial
  AppLogger.info('\n=== TESTE 3: Endereço parcial ===');
  final address3 = AddressModel(
    street: 'Rua das Flores',
    number: 123,
    complement: null,
    neighborhood: 'Centro',
    city: 'São Paulo',
    state: 'SP',
    zipCode: '01234-567',
  );
  AppLogger.info('Endereço 3 - fullAddress: ${address3.fullAddress}');
  AppLogger.info('Endereço 3 - street: ${address3.street}');
  AppLogger.info('Endereço 3 - city: ${address3.city}');
  AppLogger.info('Endereço 3 - state: ${address3.state}');

  // Teste 4: Endereço com campos vazios
  AppLogger.info('\n=== TESTE 4: Endereço com campos vazios ===');
  final address4 = AddressModel(
    street: 'Rua das Flores',
    number: 0,
    complement: null,
    neighborhood: '',
    city: 'São Paulo',
    state: 'SP',
    zipCode: '',
  );
  AppLogger.info('Endereço 4 - fullAddress: ${address4.fullAddress}');
  AppLogger.info('Endereço 4 - street: ${address4.street}');
  AppLogger.info('Endereço 4 - city: ${address4.city}');
  AppLogger.info('Endereço 4 - state: ${address4.state}');
}
