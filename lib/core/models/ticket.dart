class Ticket {
  Ticket({
    required this.id,
    required this.tipo,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.quantidadeDisponivel,
    required this.dataEvento,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      tipo: json['tipo'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      preco: double.parse(json['preco'].toString()),
      quantidadeDisponivel: json['quantidade_disponivel'] as int,
      dataEvento: json['data_evento'] as String,
    );
  }

  final int id;
  final String tipo;
  final String nome;
  final String descricao;
  final double preco;
  final int quantidadeDisponivel;
  final String dataEvento;

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'nome': nome,
      'descricao': descricao,
      'preco': preco.toStringAsFixed(2),
      'quantidade_disponivel': quantidadeDisponivel,
      'data_evento': dataEvento,
    };
  }

  int beneficiadosPorUnidade() {
    switch (tipo) {
      case 'Duo':
        return 2;
      case 'Caravana':
        return 10;
      default:
        return 1;
    }
  }
}
