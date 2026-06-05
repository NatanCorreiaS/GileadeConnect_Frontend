class Pagamento {
  Pagamento({
    required this.id,
    required this.usuarioId,
    required this.ticketCompraId,
    required this.status,
    this.valor,
    this.dataPagamento,
    this.ticketCompra,
  });

  factory Pagamento.fromJson(Map<String, dynamic> json) {
    return Pagamento(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      ticketCompraId: json['ticket_compra_id'] as int,
      status: json['status'] as String? ?? 'Pendente',
      valor: json['valor'] != null
          ? double.parse(json['valor'].toString())
          : null,
      dataPagamento: json['data_pagamento'] as String?,
      ticketCompra: json['ticket_compra'] as Map<String, dynamic>?,
    );
  }

  final int id;
  final int usuarioId;
  final int ticketCompraId;
  final String status;
  final double? valor;
  final String? dataPagamento;
  final Map<String, dynamic>? ticketCompra;
}
