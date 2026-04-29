import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum _ButtonVariant { primary, secondary, text }

class EpidexaButton extends StatelessWidget {
  const EpidexaButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.icon,
  }) : _variant = _ButtonVariant.primary;

  const EpidexaButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.icon,
  }) : _variant = _ButtonVariant.secondary;

  const EpidexaButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.icon,
  }) : _variant = _ButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final Widget? icon;
  final _ButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final callback = enabled ? onPressed : null;

    return switch (_variant) {
      _ButtonVariant.primary => _PrimaryButton(
          label: label,
          onPressed: callback,
          icon: icon,
          enabled: enabled,
        ),
      _ButtonVariant.secondary => _SecondaryButton(
          label: label,
          onPressed: callback,
          icon: icon,
          enabled: enabled,
        ),
      _ButtonVariant.text => _TextButtonWidget(
          label: label,
          onPressed: callback,
          enabled: enabled,
        ),
    };
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.enabled,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 150),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.plum.withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.plum,
            foregroundColor: AppColors.surface,
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: AppTextStyles.buttonText),
                    const SizedBox(width: 8),
                    icon!,
                  ],
                )
              : Text(label, style: AppTextStyles.buttonText),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    required this.enabled,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 150),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryText,
            side: BorderSide(color: AppColors.plum.withOpacity(0.35), width: 1.5),
            shape: const StadiumBorder(),
          ),
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: AppTextStyles.buttonTextSecondary),
                    const SizedBox(width: 8),
                    icon!,
                  ],
                )
              : Text(label, style: AppTextStyles.buttonTextSecondary),
        ),
      ),
    );
  }
}

class _TextButtonWidget extends StatelessWidget {
  const _TextButtonWidget({
    required this.label,
    required this.onPressed,
    required this.enabled,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTextStyles.buttonTextSecondary.copyWith(
          color: enabled ? AppColors.plum : AppColors.border,
        ),
      ),
    );
  }
}
