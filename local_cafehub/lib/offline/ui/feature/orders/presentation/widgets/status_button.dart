import 'package:flutter/material.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class StatusButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback? onTap;

  const StatusButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.activeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor : const Color(0xFF3A3A3C),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive && label == 'Received') ...[
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
              ],
              if (isActive && label == 'Preparing') ...[
                const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 16,
                ), // Using refresh as spinner proxy
                const SizedBox(width: 4),
              ],
              if (isActive && label == 'Ready') ...[
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
              ],
              if (isActive && label == 'Completed') ...[
                const Icon(Icons.done_all, color: Colors.white, size: 16),
                const SizedBox(width: 4),
              ],
              Text(
                _getLocalizedLabel(context, label),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLocalizedLabel(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context)!;
    switch (label) {
      case 'Received':
        return l10n.received;
      case 'Preparing':
        return l10n.preparing;
      case 'Ready':
        return l10n.ready;
      case 'Completed':
        return l10n.completed;
      default:
        return label;
    }
  }
}
