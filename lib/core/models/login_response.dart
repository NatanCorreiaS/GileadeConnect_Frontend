class LoginResponse {
  LoginResponse({required this.token, required this.usuario});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
    );
  }

  final String token;
  final Usuario usuario;
}

class Usuario {
  Usuario({
    required this.id,
    required this.nome,
    required this.tipoUsuario,
    required this.cpf,
    required this.idade,
    required this.celular,
    required this.igreja,
    required this.papelIgreja,
    required this.estadoCivil,
    required this.email,
    required this.sexo,
    required this.cidade,
    required this.estadoUf,
    required this.escolaridade,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nome: json['nome'] as String,
      tipoUsuario: json['tipo_usuario'] as String,
      cpf: json['cpf'] as String,
      idade: json['idade'] as int,
      celular: json['celular'] as String,
      igreja: json['igreja'] as String,
      papelIgreja: json['papel_igreja'] as String,
      estadoCivil: json['estado_civil'] as String,
      email: json['email'] as String,
      sexo: json['sexo'] as String,
      cidade: json['cidade'] as String,
      estadoUf: json['estado_uf'] as String,
      escolaridade: json['escolaridade'] as String,
    );
  }

  final int id;
  final String nome;
  final String tipoUsuario;
  final String cpf;
  final int idade;
  final String celular;
  final String igreja;
  final String papelIgreja;
  final String estadoCivil;
  final String email;
  final String sexo;
  final String cidade;
  final String estadoUf;
  final String escolaridade;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo_usuario': tipoUsuario,
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
