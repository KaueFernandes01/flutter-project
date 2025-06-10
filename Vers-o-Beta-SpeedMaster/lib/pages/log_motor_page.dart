import 'package:flutter/material.dart';
import '../services/log_service.dart';

// Pra formatação de data/hora
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LogMotorPage extends StatelessWidget {
  final int usuarioId;

  const LogMotorPage({super.key, required this.usuarioId});

  String formatarDataLocal(String iso8601) {
    try {
      // Garante que os fusos estão carregados
  
        tz.initializeTimeZones();
      

      // Converte a string pra DateTime UTC
      final dt = DateTime.parse(iso8601).toUtc();

      // Define o fuso horário do Recife
      final recife = tz.getLocation('America/Recife');

      // Converte pra hora local
      final dtRecife = tz.TZDateTime.from(dt, recife);

      // Formata como dd/MM/yyyy às HH:mm
      return '${DateFormat('dd/MM/yyyy').format(dtRecife)} às ${DateFormat('HH:mm').format(dtRecife)}';
    } catch (_) {
      return 'Data inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logs do Motor')),
      body: FutureBuilder<List<dynamic>>(
        future: LogService().getLogsDoMotor(usuarioId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar logs do motor: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum log encontrado.'));
          }

          final logs = snapshot.data!;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];

              final String status = log['status'] ?? 'Desconhecido';
              final int velocidade = log['velocidade'] ?? 0;
              final String dataHoraISO = log['data_hora'] ?? 'Data não disponível';
              final String detalhes = log['detalhes'] ?? 'Sem detalhes';

              final String dataFormatada = formatarDataLocal(dataHoraISO);

              String acao = 'Alterou o motor para $status com velocidade $velocidade RPM';
              if (status.toLowerCase() == 'ligado') {
                acao = 'Ligou o motor ($velocidade vel)';
              } else if (status.toLowerCase() == 'desligado') {
                acao = 'Desligou o motor';
              }

              return ListTile(
                leading: const Icon(Icons.settings_remote, color: Colors.green),
                title: Text(acao),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detalhes),
                    const SizedBox(height: 4),
                    Text('Data: $dataFormatada'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}