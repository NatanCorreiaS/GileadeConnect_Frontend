import 'beneficiado.dart';

class CheckoutRequest {
  CheckoutRequest({
    required this.usuarioId,
    required this.ticketId,
    required this.quantidade,
    required this.beneficiados,
  });

  final int usuarioId;
  final int ticketId;
  final int quantidade;
  final List<Beneficiado> beneficiados;

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'ticket_id': ticketId,
      'quantidade': quantidade,
      'beneficiados': beneficiados.map((b) => b.toJson()).toList(),
      'back_urls': {
        'success': 'gileadeconnect://checkout/success',
        'failure': 'gileadeconnect://checkout/failure',
        'pending': 'gileadeconnect://checkout/pending',
      },
      'auto_return': 'approved',
    };
  }
}

class CheckoutResponse {
  CheckoutResponse({
    required this.preferenceId,
    required this.initPoint,
    required this.sandboxInitPoint,
    required this.ticketCompraId,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      preferenceId: json['preference_id'] as String,
      initPoint: json['init_point'] as String,
      sandboxInitPoint: json['sandbox_init_point'] as String,
      ticketCompraId: json['ticket_compra_id'] as int,
    );
  }

  final String preferenceId;
  final String initPoint;
  final String sandboxInitPoint;
  final int ticketCompraId;
}
