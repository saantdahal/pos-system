import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/server/bloc/server_bloc.dart';
import 'package:bhansa_ghar/offline/server/bloc/server_event.dart';
import 'package:bhansa_ghar/offline/server/bloc/server_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/setting_item.dart';

class ServerSettingsSection extends StatelessWidget {
  const ServerSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServerBloc, ServerState>(
      builder: (context, state) {
        final isRunning = state.status == ServerStatus.running;
        final isStarting = state.status == ServerStatus.starting;
        final isStopping = state.status == ServerStatus.stopping;

        String subtitle;
        if (isStarting) {
          subtitle = AppLocalizations.of(context)!.startingServer;
        } else if (isStopping) {
          subtitle = AppLocalizations.of(context)!.stoppingServer;
        } else if (isRunning) {
          subtitle =
              '${AppLocalizations.of(context)!.runningAt} ${state.ip}:${state.port}';
        } else if (state.status == ServerStatus.error) {
          subtitle =
              '${AppLocalizations.of(context)!.serverError} ${state.errorMessage}';
        } else {
          subtitle = AppLocalizations.of(context)!.serverOffline;
        }

        return SettingItem(
          icon: Icons.wifi_tethering,
          title: AppLocalizations.of(context)!.webServer,
          subtitle: subtitle,
          trailing: isStarting || isStopping
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Switch(
                  value: isRunning,
                  onChanged: (value) {
                    if (value) {
                      context.read<ServerBloc>().add(StartServer());
                    } else {
                      _showStopServerConfirmation(context);
                    }
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.green,
                ),
        );
      },
    );
  }

  void _showStopServerConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.stopServerTitle),
        content: Text(AppLocalizations.of(context)!.stopServerMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ServerBloc>().add(StopServer());
            },
            child: Text(
              AppLocalizations.of(context)!.stop,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
