import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/offline/core/bloc/theme/theme_bloc.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/setting_item.dart';

class AppearanceSettingsSection extends StatelessWidget {
  const AppearanceSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return SettingItem(
          icon: state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          title: AppLocalizations.of(context)!.darkMode,
          subtitle: state.isDarkMode
              ? AppLocalizations.of(context)!.currentlyUsingDarkTheme
              : AppLocalizations.of(context)!.currentlyUsingLightTheme,
          trailing: Switch(
            value: state.isDarkMode,
            onChanged: (value) {
              context.read<ThemeBloc>().add(ToggleThemeEvent());
            },
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.blue,
          ),
        );
      },
    );
  }
}
