import 'package:flutter/material.dart';
import '../services/log_service.dart';
import 'package:intl/intl.dart'; 
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LogMotorPage extends StatefulWidget {
  final int usuarioId;

  const LogMotorPage({super.key, required this.usuarioId});

  @override
  State<LogMotorPage> createState() => _LogMotorPageState();
}

class _LogMotorPageState extends State<LogMotorPage> {
  bool timezoneLoaded = false;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    setState(() {
      timezoneLoaded = true;
    });
  }

  String formatarDataLocal(String iso8601) {
    try {
      final dtUtc = DateTime.parse(iso8601).toUtc();
      final location = tz.getLocation('America/Recife');
      final dtLocal = tz.TZDateTime.from(dtUtc, location);

      return '${DateFormat('dd/MM/yyyy').format(dtLocal)} às ${DateFormat('HH:mm').format(dtLocal)}';
    } catch (_) {
      return 'Data inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!timezoneLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Logs do Motor')),
      body: FutureBuilder<List<dynamic>>(
        future: LogService().getLogsDoMotor(widget.usuarioId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar logs do motor: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum log de motor encontrado.'));
          }

          final List<dynamic> logs = snapshot.data!;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];

              final String status = log['status'] ?? 'Desconhecido';
              final int velocidade = log['velocidade'] ?? 0;
              final String dataHoraISO = log['data_hora']?.toString() ?? 'Data não disponível';

              final String dataFormatada = formatarDataLocal(dataHoraISO);

              String acao = 'Alterou o motor para $status com velocidade $velocidade RPM';
              if (status.toLowerCase().contains('ligado')) {
                acao = 'Ligou o motor ($velocidade RPM)';
              } else if (status.toLowerCase().contains('desligado')) {
                acao = 'Desligou o motor';
              }

              return ListTile(
                leading: const Icon(Icons.settings_remote, color: Colors.green),
                title: Text(acao),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detalhes do log', style: TextStyle(fontSize: 12)),
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
