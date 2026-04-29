import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class EpidexaScaffold extends StatelessWidget {
  const EpidexaScaffold({
    super.key,
    required this.body,
    this.title,
    this.onBack,
    this.actions,
    this.bottomPadding = true,
    this.showBack = true,
    this.useLogo = false,
  });

  final Widget body;
  final String? title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool bottomPadding;
  final bool showBack;
  final bool useLogo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        automaticallyImplyLeading: onBack == null && showBack,
        leading: onBack != null
            ? _BackButton(onBack: onBack!)
            : null,
        titleSpacing: onBack != null ? 0 : NavigationToolbar.kMiddleSpacing,
        title: title != null
            ? Text(
                title!,
                style: useLogo ? AppTextStyles.logo : AppTextStyles.subheading,
              )
            : null,
        actions: actions,
      ),
      body: SafeArea(
        bottom: bottomPadding,
        child: body,
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios_rounded,
              size: 16,
              color: AppColors.primaryText,
            ),
          ],
        ),
      ),
    );
  }
}
