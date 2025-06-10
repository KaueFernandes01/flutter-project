import 'package:flutter/material.dart';
import '../services/log_service.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LogPage extends StatefulWidget {
  final int usuarioId;

  const LogPage({super.key, required this.usuarioId});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
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
    final dtOriginal = DateTime.tryParse(iso8601);
    if (dtOriginal == null) return 'Data inválida';

    tz.initializeTimeZones();
    final recife = tz.getLocation('America/Recife');

    final dtRecife = tz.TZDateTime(
      recife,
      dtOriginal.year,
      dtOriginal.month,
      dtOriginal.day,
      dtOriginal.hour,
      dtOriginal.minute,
      dtOriginal.second,
    );

    return '${DateFormat('dd/MM/yyyy').format(dtRecife)} às ${DateFormat('HH:mm').format(dtRecife)}';
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
      appBar: AppBar(title: const Text('Registro de Atividades')),
      body: FutureBuilder<List<dynamic>>(
        future: LogService().getLogsDoUsuario(widget.usuarioId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar logs: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum log encontrado.'));
          }

          final List<dynamic> logs = snapshot.data!;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final String acao = log['acao'] ?? 'Ação desconhecida';
              final String detalhes = log['detalhes'] ?? 'Sem detalhes';
              final String dataHora = log['data_hora'] ?? 'Data não disponível';

              final String dataFormatada = formatarDataLocal(dataHora);

              return ListTile(
                leading: const Icon(Icons.history),
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
