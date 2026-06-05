class Beneficiado {
  Beneficiado({
    required this.nome,
    required this.cpf,
    this.idade,
    this.celular,
    this.igreja,
    this.papelIgreja,
    this.estadoCivil,
    this.email,
    this.sexo,
    this.cidade,
    this.estadoUf,
    this.escolaridade,
  });

  factory Beneficiado.fromJson(Map<String, dynamic> json) {
    return Beneficiado(
      nome: json['nome'] as String,
      cpf: json['cpf'] as String,
      idade: json['idade'] as int?,
      celular: json['celular'] as String?,
      igreja: json['igreja'] as String?,
      papelIgreja: json['papel_igreja'] as String?,
      estadoCivil: json['estado_civil'] as String?,
      email: json['email'] as String?,
      sexo: json['sexo'] as String?,
      cidade: json['cidade'] as String?,
      estadoUf: json['estado_uf'] as String?,
      escolaridade: json['escolaridade'] as String?,
    );
  }

  final String nome;
  final String cpf;
  final int? idade;
  final String? celular;
  final String? igreja;
  final String? papelIgreja;
  final String? estadoCivil;
  final String? email;
  final String? sexo;
  final String? cidade;
  final String? estadoUf;
  final String? escolaridade;

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cpf': cpf,
      'idade': idade,
      'celular': celular,
      'igreja': igreja,
      'papel_igreja': papelIgreja,
      'estado_civil': estadoCivil,
      'email': email,
      'sexo': sexo,
      'cidade': cidade,
      'estado_uf': estadoUf,
      'escolaridade': escolaridade,
    };
  }
}
