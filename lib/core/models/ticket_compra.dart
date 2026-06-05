class TicketCompra {
  TicketCompra({
    required this.id,
    required this.usuarioId,
    required this.ticketId,
    required this.quantidade,
    required this.status,
    this.ticket,
    this.usuario,
  });

  factory TicketCompra.fromJson(Map<String, dynamic> json) {
    return TicketCompra(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      ticketId: json['ticket_id'] as int,
      quantidade: json['quantidade'] as int,
      status: json['status'] as String,
      ticket: json['ticket'] != null
          ? TicketCompra._parseTicket(json['ticket'])
          : null,
      usuario: json['usuario'] != null
          ? TicketCompra._parseUsuario(json['usuario'])
          : null,
    );
  }

  static dynamic _parseTicket(dynamic data) {
    if (data == null) return null;
    return data is Map<String, dynamic>
        ? data
        : data;
  }

  static dynamic _parseUsuario(dynamic data) {
    if (data == null) return null;
    return data is Map<String, dynamic>
        ? data
        : data;
  }

  final int id;
  final int usuarioId;
  final int ticketId;
  final int quantidade;
  final String status;
  final Map<String, dynamic>? ticket;
  final Map<String, dynamic>? usuario;

  bool get isPago => status == 'Pago';
  bool get isPendente => status == 'Pendente';
  bool get isCancelado => status == 'Cancelado';

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'ticket_id': ticketId,
      'quantidade': quantidade,
      'status': status,
    };
  }
}
