class PessoaCreateRequest {
  PessoaCreateRequest({
    required this.nome,
    required this.email,
    required this.senha,
    required this.cpf,
    required this.idade,
    required this.celular,
    required this.igreja,
    required this.papelIgreja,
    required this.estadoCivil,
    required this.sexo,
    required this.cidade,
    required this.estadoUf,
    required this.escolaridade,
    this.tipoUsuario = 'Usuario',
  });

  final String nome;
  final String email;
  final String senha;
  final String cpf;
  final int idade;
  final String celular;
  final String igreja;
  final String papelIgreja;
  final String estadoCivil;
  final String sexo;
  final String cidade;
  final String estadoUf;
  final String escolaridade;
  final String tipoUsuario;

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'senha': senha,
      'cpf': cpf,
      'idade': idade,
      'celular': celular,
      'igreja': igreja,
      'papel_igreja': papelIgreja,
      'estado_civil': estadoCivil,
      'sexo': sexo,
      'cidade': cidade,
      'estado_uf': estadoUf,
      'escolaridade': escolaridade,
      'tipo_usuario': tipoUsuario,
    };
  }
}
