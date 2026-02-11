import 'package:flutter/material.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';

class NumberPad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onDeletePressed;

  const NumberPad({
    super.key,
    required this.onNumberPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1-3
        for (int row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int col = 1; col <= 3; col++)
                  _buildNumberButton(
                    context,
                    (row * 3 + col).toString(),
                    onNumberPressed,
                  ),
              ],
            ),
          ),
        // Row 0 and Delete
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 70, height: 70), // Empty space
            _buildNumberButton(context, '0', onNumberPressed),
            _buildDeleteButton(context, onDeletePressed),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(
    BuildContext context,
    String number,
    Function(String) onPressed,
  ) {
    return GestureDetector(
      onTap: () => onPressed(number),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.getCardBackground(context),
          border: Border.all(
            color: AppColors.getSubtitleColor(context).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.getCardBackground(context),
          border: Border.all(
            color: AppColors.getSubtitleColor(context).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(Icons.backspace_outlined, color: AppColors.red, size: 24),
        ),
      ),
    );
  }
}
