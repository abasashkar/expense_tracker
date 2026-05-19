import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';

/// Nickname input matching onboarding design (dark field + green check when valid).
class NicknameField extends StatelessWidget {
  const NicknameField({
    super.key,
    required this.controller,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  static bool isValidNickname(String value) => value.trim().length >= 2;

  @override
  Widget build(BuildContext context) {
    final isValid = isValidNickname(controller.text);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
              onChanged: onChanged,
              onSubmitted: (_) => onSubmitted?.call(),
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: 'Eg: Johnnnie',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                isDense: true,
              ),
            ),
          ),
          if (isValid)
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.success,
                size: 22,
              ),
            )
          else
            const SizedBox(width: 16),
        ],
      ),
    );
  }
}
