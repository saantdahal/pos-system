import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/core/services/tts_service.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/setting_item.dart';
import 'package:bhansa_ghar/offline/core/bloc/localization/localization_bloc.dart';

class VoiceSettingsSection extends StatefulWidget {
  const VoiceSettingsSection({super.key});

  @override
  State<VoiceSettingsSection> createState() => _VoiceSettingsSectionState();
}

class _VoiceSettingsSectionState extends State<VoiceSettingsSection> {
  late TtsService _ttsService;
  bool _isTtsEnabled = true;
  double _ttsVolume = 1.0;
  double _ttsRate = 0.5;
  double _ttsPitch = 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ttsService = RepositoryProvider.of<TtsService>(context);
    _isTtsEnabled = _ttsService.isEnabled;
    _ttsVolume = _ttsService.volume;
    _ttsRate = _ttsService.rate;
    _ttsPitch = _ttsService.pitch;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingItem(
          icon: Icons.record_voice_over,
          title: AppLocalizations.of(context)!.enableVoiceAnnouncements,
          subtitle: _isTtsEnabled
              ? AppLocalizations.of(context)!.enabled
              : AppLocalizations.of(context)!.disabled,
          trailing: Switch(
            value: _isTtsEnabled,
            onChanged: (value) async {
              await _ttsService.setEnabled(value);
              setState(() {
                _isTtsEnabled = value;
              });
            },
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.blue,
          ),
        ),
        if (_isTtsEnabled) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.volume}: ${(_ttsVolume * 100).toInt()}%',
                  style: TextStyle(color: AppColors.getTextColor(context)),
                ),
                Slider(
                  value: _ttsVolume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      _ttsVolume = value;
                    });
                  },
                  onChangeEnd: (value) async {
                    await _ttsService.setVolume(value);
                  },
                ),
                Text(
                  '${AppLocalizations.of(context)!.speechRate}: ${_ttsRate.toStringAsFixed(1)}x',
                  style: TextStyle(color: AppColors.getTextColor(context)),
                ),
                Slider(
                  value: _ttsRate,
                  min: 0.1,
                  max: 2.0,
                  onChanged: (value) {
                    setState(() {
                      _ttsRate = value;
                    });
                  },
                  onChangeEnd: (value) async {
                    await _ttsService.setRate(value);
                  },
                ),
                Text(
                  '${AppLocalizations.of(context)!.pitch}: ${_ttsPitch.toStringAsFixed(1)}',
                  style: TextStyle(color: AppColors.getTextColor(context)),
                ),
                Slider(
                  value: _ttsPitch,
                  min: 0.5,
                  max: 2.0,
                  onChanged: (value) {
                    setState(() {
                      _ttsPitch = value;
                    });
                  },
                  onChangeEnd: (value) async {
                    await _ttsService.setPitch(value);
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final locale = context
                          .read<LocalizationBloc>()
                          .state
                          .locale
                          .languageCode;
                      final message = AppLocalizations.of(
                        context,
                      )!.testVoiceMessage;
                      await _ttsService.setLanguage(locale);
                      await _ttsService.speak(message);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(AppLocalizations.of(context)!.testVoice),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
