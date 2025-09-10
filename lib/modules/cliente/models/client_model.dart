import '../../../core/models/user_model.dart';

class ClientModel extends UserModel {
  final String? cpf;

  final bool ativo;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  ClientModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.isSeller,
    super.isEntregador,
    this.cpf,
    required this.ativo,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    // Criar AddressModel a partir dos dados do backend
    final addressData = json['endereco'] ?? json['address'] ?? {};
    final address = AddressModel(
      street: addressData['rua'] ?? addressData['street'] ?? '',
      number: addressData['numero'] is int
          ? addressData['numero']
          : int.tryParse(addressData['numero']?.toString() ?? '0') ?? 0,
      complement: addressData['complemento'] ?? addressData['complement'],
      neighborhood: addressData['bairro'] ?? addressData['neighborhood'] ?? '',
      city: addressData['cidade'] ?? addressData['city'] ?? '',
      state: addressData['estado'] ?? addressData['state'] ?? '',
      zipCode: addressData['cep'] ?? addressData['zipCode'] ?? '',
    );

    return ClientModel(
      id: json['id']?.toString() ?? '',
      name: json['nome'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['telefone'] ?? json['phone'] ?? '',
      address: address,
      latitude: (json['latitude'] is int)
          ? (json['latitude'] as int).toDouble()
          : (json['latitude'] as double? ?? 0.0),
      longitude: (json['longitude'] is int)
          ? (json['longitude'] as int).toDouble()
          : (json['longitude'] as double? ?? 0.0),
      isSeller: json['isSeller'] ?? false,
      isEntregador: json['isEntregador'],
      cpf: json['cpf'],
      ativo: json['ativo'] ?? true,
      dataCriacao: json['data_criacao'] != null
          ? DateTime.parse(json['data_criacao'])
          : DateTime.now(),
      dataAtualizacao: json['data_atualizacao'] != null
          ? DateTime.parse(json['data_atualizacao'])
          : DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'cpf': cpf,
        'ativo': ativo,
        'data_criacao': dataCriacao.toIso8601String(),
        'data_atualizacao': dataAtualizacao.toIso8601String(),
      };

  // Método para converter para UserModel (agora é desnecessário, mas mantido para compatibilidade)
  UserModel toUserModel() {
    return this;
  }

  // Getters específicos do cliente
  String get nome => name;
  String get telefone => phone;
  bool get isSellerUser => isSeller;
}

class ClientAddressModel extends AddressModel {
  final String cep;
  final String rua;
  final String bairro;
  final String cidade;
  final String estado;
  final String numero;
  final String? complemento;

  ClientAddressModel({
    required this.cep,
    required this.rua,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.numero,
    this.complemento,
  }) : super(
          street: rua,
          number: int.tryParse(numero) ?? 0,
          complement: complemento,
          neighborhood: bairro,
          city: cidade,
          state: estado,
          zipCode: cep,
        );

  factory ClientAddressModel.fromJson(Map<String, dynamic> json) =>
      ClientAddressModel(
        cep: json['cep']?.toString() ?? '',
        rua: json['rua']?.toString() ?? '',
        bairro: json['bairro']?.toString() ?? '',
        cidade: json['cidade']?.toString() ?? '',
        estado: json['estado']?.toString() ?? '',
        numero: json['numero']?.toString() ?? '',
        complemento: json['complemento']?.toString(),
      );

  @override
  Map<String, dynamic> toJson() => {
        'cep': cep,
        'rua': rua,
        'bairro': bairro,
        'cidade': cidade,
        'estado': estado,
        'numero': numero,
        'complemento': complemento,
      };

  // Método para converter para AddressModel (agora é desnecessário, mas mantido para compatibilidade)
  AddressModel toAddressModel() {
    return this;
  }

  @override
  String get fullAddress {
    final parts = <String>[];

    if (rua.isNotEmpty) parts.add(rua);
    if (numero.isNotEmpty) parts.add(numero);
    if (complemento != null && complemento!.isNotEmpty) parts.add(complemento!);
    if (bairro.isNotEmpty) parts.add(bairro);
    if (cidade.isNotEmpty && estado.isNotEmpty) {
      parts.add('$cidade - $estado');
    } else if (cidade.isNotEmpty) {
      parts.add(cidade);
    } else if (estado.isNotEmpty) {
      parts.add(estado);
    }
    if (cep.isNotEmpty) parts.add(cep);

    return parts.isEmpty ? 'Endereço não informado' : parts.join(', ');
  }
}
