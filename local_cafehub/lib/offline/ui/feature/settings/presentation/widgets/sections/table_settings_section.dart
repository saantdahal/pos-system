import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/core/utils/snackbar.dart';
import 'package:bhansa_ghar/offline/ui/feature/tables/presentation/bloc/table_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/tables/presentation/bloc/table_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/tables/presentation/bloc/table_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/tables/presentation/widgets/manage_tables_dialog.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/setting_item.dart';

class TableSettingsSection extends StatelessWidget {
  const TableSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TableBloc, TableState>(
      builder: (context, state) {
        final tableCount = state.tables.length;
        final subtitle = tableCount == 0
            ? AppLocalizations.of(context)!.noTablesConfigured
            : '$tableCount ${tableCount == 1 ? AppLocalizations.of(context)!.tableConfigured : AppLocalizations.of(context)!.tablesConfigured}';

        return SettingItem(
          icon: Icons.table_restaurant,
          title: AppLocalizations.of(context)!.manageTables,
          subtitle: subtitle,
          onTap: () {
            showDialog(
              context: context,
              builder: (dialogContext) => ManageTablesDialog(
                currentTableCount: tableCount,
                onSave: (count) {
                  context.read<TableBloc>().add(SetNumberOfTables(count));
                  snackBar(
                    message:
                        '${AppLocalizations.of(context)!.successfullySetTables} $count ${count == 1 ? AppLocalizations.of(context)!.tableConfigured : AppLocalizations.of(context)!.tablesConfigured}',
                    messageType: MessageType.success,
                  );
                },
              ),
            );
          },
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        );
      },
    );
  }
}
