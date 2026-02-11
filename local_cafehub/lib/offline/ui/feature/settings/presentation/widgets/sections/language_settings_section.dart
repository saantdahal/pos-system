import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/offline/core/bloc/localization/localization_bloc.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/setting_item.dart';

class LanguageSettingsSection extends StatelessWidget {
  const LanguageSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return SettingItem(
          icon: Icons.language,
          title: AppLocalizations.of(context)!.changeLanguage,
          trailing: DropdownButton<String>(
            value: state.locale.languageCode,
            underline: const SizedBox(),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).iconTheme.color,
            ),
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text(
                  'English',
                  style: TextStyle(color: AppColors.getTextColor(context)),
                ),
              ),
              DropdownMenuItem(
                value: 'ne',
                child: Text(
                  'नेपाली',
                  style: TextStyle(color: AppColors.getTextColor(context)),
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<LocalizationBloc>().add(
                  ChangeLanguage(Locale(value)),
                );
              }
            },
          ),
          subtitle: AppLocalizations.of(context)!.changeLanguageSubtitle,
        );
      },
    );
  }
}
